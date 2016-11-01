//
//  ShowPictureController.m
//  CPicture
//
//  Created by mac on 16/10/26.
//  Copyright © 2016年 CYC. All rights reserved.
//

#import "ShowPictureController.h"
#import "CCollectionViewCell.h"
#import "FMDB.h"
#import "JustImage.h"
#define CollectionViewCellID @"CollectionViewCellIDNew"    // 单元格重用标志符
#define CellWidth 85   // 单元格宽度
#define CellHeight 85  // 单元格高度
// 缩略图文件路径
#define ThumbImagePath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"/thumbImage"]
// 原始图文件路径
#define FullImagePath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"/fullImage"]
@interface ShowPictureController () <UICollectionViewDelegate, UICollectionViewDataSource> {
    UICollectionView *_collectionView;
    FMDatabase *_fmdb;
}
@property (strong, nonatomic) NSMutableArray *thumbImageArray;
@property (strong, nonatomic) NSMutableArray *fullImageArray;

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
