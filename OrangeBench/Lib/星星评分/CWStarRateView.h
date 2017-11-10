//
//  CWStarRateView.h
//  StarRateDemo
//
//  Created by manasoft on 15/9/17.
//  Copyright (c) 2015年 manasoft. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CWStarRateView;

@protocol CWStarRateViewDelegate <NSObject>

@optional

- (void)starRateView:(CWStarRateView *)starRateView scroePercentDidChange:(CGFloat)newScorePercent;

@end

@interface CWStarRateView : UIView{
    NSString * tagNumber;
}

//得分值，范围为0--1，默认为1
@property (nonatomic, assign) CGFloat scorePercent;
//是否允许动画，默认为NO
@property (nonatomic, assign) BOOL hasAnimation;
//评分时是否允许不是整星，默认为NO
@property (nonatomic, assign) BOOL allowIncompleteStar;
//得分
@property (nonatomic, assign) CGFloat score;
//代理
@property (nonatomic, weak) id<CWStarRateViewDelegate>delegate;
//初始化方法
- (instancetype)initWithFrame:(CGRect)frame numberOfStars:(NSInteger)numberOfStars;

@end
