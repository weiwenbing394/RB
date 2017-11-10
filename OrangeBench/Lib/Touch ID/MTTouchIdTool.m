//
//  MTTouchIdTool.m
//  MTTouchIdDemo
//
//  Created by dajiabao on 2017/10/23.
//  Copyright © 2017年 xiaowei. All rights reserved.
//

#import "MTTouchIdTool.h"

@implementation MTTouchIdTool

+ (instancetype)sharedInstance{
    static MTTouchIdTool* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MTTouchIdTool alloc] init];
    });
    return instance;
}

- (void)evaluatePolicy:(NSString *)localizedReason
         fallbackTitle:(NSString *)title
          SuccesResult:(void(^)(void))backSucces
         FailureResult:(TouchIdValidationFailureBack)backFailure{
    //初始化上下文对象
    LAContext* context = [[LAContext alloc] init];
    //错误对象
    NSError* error = nil;
    //首先使用canEvaluatePolicy 判断设备支持状态
   if ([context canEvaluatePolicy: LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]){
       //支持指纹验证
       [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
               localizedReason:localizedReason
                         reply:
        ^(BOOL succes, NSError *error) {
            if (succes) {
                //验证成功，返回主线程处理
                dispatch_async(dispatch_get_main_queue(), ^{
                    backSucces?backSucces():nil;
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    backFailure(error.code);
                });
            }
        }];
   }else{
       dispatch_async(dispatch_get_main_queue(), ^{
           backFailure(error.code);
       });
  
   }
}

@end
