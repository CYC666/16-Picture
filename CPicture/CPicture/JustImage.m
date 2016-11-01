//
//  JustImage.m
//  CPicture
//
//  Created by mac on 16/10/27.
//  Copyright © 2016年 CYC. All rights reserved.
//

#import "JustImage.h"

static JustImage *instence = nil;

@implementation JustImage

+ (instancetype)shareImage {

    if (instence == nil) {
        instence = [[JustImage alloc] init];
    }
    
    return instence;

}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {

    if (instence == nil) {
        instence = [super allocWithZone:zone];
    }
    return instence;

}

- (instancetype)copy {

    return self;

}

@end
