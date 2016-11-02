//
//  CPictureViewController.m
//  CPicture
//
//  Created by mac on 16/10/26.
//  Copyright © 2016年 CYC. All rights reserved.
//

// 1、App的主页，有两个按钮"展示相册"、"导入相片"
// 2、点击按钮，按钮会展示放大后缩小的动画
// 3、点击展示相册，push到沙盒保存的页面，并展示相片
// 4、点击导入相片，会有提示框，"从相册获取"、"拍照"




#import "CPictureViewController.h"
#import "ShowPictureController.h"
#import "InputPictureController.h"
#import "FMDB.h"
#import "JustImage.h"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width        // 屏幕宽度
#define kScreenHeight [UIScreen mainScreen].bounds.size.height      // 屏幕高度
#define ButtonWidth 100     // 按钮宽度
#define ButtonHeight 100    // 按钮高度
// 缩略图文件路径
#define ThumbImagePath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"/thumbImage"]
// 原始图文件路径
#define FullImagePath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"/fullImage"]


@interface CPictureViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    FMDatabase *_fmdb;
    NSMutableDictionary *_thumbImageDic; // 存储缩略图的字典
    NSMutableDictionary *_fullImageDic;  // 存储原始图的字典
}

@end

@implementation CPictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"大厅";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 波浪视图
    UIImageView *circleM = [[UIImageView alloc] initWithFrame:CGRectMake(0, 500, 375, 375)];
    circleM.image = [UIImage imageNamed:@"family.png"];
    [self.view addSubview:circleM];
    [NSTimer scheduledTimerWithTimeInterval:.1
                                     target:self
                                   selector:@selector(flowGoingM:)
                                   userInfo:circleM
                                    repeats:YES];
    
    
    
    // 创建缩略图、原始图文件夹
    [[NSFileManager defaultManager] createDirectoryAtPath:ThumbImagePath withIntermediateDirectories:YES attributes:nil error:nil];
    BOOL isTrue = [[NSFileManager defaultManager] createDirectoryAtPath:FullImagePath withIntermediateDirectories:YES attributes:nil error:nil];
    NSLog(@"%d", isTrue);
    
    UIButton *showButton = [UIButton buttonWithType:UIButtonTypeCustom];
    showButton.frame = CGRectMake((kScreenWidth - ButtonWidth)/2, (kScreenHeight - ButtonHeight*2 - 50)/2, ButtonWidth, ButtonHeight);
    [showButton setImage:[UIImage imageNamed:@"ShowPicture.png"] forState:UIControlStateNormal];
    showButton.adjustsImageWhenHighlighted = NO;
    [showButton addTarget:self action:@selector(showPictureAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showButton];
   
    
    UIButton *inputButton = [UIButton buttonWithType:UIButtonTypeCustom];
    inputButton.frame = CGRectMake((kScreenWidth - ButtonWidth)/2, (kScreenHeight - ButtonHeight*2 - 50)/2 + (ButtonHeight + 50), ButtonWidth, ButtonHeight);
    [inputButton setImage:[UIImage imageNamed:@"InputPicture.png"] forState:UIControlStateNormal];
    inputButton.adjustsImageWhenHighlighted = NO;
    [inputButton addTarget:self action:@selector(inputPictureAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:inputButton];
 
}



#pragma mark - 展示相册
- (void)showPictureAction:(UIButton *)button {

    [UIView animateWithDuration:.35
                     animations:^{
                         button.transform = CGAffineTransformMakeScale(1.5, 1.5);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.35
                                          animations:^{
                                              button.transform = CGAffineTransformMakeScale(1, 1);
                                          } completion:^(BOOL finished) {
                                              [self.navigationController pushViewController:[[ShowPictureController alloc] init] animated:YES];

                                          }];
                         

                     }];
    

}
#pragma mark - 导入相片
- (void)inputPictureAction:(UIButton *)button {
    
    [UIView animateWithDuration:.35
                     animations:^{
                         button.transform = CGAffineTransformMakeScale(1.5, 1.5);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.35
                                          animations:^{
                                              button.transform = CGAffineTransformMakeScale(1, 1);
                                          }];
                     }];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"您想从哪儿导入照片？"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"从相册导入"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self.navigationController pushViewController:[[InputPictureController alloc] init] animated:YES];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"拍摄"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self useCamare];
                                            }]];
    [self presentViewController:alert animated:YES completion:nil];

}


#pragma mark - 打开摄像头
- (void)useCamare {

    if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
    
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"不存在摄像头"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    // 打开摄像头，拍摄
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerController.delegate = self;
    pickerController.mediaTypes = @[@"public.image"];
    [self presentViewController:pickerController animated:YES completion:nil];

}

#pragma mark - 拍摄照片后,会出现重新拍摄和使用照片两个选项，使用照片就会调用下面的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            
            // 压缩成缩略图
            UIImage *thumbImage = [self imageByScalingAndCroppingForSize:CGSizeMake(85, 85) withImage:image];

            // 保存缩略图
            NSString *thumbPath = [ThumbImagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/pic_%@.png", thumbImage]];
            [UIImagePNGRepresentation(thumbImage) writeToFile:thumbPath atomically:YES];
            
            // 保存原图
            NSString *fullPath = [FullImagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/pic_%@.png", image]];
            [UIImagePNGRepresentation(image) writeToFile:fullPath atomically:YES];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}


#pragma mark - 将图片压缩成指定大小
//图片压缩到指定大小
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize withImage:(UIImage *)image {
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - 波浪图定时偏移
- (void)flowGoingM:(NSTimer *)timer {

    UIImageView *imageView = timer.userInfo;
    imageView.transform = CGAffineTransformRotate(imageView.transform, .05);

}






















@end
