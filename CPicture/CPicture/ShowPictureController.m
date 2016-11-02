//
//  ShowPictureController.m
//  CPicture
//
//  Created by mac on 16/10/26.
//  Copyright © 2016年 CYC. All rights reserved.
//

// 1、用集合视图展示沙盒存储的相片









#import "ShowPictureController.h"
#import "CCollectionViewCell.h"
#import "FMDB.h"
#import "JustImage.h"
#define CollectionViewCellID @"CollectionViewCellIDNew"    // 单元格重用标志符
#define kScreenWidth [UIScreen mainScreen].bounds.size.width        // 屏幕宽度
#define kScreenHeight [UIScreen mainScreen].bounds.size.height      // 屏幕高度

#define CellWidth 85   // 单元格宽度
#define CellHeight 85  // 单元格高度
// 缩略图文件路径
#define ThumbImagePath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"/thumbImage"]
// 原始图文件路径
#define FullImagePath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"/fullImage"]



@interface ShowPictureController () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate> {
    UICollectionView *_collectionView;
    FMDatabase *_fmdb;
}
@property (strong, nonatomic) NSMutableArray *thumbImageArray;
@property (strong, nonatomic) NSMutableArray *fullImageArray;
@property (assign, nonatomic) NSInteger currentPage;
@property (assign, nonatomic) NSInteger index;

@end

@implementation ShowPictureController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _thumbImageArray = [NSMutableArray array];
    _fullImageArray = [NSMutableArray array];
    
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
    
    [self getImageArray];
    
    
    
}

#pragma mark - 集合视图代理方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _thumbImageArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
 
    CCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellID
                                                                          forIndexPath:indexPath];
    
    cell.cellImageView.image = _thumbImageArray[indexPath.row];

    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    // 全屏显示相片
    _index = indexPath.row;
    [self showImageDetial:indexPath.row withPoint:[collectionView cellForItemAtIndexPath:indexPath].frame.origin];
    
    
}


#pragma mark - 获取沙盒文件夹里的图片,并刷新集合视图
- (void)getImageArray {

    // 获取文件夹中所有的文件名
    NSArray *thumbNameArray = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:ThumbImagePath error:nil] pathsMatchingExtensions:[NSArray arrayWithObject:@"png"]];
    
    for (NSString *str in thumbNameArray) {
        // 取出所有缩略图
        UIImage *thumbImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", ThumbImagePath, str]];
        [_thumbImageArray addObject:thumbImage];
    }
    
    // 获取文件夹中所有的文件名
    NSArray *fullImageArray = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:FullImagePath error:nil] pathsMatchingExtensions:[NSArray arrayWithObject:@"png"]];
    for (NSString *str in fullImageArray) {
        // 取出所有原图
        UIImage *fullImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", FullImagePath, str]];
        [_fullImageArray addObject:fullImage];
    }
    
    [_collectionView reloadData];


}

#pragma mark - 点击单元格后全屏显示预览(传入参数：点击的单元格index；单元格的位置origin)
- (void)showImageDetial:(NSInteger)index withPoint:(CGPoint)origin {

    UIScrollView *imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(origin.x+85/2.0, origin.y+64+85/2.0, 0, 0)];
    imageScrollView.contentSize = CGSizeMake(3*kScreenWidth, kScreenHeight);
    imageScrollView.backgroundColor = [UIColor blackColor];
    imageScrollView.pagingEnabled = YES;
    imageScrollView.delegate = self;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:imageScrollView];
    
    // 添加UIImageView
    for (int i = 0; i < 3; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth*i, 0, kScreenWidth, kScreenHeight)];
        imageView.tag = 4396 + i;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageScrollView addSubview:imageView];
    }
    
    // 根据index修改偏移、填充照片
    if (index > 0 && index < _thumbImageArray.count-1) {
        imageScrollView.contentOffset = CGPointMake(kScreenWidth, 0);
        for (int i = 0; i < 3; i++) {
            UIImageView *imageView = [imageScrollView viewWithTag:4396 + i];
            imageView.image = _fullImageArray[index-1+i];
        }
    } else if (index == 0) {
        imageScrollView.contentOffset = CGPointMake(0, 0);
        for (int i = 0; i < 3; i++) {
            UIImageView *imageView = [imageScrollView viewWithTag:4396 + i];
            imageView.image = _fullImageArray[index+i];
        }
    } else if (index == _thumbImageArray.count-1) {
        imageScrollView.contentOffset = CGPointMake(2*kScreenWidth, 0);
        for (int i = 0; i < 3; i++) {
            UIImageView *imageView = [imageScrollView viewWithTag:4396 + i];
            imageView.image = _fullImageArray[index-2+i];
        }
    }
    
    
    [UIView animateWithDuration:.35
                     animations:^{
                         imageScrollView.frame = [UIScreen mainScreen].bounds;
                     }];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeShowImage)];
    [imageScrollView addGestureRecognizer:tap];

}

#pragma mark - 移除相片全屏预览视图
- (void)removeShowImage {

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIScrollView *scrollView = [window.subviews lastObject];
    
    [UIView animateWithDuration:.35
                     animations:^{
                         scrollView.frame = CGRectMake(kScreenWidth/2.0f, kScreenHeight/2.0f, 0, 0);
                     } completion:^(BOOL finished) {
                         [scrollView removeFromSuperview];
                     }];

}

#pragma mark - 滑动视图代理方法
// 计算当前页
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {

    NSInteger count = targetContentOffset->x / kScreenWidth;
    
    if (count == 0) {   // 中间向左
        if (_index != 0) {
            _index--;
        }
    } else if (count == 1) {
        if (_index == 0) {                                  // 左端向右
            _index++;
        } else if (_index == _thumbImageArray.count-1) {    // 右端向左
            _index--;
        }
    } else if (count == 2){ // 中间向右
        if (_index != _thumbImageArray.count-1) {
            _index++;
        }
    }
    
    
}
// 修改滑动视图内容
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    // 根据index修改偏移、填充照片
    if (_index > 0 && _index < _thumbImageArray.count-1) {
        scrollView.contentOffset = CGPointMake(kScreenWidth, 0);
        for (int i = 0; i < 3; i++) {
            UIImageView *imageView = [scrollView viewWithTag:4396 + i];
            imageView.image = _fullImageArray[_index-1+i];
        }
    } else if (_index == 0) {
        scrollView.contentOffset = CGPointMake(0, 0);
        for (int i = 0; i < 3; i++) {
            UIImageView *imageView = [scrollView viewWithTag:4396 + i];
            imageView.image = _fullImageArray[_index+i];
        }
    } else if (_index == _thumbImageArray.count-1) {
        scrollView.contentOffset = CGPointMake(2*kScreenWidth, 0);
        for (int i = 0; i < 3; i++) {
            UIImageView *imageView = [scrollView viewWithTag:4396 + i];
            imageView.image = _fullImageArray[_index-2+i];
        }
    }

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
