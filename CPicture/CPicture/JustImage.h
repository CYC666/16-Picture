//
//  JustImage.h
//  CPicture
//
//  Created by mac on 16/10/27.
//  Copyright © 2016年 CYC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JustImage : NSObject


@property (strong, nonatomic) NSMutableArray *thumbImageArray;
@property (strong, nonatomic) NSMutableArray *fullImageArray;

+ (instancetype)shareImage;

@end
