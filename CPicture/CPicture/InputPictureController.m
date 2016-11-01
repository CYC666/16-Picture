//
//  InputPictureController.m
//  CPicture
//
//  Created by mac on 16/10/26.
//  Copyright © 2016年 CYC. All rights reserved.
//

#import "InputPictureController.h"
#import "CCollectionViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>     //必须要导入这个库文件
#import "FMDB.h"
#import "JustImage.h"
#define CollectionViewCellID @"CollectionViewCellID"    // 单元格重用标志符
#define CellWidth 85   // 单元格宽度
#define CellHeight 85  // 单元格高度
// 缩略图文件路径
#define ThumbImagePath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"/thumbImage"]
// 原始图文件路径
#define FullImagePath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"/fullImage"]



@interface InputPictureController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource> {

    ALAssetsLibrary *_library;  // 资源库
    UICollectionView *_collectionView;
    FMDatabase *_fmdb;          // 沙盒中储存照片的数据库

}

@property (strong, nonatomic) NSMutableArray *imageArray;
@property (strong, nonatomic) NSMutableArray *selectImageArray; // 原图
@property (strong, nonatomic) NSMutableArray *thumbImageArray;  // 缩略图

@end

@implementation InputPictureController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"确定"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(sureAction:)];
    [self.navigationItem setRightBarButtonItem:rightButton];
    
    
    // 创建集合视图
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(CellWidth, CellHeight);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _collectionView = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds
                                                          collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerClass:[CCollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellID];
    [self.view addSubview:_collectionView];
    
    
    _imageArray = [NSMutableArray array];
    _selectImageArray = [NSMutableArray array];
    _thumbImageArray = [NSMutableArray array];
    //创建资源库
    _library = [[ALAssetsLibrary alloc] init];
    
    [_library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                            usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                // 如果存在这个相册就遍历
                                if (group) {
                                    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                        if (result) {
                                            
                                            //将数据存到数组中
                                            [_imageArray addObject:result];
                                        }
                                    }];
                                }
                                // 刷新集合视图数据
                                [_collectionView reloadData];
                            } failureBlock:^(NSError *error) {
                                NSLog(@"访问失败");
                            }];
    
}


#pragma mark - 集合视图代理方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _imageArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellID
                                                                           forIndexPath:indexPath];
    //取出应资源的数据
    ALAsset *result = _imageArray[indexPath.row];
    //获取缩略图
    CGImageRef cimage = [result aspectRatioThumbnail];
    //转换
    UIImage *image = [UIImage imageWithCGImage:cimage];
    [cell.cellImageView setImage:image];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CCollectionViewCell *cell = (CCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.selectImageView.image == nil) {
        // 存储已经选中的单元格
        [cell.selectImageView setImage:[UIImage imageNamed:@"CellButton.png"]];
        [_selectImageArray addObject:indexPath];
    } else {
        [cell.selectImageView setImage:nil];
        [_selectImageArray removeObject:indexPath];
    }
    
    
    
}


#pragma mark - 多选结束，处理相片
- (void)sureAction:(UIBarButtonItem *)button {

    // 耗内存资源大，放在多线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        for ( NSIndexPath * indexpath in _selectImageArray) {
            // 取出应资源的数据
            ALAsset *result = _imageArray[indexpath.row];
            
            // 获取缩略图,并保存到沙盒对应文件夹
            CGImageRef cimage = [result aspectRatioThumbnail];
            UIImage *thumbImage = [UIImage imageWithCGImage:cimage];
            [_thumbImageArray addObject:thumbImage];
            NSString *thumbPath = [ThumbImagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/pic_%@.png", thumbImage]];
            BOOL isTrue = [UIImagePNGRepresentation(thumbImage) writeToFile:thumbPath atomically:YES];
            NSLog(@"%d", isTrue);
            // 获取到原始图片,并保存到沙盒对应文件夹
            ALAssetRepresentation *presentation = [result defaultRepresentation];
            CGImageRef cImage = [presentation fullResolutionImage];
            UIImage *fullImage = [UIImage imageWithCGImage:cImage];
            NSString *fullPath = [FullImagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/pic_%@.png", fullImage]];
            [UIImagePNGRepresentation(fullImage) writeToFile:fullPath atomically:YES];
            NSLog(@"%@", fullPath);
            
        
            
            /*
            // 将对象转化成二进制文件
            NSData *thumbData = [NSKeyedArchiver archivedDataWithRootObject:fullImage];
            NSData *fullData = [NSKeyedArchiver archivedDataWithRootObject:fullImage];
            
            // 将图片存入沙盒
            NSString *thumbFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/thumbImage.db"];
            _fmdb = [FMDatabase databaseWithPath:thumbFilePath];
            [_fmdb open];
            [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS t_thumbImage (id integer PRIMARY KEY, image blob NOT NULL UNIQUE)"];
            [_fmdb executeUpdateWithFormat:@"INSERT OR IGNORE INTO t_thumbImage(image) VALUES (%@)", thumbData];
            
            NSString *fullFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/fullImage.db"];
            _fmdb = [FMDatabase databaseWithPath:fullFilePath];
            [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS t_fullImage (id integer PRIMARY KEY, image blob NOT NULL UNIQUE)"];
            [_fmdb executeUpdateWithFormat:@"INSERT OR IGNORE INTO t_fullImage(image) VALUES (%@)", fullData];
            
            [_fmdb close];
             */
            
            
            
            
        }
        
    });
    
    
    
    // 返回上一层
    [self.navigationController popViewControllerAnimated:YES];
}































- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
