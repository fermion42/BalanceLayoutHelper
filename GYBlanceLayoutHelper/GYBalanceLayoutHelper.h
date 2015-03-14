//
//  BalanceView.h
//  BalanceViewDemo
//
//  Created by Yang Han on 15/3/14.
//  Copyright (c) 2015年 Yang Han. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BalanceItem <NSObject>

- (CGSize)size;

@end

typedef void (^GYBalanceLayoutHelperCallback)(NSArray *itemFrames, CGSize contentSize);

@interface GYBalanceLayoutHelper : NSObject

+ (void)       layoutItems:(NSArray *)items
    withPreferredRowHeight:(CGFloat)height
              andviewWidth:(CGFloat)width
                  callback:(GYBalanceLayoutHelperCallback)block;

@end
