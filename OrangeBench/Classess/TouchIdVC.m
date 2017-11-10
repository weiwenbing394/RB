//
//  TouchIdVC.m
//  OrangeBench
//
//  Created by dajiabao on 2017/10/25.
//  Copyright © 2017年 xiaowei. All rights reserved.
//

#import "TouchIdVC.h"
#import "ViewController.h"

@interface TouchIdVC ()

@end

@implementation TouchIdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2.0-50, 80, 100, 100)];
    [imageView sd_setImageWithURL:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1508923644000&di=5fa7bb19a850da6d62ca585126406810&imgtype=0&src=http%3A%2F%2Fimg4q.duitang.com%2Fuploads%2Fitem%2F201502%2F27%2F20150227115212_xCCzS.jpeg"]];
    imageView.layer.cornerRadius=5;
    imageView.clipsToBounds=YES;
    [self.view addSubview:imageView];
    
    UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2.0-60, self.view.centerY-90, 120, 120)];
    button.tag=100;
    [button setImage:[UIImage imageNamed:@"timg"] forState:0];
    [button setImage:[UIImage imageNamed:@"timg"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(touchid:)];
    [self.view addSubview:button];
    
    UILabel *tishi=[[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(button.frame)+20, SCREEN_WIDTH, 20)];
    [tishi setFont:font20];
    tishi.textAlignment=NSTextAlignmentCenter;
    tishi.textColor=[UIColor darkGrayColor];
    tishi.text=@"点击进行指纹解锁";
    [self.view addSubview:tishi];
    
}

//指纹解锁
- (void)touchid:(UIButton *)sender{
    [[MTTouchIdTool sharedInstance]evaluatePolicy:@"通过Home键验证已有手机指纹" fallbackTitle:@"输入密码" SuccesResult:^{
        [self dismissViewControllerAnimated:NO completion:nil];
    } FailureResult:^(LAError result) {
        switch (result) {
            case LAErrorSystemCancel:{
                NSLog(@"切换到其他APP");
                break;
            }
            case LAErrorUserCancel:{
                NSLog(@"用户取消验证Touch ID");
                break;
            }
            case LAErrorTouchIDNotEnrolled:{
                NSLog(@"TouchID is not enrolled");
                break;
            }
            case LAErrorUserFallback:{
                NSLog(@"用户选择输入密码");
                break;
            }
            default:{
                NSLog(@"其他情况");
                break;
            }
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UIButton *btn=[self.view viewWithTag:100];
    [self touchid:btn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
