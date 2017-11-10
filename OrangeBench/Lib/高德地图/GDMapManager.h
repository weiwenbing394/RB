//
//  GDMapManager.h
//  OrangeBench
//
//  Created by dajiabao on 2017/10/27.
//  Copyright © 2017年 xiaowei. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GDMapManager;

@interface Address : NSObject
//全部地址
@property(nonatomic,copy) NSString *formattedAddress;
//国家
@property(nonatomic,copy) NSString *country;
//省
@property(nonatomic,copy) NSString *province;
//市
@property(nonatomic,copy) NSString *city;
//区
@property(nonatomic,copy) NSString *district;
//区号
@property(nonatomic,copy) NSString *citycode;
//邮政编码
@property(nonatomic,copy) NSString *adcode;
//街道
@property(nonatomic,copy) NSString *street;
//街道号牌
@property(nonatomic,copy) NSString *number;
//poi名字
@property(nonatomic,copy) NSString *POIName;
//aoi名字
@property(nonatomic,copy) NSString *AOIName;
///纬度
@property (nonatomic, assign) CGFloat latitudeNum;
///经度
@property (nonatomic, assign) CGFloat longitudeNum;

@end

//周边地址代理
@protocol GDMapManagerDelegate <NSObject>

- (void)gdMapManager:(GDMapManager *)manager successArray:(NSMutableArray *)backNameArray;

- (void)gdMapManagerFail:(GDMapManager *)manager;

@end

//地理编码代理
@protocol GDGeoSearchDelegate <NSObject>

- (void)gdMapManager:(GDMapManager *)manager geoSuccessLatitude:(CGFloat)lati geoSuccessLongtitude:(CGFloat)longti;

- (void)gdMapManagerGeoFail:(GDMapManager *)manager;

@end

//反向地理编码代理
@protocol GDReGeoSearchDelegate <NSObject>

- (void)gdMapManager:(GDMapManager *)manager reGeoSuccess:(NSString *)address;

- (void)gdMapManagerReGeoFail:(GDMapManager *)manager;

@end

@interface GDMapManager : NSObject

//周边地址代理
@property (nonatomic, weak) id<GDMapManagerDelegate>delegate;

//地理编码代理
@property (nonatomic, weak) id<GDGeoSearchDelegate>geoDelegate;

//反向地理编码代理
@property (nonatomic, weak) id<GDReGeoSearchDelegate>reGeoDelegate;

//单例
+(GDMapManager *)share;

//获取定位地址
- (void)getLocation:(void(^)(Address *address)) successBlock fail:(void(^)(int errorCode))failBlock;

//获取周边位置
- (void)getAroundLocation:(void(^)(int errorCode))failBlock;

//根据地址名获取经纬度
- (void)backLatiAndLongtiWithAddressName:(NSString *)addressName;

//根据经纬度获取地址名
- (void)backAddressWithLati:(CGFloat)lati longtitude:(CGFloat)longtitude;

//指定经纬度是否在圆形内
- (void)isIncirle:(void(^)(BOOL in))inBlock fail:(void(^)(int errorCode))failBlock;

//指定经纬度是否在指定图形内
- (void)isInRect:(void(^)(BOOL in))inBlock fail:(void(^)(int errorCode))failBlock;

//当前位置是否在指定的城市
- (BOOL)inCity:(Address *)address cityName:(NSString *)city;

//计算两点之间的距离
- (double)distance:(CGFloat)firstLatitude firstLongtitude:(CGFloat)fLongtitude withSecondLatitude:(CGFloat)secLatitude secondLongtitude:(CGFloat)secLongtitude;

@end




