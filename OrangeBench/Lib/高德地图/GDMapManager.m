//
//  GDMapManager.m
//  OrangeBench
//
//  Created by dajiabao on 2017/10/27.
//  Copyright © 2017年 xiaowei. All rights reserved.
//

#import "GDMapManager.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <MAMapKit/MAMapKit.h>
//高德地图key
#define mapKey  @"4914ea855e8365130f4075a2fb577b1c"

@implementation Address

@end

@interface GDMapManager()<AMapSearchDelegate>

//定位管理
@property (nonatomic,strong)AMapLocationManager *locationManager;
//搜索管理器
@property (nonatomic,strong)AMapSearchAPI *search;
//poi搜索请求
@property (nonatomic,strong)AMapPOIAroundSearchRequest *request;
//地理编码搜索
@property (nonatomic,strong)AMapGeocodeSearchRequest *geo;
//反向地理编码搜索
@property (nonatomic,strong)AMapReGeocodeSearchRequest *regeo;
//当前地址的地名
@property (nonatomic,copy)NSString *currentAddressName;

@end

@implementation GDMapManager

//单例
+(GDMapManager *)share{
    static GDMapManager *manager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager=[[self alloc]init];
        [[AMapServices sharedServices] setEnableHTTPS:YES];
        [AMapServices sharedServices].apiKey =mapKey;
    });
    return manager;
};


//获取定位地址
- (void)getLocation:(void(^)(Address *address)) successBlock fail:(void(^)(int errorCode))failBlock{
    // 带逆地理信息的一次定位（返回坐标和地址信息）
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    //   定位超时时间，最低2s，此处设置为2s
    self.locationManager.locationTimeout =2;
    //   逆地理请求超时时间，最低2s，此处设置为2s
    self.locationManager.reGeocodeTimeout = 2;
    // 带逆地理（返回坐标和地址信息）。将下面代码中的 YES 改成 NO ，则不会返回地址信息。
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        if (error){
            [self openLocationServiceWithBlock:^(bool open) {
                if (open==NO) {
                    //没有定位权限
                    failBlock?failBlock(0):nil;
                }else{
                    failBlock?failBlock(1):nil;
                }
            }];
            return;
        }
        if (regeocode){
            Address *backAddress=[Address mj_objectWithKeyValues:regeocode];
            backAddress.latitudeNum=location.coordinate.latitude;
            backAddress.longitudeNum=location.coordinate.longitude;
            successBlock?successBlock(backAddress):nil;
        }
    }];
};

//是否已经开启定位权限
- (void)openLocationServiceWithBlock:(void(^)(bool open))returnBlock{
    BOOL isOpen = NO;
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        isOpen = YES;
    }
    returnBlock?returnBlock(isOpen):nil;
}

//获取周边位置
- (void)getAroundLocation:(void(^)(int errorCode))failBlock{
    WeakSelf;
    [weakSelf getLocation:^(Address *address) {
        //当前的地名
        weakSelf.currentAddressName=address.formattedAddress;
        //搜索请求
        self.request.location = [AMapGeoPoint locationWithLatitude:address.latitudeNum longitude:address.longitudeNum];
        self.request.keywords = nil;
        self.request.types = @"地名地址信息|体育休闲服务|科教文化服务|公共设施|餐饮服务|购物服务|生活服务|医疗保健服务|住宿服务|风景名胜|政府机构及社会团体|公司企业|道路附属设施|交通设施服务";
        /* 按照距离排序. */
        self.request.sortrule= 0;
        self.request.requireExtension= YES;
        [weakSelf.search AMapPOIAroundSearch:self.request];
        
    } fail:^(int errorCode) {
        failBlock?failBlock(errorCode):nil;
    }];
}

/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    if (response.pois.count == 0){
        return;
    }
    //通过 AMapPOISearchResponse 对象处理搜索结果
    NSMutableArray *nameArray=[NSMutableArray array];
    //添加当前地址
    if (0<self.currentAddressName.length) {
        [nameArray addObject:self.currentAddressName];
    }
    //构建返回地名
    for (AMapPOI *p in response.pois) {
        NSString  *address=[NSString stringWithFormat:@"%@%@%@%@",p.city,p.district,p.address,p.name];
       [nameArray addObject:address];
    }
    //代理返回数据
    if (self.delegate&&[self.delegate respondsToSelector:@selector(gdMapManager:successArray:)]) {
        [self.delegate gdMapManager:self successArray:nameArray];
    }
}

//根据地址名获取经纬度
- (void)backLatiAndLongtiWithAddressName:(NSString *)addressName{
    self.geo.address=addressName;
    [self.search AMapGeocodeSearch:self.geo];
};


/*地理编码搜索回调. */
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response{
    if (response.geocodes.count == 0){
        return;
    }
    //解析response获取地理信息，具体解析见 Demo
    AMapGeocode *geocode=response.geocodes[0];
    if (self.geoDelegate&&[self.geoDelegate respondsToSelector:@selector(gdMapManager:geoSuccessLatitude:geoSuccessLongtitude:)]) {
        [self.geoDelegate gdMapManager:self geoSuccessLatitude:geocode.location.latitude geoSuccessLongtitude:geocode.location.longitude];
    }
}

//根据经纬度获取地址名
- (void)backAddressWithLati:(CGFloat)lati longtitude:(CGFloat)longtitude{
    self.regeo.location = [AMapGeoPoint locationWithLatitude:lati longitude:longtitude];
    self.regeo.requireExtension= YES;
    [self.search AMapReGoecodeSearch:self.regeo];
};

/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    if (response.regeocode != nil){
        if (self.reGeoDelegate&&[self.reGeoDelegate respondsToSelector:@selector(gdMapManager:reGeoSuccess:)]) {
            [self.reGeoDelegate gdMapManager:self reGeoSuccess:response.regeocode.formattedAddress];
        }
    }
}

/*搜索失败回掉. */
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    if ([request isEqualToString:@"AMapPOIAroundSearchRequest"]) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(gdMapManagerFail:)]) {
            [self.delegate gdMapManagerFail:self];
        }
    }else if ([request isEqualToString:@"AMapGeocodeSearchRequest"]){
        if (self.geoDelegate&&[self.geoDelegate respondsToSelector:@selector(gdMapManagerGeoFail:)]) {
            [self.geoDelegate gdMapManagerGeoFail:self];
        }
    }else if ([request isEqualToString:@"AMapReGeocodeSearchRequest"]){
        if (self.reGeoDelegate&&[self.reGeoDelegate respondsToSelector:@selector(gdMapManagerReGeoFail:)]) {
            [self.reGeoDelegate gdMapManagerReGeoFail:self];
        }
    }
}

//指定经纬度是否在圆形内
- (void)isIncirle:(void(^)(BOOL in))inBlock fail:(void(^)(int errorCode))failBlock{
    [self getLocation:^(Address *address) {
        BOOL inCicle= [self inCirle:address.latitudeNum longtitude:address.longitudeNum centerLatitude:address.latitudeNum centerLongtitude:address.longitudeNum radius:500];
        inBlock?inBlock(inCicle):nil;
    } fail:^(int errorCode) {
        failBlock?failBlock(errorCode):nil;
    }];
}

//判断指定坐标是否在圆内
- (BOOL)inCirle:(CGFloat)latitude longtitude:(CGFloat)longtitude centerLatitude:(CGFloat)centerLatitude centerLongtitude:(CGFloat)centerLongtitude radius:(CGFloat)radius{
    //当前位置经纬度
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitude,longtitude);
    //圆形区域
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(centerLatitude,centerLongtitude);
    //当前位置是否在圆形区域
    BOOL isContains = MACircleContainsCoordinate(location, center, radius);
    return isContains;
}

//指定经纬度是否在指定图形内
- (void)isInRect:(void(^)(BOOL in))inBlock fail:(void(^)(int errorCode))failBlock{
    [self getLocation:^(Address *address) {
        BOOL inRect = [self isInRect:address.latitudeNum longtitude:address.longitudeNum];
        inBlock?inBlock(inRect):nil;
    } fail:^(int errorCode) {
        failBlock?failBlock(errorCode):nil;
    }];
};

//指定经纬度是否在指定图形内
- (BOOL)isInRect:(CGFloat)latitude longtitude:(CGFloat)longtitude {
    //当前位置的经纬度
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitude,longtitude);
    //多边形
    NSInteger count = 4;
    CLLocationCoordinate2D *coorArr = malloc(sizeof(CLLocationCoordinate2D) * count);
    coorArr[0] = CLLocationCoordinate2DMake(39.933921, 116.372927);     //平安里地铁站
    coorArr[1] = CLLocationCoordinate2DMake(39.907261, 116.376532);     //西单地铁站
    coorArr[2] = CLLocationCoordinate2DMake(39.900611, 116.418161);     //崇文门地铁站
    coorArr[3] = CLLocationCoordinate2DMake(39.941949, 116.435497);     //东直门地铁站
    //当前经纬度是否在多边形内
    BOOL isIn=MAPolygonContainsCoordinate(location,coorArr, count);
    return isIn;
}

//当前位置是否在指定的城市
- (BOOL)inCity:(Address *)address cityName:(NSString *)city{
    return   [address.city isEqualToString:city];
}

//计算两点之间的距离
- (double)distance:(CGFloat)firstLatitude firstLongtitude:(CGFloat)fLongtitude withSecondLatitude:(CGFloat)secLatitude secondLongtitude:(CGFloat)secLongtitude{
    //1.将两个经纬度点转成投影点
    MAMapPoint point1 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(firstLatitude,fLongtitude));
    MAMapPoint point2 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(secLatitude,secLongtitude));
    //2.计算距离
    CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
    return distance;
};

//懒加载
- (AMapSearchAPI *)search{
    if (!_search) {
        _search=[[AMapSearchAPI alloc]init];
        _search.delegate = self;
    }
    return _search;
}

- (AMapLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager=[[AMapLocationManager alloc]init];
    }
    return _locationManager;
}

- (AMapPOIAroundSearchRequest *)request{
    if (!_request) {
        _request=[[AMapPOIAroundSearchRequest alloc]init];
    }
    return _request;
}

- (AMapGeocodeSearchRequest *)geo{
    if (!_geo) {
        _geo=[[AMapGeocodeSearchRequest alloc]init];
    }
    return _geo;
}

- (AMapReGeocodeSearchRequest *)regeo{
    if (!_regeo) {
        _regeo=[[AMapReGeocodeSearchRequest alloc]init];
    }
    return _regeo;
}

@end
