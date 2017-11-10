//
//  MTTouchIdTool.h
//
//  Created by dajiabao on 2017/10/23.
//  Copyright © 2017年 xiaowei. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <LocalAuthentication/LocalAuthentication.h>


@interface MTTouchIdTool : NSObject

/**
 *  TouchIdValidationFailureBack
 *
 *  @param result LAError枚举
 */
typedef void(^TouchIdValidationFailureBack)(LAError result);

/**
 *  单例
 *
 */
+ (instancetype) sharedInstance;

/**
 *  TouchId 验证
 *
 *  @param localizedReason TouchId信息
 *  @param title           验证错误按钮title
 *  @param backSucces      成功返回Block
 *  @param backFailure     失败返回Block
 */
- (void)evaluatePolicy:(NSString *)localizedReason
         fallbackTitle:(NSString *)title
          SuccesResult:(void(^)(void))backSucces
         FailureResult:(TouchIdValidationFailureBack)backFailure;

@end
