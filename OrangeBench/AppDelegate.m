//
//  AppDelegate.m
//  OrangeBench
//
//  Created by dajiabao on 2017/10/23.
//  Copyright © 2017年 xiaowei. All rights reserved.
//

#import "AppDelegate.h"
#import "UMessage.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#import <UserNotifications/UserNotifications.h>
#endif
#import "ViewController.h"
#import "TouchIdVC.h"

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //窗口初始化
    self.window=[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    [application setApplicationIconBadgeNumber:0];
    //关闭scrollerView下滑
    if (@available(iOS 11.0, *)) {
        [UIScrollView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    //设置rootVC
    ViewController *root=[[ViewController alloc]init];
    self.window.rootViewController=root;
    //键盘
    [self globeKeybordSet];
    //友盟分享
    [self umengShare];
    //友盟推送
    //[self umpush:launchOptions];
    //窗口设置
    self.window.backgroundColor=[UIColor whiteColor];
    [self.window makeKeyAndVisible];
    //弹出指纹解锁kong z
    [self touchIdScreen];
    //未启动状态下接收推送处理
    NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(userInfo){
        [self pushInbackGroundOrUnLaunch:userInfo];
    }
    
    return YES;
}

/**
 *  全局键盘设置
 */
- (void)globeKeybordSet {
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.shouldResignOnTouchOutside = YES;
    manager.toolbarDoneBarButtonItemText=@"完成";
    manager.shouldToolbarUsesTextFieldTintColor = NO;
    manager.enableAutoToolbar=YES;
    manager.shouldShowToolbarPlaceholder=NO;
    manager.toolbarTintColor=[UIColor darkGrayColor];
    manager.toolbarManageBehaviour =IQAutoToolbarByTag;
    manager.keyboardDistanceFromTextField=60;
}

/**
 *  友盟分享
 */
- (void)umengShare {
    //允许http图片分享
    [UMSocialGlobal shareInstance].isUsingHttpsWhenShareContent = NO;
    //设置友盟appkey
    [[UMSocialManager defaultManager] setUmSocialAppkey:UMENG_APPKEY];
    //微信
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:weChatId appSecret:weChatScreat redirectURL:redirectAddess];
    [[UMSocialManager defaultManager] removePlatformProviderWithPlatformTypes:@[@(UMSocialPlatformType_WechatFavorite)]];
    //qq
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:qqId  appSecret:nil redirectURL:redirectAddess];
    //新浪
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:sinaId  appSecret:sinaScreat redirectURL:redirectAddess];
}

/**
 *  友盟推送
 */
- (void)umpush:(NSDictionary *)launchOptions{
    [UMessage startWithAppkey:UMPUSHKEY launchOptions:launchOptions httpsenable:YES];
    [UMessage registerForRemoteNotifications];
    [UMessage setLogEnabled:YES];
    if (@available(iOS 10.0, *)) {
        //iOS10必须加下面这段代码。
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate=self;
        UNAuthorizationOptions types10=UNAuthorizationOptionBadge|UNAuthorizationOptionAlert|UNAuthorizationOptionSound;
        [center requestAuthorizationWithOptions:types10 completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                //点击允许
            } else {
                //点击不允许
            }
        }];
    }
}

//接收通知（前台或者后台状态下）
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
        //前台，关闭U-Push自带的弹出框
        [UMessage setAutoAlert:NO];
        [self pushInActive:userInfo];
    }else{
        //后台
        [self pushInbackGroundOrUnLaunch:userInfo];
    }
}

//iOS10新增：处理前台收到通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    if (@available(iOS 10.0, *)) {
        NSDictionary * userInfo = notification.request.content.userInfo;
        if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            //应用处于前台时的远程推送接受
            [UMessage setAutoAlert:NO];
            [self pushInActive:userInfo];
        }else{
            //应用处于前台时的本地推送接受
        }
        //当应用处于前台时提示设置，需要哪个可以设置哪一个
        completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
    }
}

//iOS10新增：处理后台点击通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler{
    if (@available(iOS 10.0, *)) {
        NSDictionary * userInfo = response.notification.request.content.userInfo;
        if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            //应用处于后台时的远程推送接受
            [self pushInbackGroundOrUnLaunch:userInfo];
        }else{
            //应用处于后台时的本地推送接受
        }
    }
}

//推送处理(前台状态下)
- (void)pushInActive:(NSDictionary *)userInfo{
    if ([[[userInfo objectForKey:@"aps"] allKeys] containsObject:@"alert"]) {
        //显示内容的处理
        NSString *subTitle;
        id  alert=[[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
        if ([alert isKindOfClass:[NSString class]]) {
            subTitle=alert;
        }else if([alert isKindOfClass:[NSDictionary class]]&&[[alert allKeys]containsObject:@"body"]){
            subTitle=[alert objectForKey:@"body"];
        }
        if (0==subTitle.length) {
            return;
        }
        //跳转与传值处理
        [self jumpVC:userInfo];
   }
}

//推送处理(后台状态和未启动状态下)
- (void)pushInbackGroundOrUnLaunch:(NSDictionary *)userInfo{
    //跳转与传值处理
    [self jumpVC:userInfo];
}

//处理推送跳转相关
- (void)jumpVC:(NSDictionary *)userInfo{
    [UMessage didReceiveRemoteNotification:userInfo];
    UIViewController *pushViewController=[[ToolsManager share] getTopViewController:KeyWindow.rootViewController];
    if (pushViewController!=nil) {
        NSString *type=@"";
        NSString *content=@"";
        if ([[userInfo allKeys] containsObject:@"type"]) {
            type=[userInfo valueForKey:@"type"];
        }
        if ([[userInfo allKeys] containsObject:@"content"]) {
            content=[userInfo valueForKey:@"content"];
        }
        if (0==content.length||0==type.length) {
            return;
        }
        //根据不同的type做相应的跳转， content：需要传递的值
    }
}


//第三方应用调用本app（ios2-iOS9）
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return  [self setApplicationOpenUrl:url];
}


//第三方应用调用本app（ios4-iOS9）
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return  [self setApplicationOpenUrl:url];
}


//第三方应用调用本app(ios9以后)
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options{
    return  [self setApplicationOpenUrl:url];
}

- (BOOL)setApplicationOpenUrl:(NSURL *)url{
    //UM
    BOOL result=[[UMSocialManager defaultManager] handleOpenURL:url];
    if (result) {
        return result;
    }
    //WXApi
    result=[WXApi handleOpenURL:url delegate:[ToolsManager share]];
    if (result) {
        return result;
    }
    //Alipay
    result=[self aliPayCallbackWithOpenUrl:url];
    if (result) {
        return result;
    }
    return YES;
}

//支付宝
- (BOOL)aliPayCallbackWithOpenUrl:(NSURL *)url{
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [[ToolsManager share] alipayStatus:resultDic];
        }];
        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            [[ToolsManager share] alipayStatus:resultDic];
        }];
        return YES;
    }
    return NO;
}

//3dtouch操作
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler{
    UIViewController *pushViewController=[[ToolsManager share] getTopViewController:KeyWindow.rootViewController];
    if (pushViewController!=nil) {
        if ([shortcutItem.type isEqualToString:@"firstShortcutItem"]){
            NSLog(@"firstShortcutItem");
        }else if ([shortcutItem.type isEqualToString:@"secondShortcutItem"]){
            NSLog(@"secondShortcutItem");
        }else if ([shortcutItem.type isEqualToString:@"thirdShortcutItem"]){
            NSLog(@"thirdShortcutItem");
        }
    }
    completionHandler?completionHandler(YES):nil;
}

//当应用程序将要入非活动状态执行，在此期间，应用程序不接收消息或事件
- (void)applicationWillResignActive:(UIApplication *)application {
    
}

//当程序被推送到后台的时候调用
- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

//当程序从后台将要重新回到前台时候调用
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
    [self touchIdScreen];
}

//当应用程序进入活动状态执行
- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

//当程序将要退出时被调用
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//指纹锁屏
- (void)touchIdScreen{
    if ([UserDefaults boolForKey:@"touchIdSuccess"]) {
        TouchIdVC *root=[[TouchIdVC alloc]init];
        root.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [KeyWindow.rootViewController presentViewController:root animated:NO completion:nil];
    }
}


@end
