//
//  CCollectionViewCell.m
//  CPicture
//
//  Created by mac on 16/10/27.
//  Copyright © 2016年 CYC. All rights reserved.
//


// 1、单元格显示相片，底层是照片，顶层是单元格选中时显示的小红勾图片






#import "CCollectionViewCell.h"
#define CellWidth 85   // 单元格宽度
#define CellHeight 85  // 单元格高度


@interface CCollectionViewCell ()


@end


@implementation CCollectionViewCell



- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self != nil) {
        _cellImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CellWidth, CellHeight)];
        _cellImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_cellImageView];
        _selectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CellWidth, CellHeight)];
        _selectImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_selectImageView];
    }
    return self;

}







@end
