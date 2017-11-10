//
//  ViewController.m
//  OrangeBench
//
//  Created by dajiabao on 2017/10/23.
//  Copyright © 2017年 xiaowei. All rights reserved.
//

#import "ViewController.h"
#import "CWStarRateView.h"
#import "GDMapManager.h"
#import "TestViewController.h"

@interface ViewController ()<CWStarRateViewDelegate,GDMapManagerDelegate,GDGeoSearchDelegate,GDReGeoSearchDelegate>

@property (nonatomic,strong)NSMutableArray *array;

@end

@implementation ViewController

//初始化
-(instancetype)init{
    if (self=[super init]) {
        //标签栏
        self.menuHeight=44;
        self.menuBGColor=[UIColor whiteColor];
        self.menuViewStyle=WMMenuViewStyleLine;
        self.progressViewIsNaughty=YES;
        self.automaticallyCalculatesItemWidths=YES;
        self.titleColorSelected=[UIColor colorWithHexString:@"#0096ff"];
        self.titleColorNormal=[UIColor colorWithHexString:@"#323232"];
        self.progressHeight=5;
        self.titleSizeNormal=15;
        self.titleSizeSelected=15;
        self.itemMargin=15;
        self.viewFrame=CGRectMake(0, STATUSBARHEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-STATUSBARHEIGHT);
    }
    return self;
}


//WMPageController 代理（有多少分类）
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController * _Nonnull)pageController{
    return self.array.count;
};


- (__kindof UIViewController * _Nonnull)pageController:(WMPageController * _Nonnull)pageController viewControllerAtIndex:(NSInteger)index{
    //上滑数值增加，下滑数值减少
    TestViewController *content=[[TestViewController alloc]init];
    return content;
};


- (NSString * _Nonnull)pageController:(WMPageController * _Nonnull)pageController titleAtIndex:(NSInteger)index{
    return self.array[index];
};


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UIButton *wechat=[[UIButton alloc]initWithFrame:CGRectMake(10, NAVIBARHEIGHT,100, 40)];
//    [wechat setTitle:@"分享" forState:0];
//    [wechat setTitleColor:[UIColor redColor] forState:0];
//    [wechat.titleLabel setFont:font18];
//    [wechat addTarget:self action:@selector(shareContent:)];
//    [self.view addSubview:wechat];
//
//    UIButton *wechatlogin=[[UIButton alloc]initWithFrame:CGRectMake(10, NAVIBARHEIGHT+40, 100, 40)];
//    [wechatlogin setTitle:@"微信登录" forState:0];
//    [wechatlogin setTitleColor:[UIColor redColor] forState:0];
//    [wechatlogin.titleLabel setFont:font18];
//    [wechatlogin addTarget:self action:@selector(thirdl:) forControlEvents:UIControlEventTouchUpInside];
//    wechatlogin.tag=101;
//    [self.view addSubview:wechatlogin];
//
//    UIButton *qqLogin=[[UIButton alloc]initWithFrame:CGRectMake(10, NAVIBARHEIGHT+80, 100, 40)];
//    [qqLogin setTitle:@"qq登录" forState:0];
//    [qqLogin setTitleColor:[UIColor redColor] forState:0];
//    [qqLogin.titleLabel setFont:font18];
//    qqLogin.tag=102;
//    [qqLogin addTarget:self action:@selector(thirdl:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:qqLogin];
//
//    UIButton *sinaLogin=[[UIButton alloc]initWithFrame:CGRectMake(10, NAVIBARHEIGHT+120,100, 40)];
//    [sinaLogin setTitle:@"新浪登录" forState:0];
//    [sinaLogin setTitleColor:[UIColor redColor] forState:0];
//    [sinaLogin.titleLabel setFont:font18];
//    sinaLogin.tag=103;
//    [sinaLogin addTarget:self action:@selector(thirdl:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:sinaLogin];
//
//
//    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(sinaLogin.frame), 100, 40)];
//    label.text=@"指纹锁屏";
//    label.font=font16;
//    label.textColor=[UIColor darkGrayColor];
//    [self.view addSubview:label];
//
//    UISwitch *touchSwitch=[[UISwitch alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-70, CGRectGetMinY(label.frame), 100, 40)];
//    [touchSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
//    if ([UserDefaults boolForKey:@"touchIdSuccess"]) {
//        NSLog(@"已有指纹");
//        [touchSwitch setOn:YES];
//    }else{
//        NSLog(@"没有指纹");
//        [touchSwitch setOn:NO];
//    }
//    [self.view addSubview:touchSwitch];
//
//    CWStarRateView *starView=[[CWStarRateView alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(touchSwitch.frame)+40, SCREEN_WIDTH-40, 20) numberOfStars:5];
//    //得分值
//    starView.scorePercent=1;
//    //是否允许半分值
//    starView.allowIncompleteStar=NO;
//    //是否有动画
//    starView.hasAnimation=YES;
//    //代理
//    starView.delegate=self;
//    [self.view addSubview:starView];
//
//    //当前定位
//    UILabel *dingweiLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(starView.frame), SCREEN_WIDTH-40, 100)];
//    dingweiLabel.textColor=[UIColor darkGrayColor];
//    dingweiLabel.font=font16;
//    dingweiLabel.numberOfLines=0;
//    [self.view addSubview:dingweiLabel];
//    //获取定位
//    GDMapManager *mapManager=[GDMapManager share];
//    mapManager.delegate=self;
    //定位
//    [mapManager getLocation:^(Address *address) {
//        dingweiLabel.text=[NSString stringWithFormat:@"当前地址：%@",address.formattedAddress];
//    } fail:^(int errorCode) {
//        if (errorCode==0) {
//            dingweiLabel.text=@"没开启定位权限";
//        }else{
//            dingweiLabel.text=@"定位出错";
//        }
//    }];
    //获取周边地址
//    [mapManager getAroundLocation:^(int errorCode) {
//        if (errorCode==0) {
//            dingweiLabel.text=@"没开启定位权限";
//        }else{
//            dingweiLabel.text=@"定位出错";
//        }
//    }];
    //经纬度是否在圆内
//    [mapManager isIncirle:^(BOOL in) {
//        if (in) {
//            NSLog(@"在区域内");
//        }else{
//            NSLog(@"不在区域内");
//        }
//    } fail:^(int errorCode) {
//
//    }];
    //经纬度是否在多边形内
//    [mapManager isInRect:^(BOOL in) {
//        if (in) {
//            NSLog(@"在区域内");
//        }else{
//            NSLog(@"不在区域内");
//        }
//    } fail:^(int errorCode) {
//
//    }];
    //当前位置是否在上海市
//    [mapManager getLocation:^(Address *address) {
//        if ([mapManager inCity:address cityName:@"北京市"]) {
//            NSLog(@"当前在北京市");
//        }else{
//            NSLog(@"不在北京市")
//        } ;
//    } fail:^(int errorCode) {
//
//    }];
//    mapManager.geoDelegate=self;
//    [mapManager backLatiAndLongtiWithAddressName:@"虹口区花园路"];
//    mapManager.reGeoDelegate=self;
//    [mapManager backAddressWithLati:31.270736 longtitude:121.476314];
}


-(void)switchAction:(UISwitch *)switchButton{
    if (switchButton.isOn) {
        [[MTTouchIdTool sharedInstance]evaluatePolicy:@"通过Home键验证已有手机指纹" fallbackTitle:@"输入密码" SuccesResult:^{
            [UserDefaults setBool:YES forKey:@"touchIdSuccess"];
            [UserDefaults synchronize];
            [switchButton setOn:YES];
        } FailureResult:^(LAError result) {
            [switchButton setOn:NO];
        }];
    }else{
        [[MTTouchIdTool sharedInstance]evaluatePolicy:@"通过Home键验证已有手机指纹" fallbackTitle:@"输入密码" SuccesResult:^{
            [UserDefaults setBool:NO forKey:@"touchIdSuccess"];
            [UserDefaults synchronize];
            [switchButton setOn:NO];
        } FailureResult:^(LAError result) {
            [switchButton setOn:YES];
        }];
    }
}

- (void)shareContent:(UIButton *)sender{
    [[ToolsManager share] shareImageUrl:@"http://pic130.nipic.com/file/20170523/1409515_003144207000_2.jpg" shareUrl:@"http://www.baidu.com" title:@"测试主标题" subTitle:@"测试副标题" shareType:0];
}

- (void)thirdl:(UIButton *)sender{
    int type=(int)(sender.tag-101);
    [[ToolsManager share] thirdLogin:type successBlock:^(NSDictionary *dic) {
        [[ToolsManager share] toastMessage:[NSString stringWithFormat:@"%@",dic]];
    }];
}

//CWStarRateViewDelegate
- (void)starRateView:(CWStarRateView *)starRateView scroePercentDidChange:(CGFloat)newScorePercent{
    //NSString *fenshu=[NSString stringWithFormat:@"%.1f",newScorePercent*5];
};

//GDMapManagerDelegate
- (void)gdMapManager:(GDMapManager *)manager successArray:(NSMutableArray *)backNameArray{
    if (0<backNameArray.count) {
        [backNameArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(obj);
        }];
    }
}

- (void)gdMapManager:(GDMapManager *)manager geoSuccessLatitude:(CGFloat)lati geoSuccessLongtitude:(CGFloat)longti{
    NSLog(@"纬度：%f",lati);
    NSLog(@"经度：%f",longti);
};

- (void)gdMapManagerGeoFail:(GDMapManager *)manager{
    
};

- (void)gdMapManager:(GDMapManager *)manager reGeoSuccess:(NSString *)address{
    NSLog(@"反向地址是：%@",address);
};

- (void)gdMapManagerReGeoFail:(GDMapManager *)manager{
    NSLog(@"反向编码错误");
};

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)array{
    if (!_array) {
        _array=[NSMutableArray array];
        [_array addObject:@"第一页"];
        [_array addObject:@"第二页"];
        [_array addObject:@"第三页"];
    }
    return _array;
}

@end
