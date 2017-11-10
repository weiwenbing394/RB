//
//  ToolsManager.m
//  DaJiaBaoMall
//
//  Created by 大家保 on 2017/5/17.
//  Copyright © 2017年 大家保. All rights reserved.
//

#import "ToolsManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import "NSDate+DateTools.h"


@implementation ToolsManager

//单例
+ (ToolsManager *)share{
    static ToolsManager *tool=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool=[[ToolsManager alloc]init];
    });
    return tool;
};

//字符串转图片
- (UIImage *)imageFromString:(NSString *)string{
    // NSString --> NSData
    NSData *data=[[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    // NSData --> UIImage
    UIImage *image = [UIImage imageWithData:data];
    return image;
}

//图片转字符串
- (NSString *)imageToString:(UIImage *)image{
    // UIImage --> NSData
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    // NSData --> NSString
    NSString *imageDataString = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    return imageDataString;
}

//将图片转换为jpg再转换成字符串
- (NSString *)imageToJpgString:(UIImage *)image andScale:(CGFloat)imageScale{
    // 图片经过等比压缩后得到的二进制文件
    NSData *imageData = UIImageJPEGRepresentation([self fixOrientation:image], imageScale ?: 1.f);
    // NSData --> NSString
    NSString *imageDataString = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    return imageDataString;
};

- (UIImage *)fixOrientation:(UIImage *)aImage {
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


//  去除字符串空格
- (NSString *)clearSpace:(NSString *)str{
    return 0==str.length?@"":[[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

//计算剩余天数
- (NSString *)dateTimeDifferenceWithStartTime:(long long)lostTime{
    long long value= lostTime;
    long long second = value % 60;//秒
    long long minute = value / 60 % 60;
    long long house =value / 3600 % 24;
    long long day = value / ( 24 * 3600 );
    NSString *str;
    if (day != 0) {
        str = [NSString stringWithFormat:@"%lld天%lld小时%lld分%lld秒",day,house,minute,second];
    }else if (day==0 && house != 0) {
        str = [NSString stringWithFormat:@"%lld小时%lld分%lld秒",house,minute,second];
    }else if (day== 0 && house== 0 && minute!=0) {
        str = [NSString stringWithFormat:@"%lld分%lld秒",minute,second];
    }else{
        str = [NSString stringWithFormat:@"%lld秒",second];
    }
    return str;
}

//将毫秒数转换为字符串
- (NSString *)timeToString:(long long) miaoshu formatterType:(NSString *)format{
    NSDate *date =[[NSDate alloc]initWithTimeIntervalSince1970:miaoshu/1000.0];
    NSTimeZone *zone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:format];
    return  [dateFormat stringFromDate:localeDate];
    
}

//计算当前天的后一天
- (NSDate *)addOneDay:(NSDate *)currentDate{
    NSDate *nextDate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:currentDate];
    return nextDate;
};

//计算当前天的后一天
- (NSDate *)decolearOneDay:(NSDate *)currentDate{
    NSDate *lastDate = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:currentDate];
    return lastDate;
};


//计算两个时间是否大于一天
- (BOOL)thanNextDay:(NSDate *)oneDate twoDate:(NSDate *)twoDate{
    NSTimeInterval time = [twoDate timeIntervalSinceDate:oneDate];
    if (time>0) {
        return true;
    }else{
        return false;
    }
};

//nsdate转为nsstring
- (NSString *)dateToString:(NSDate *)changeDate andFormat:(NSString *)format{
    //用于格式化NSDate对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设置格式：zzz表示时区
    [dateFormatter setDateFormat:format];
    //NSDate转NSString
    NSString *currentDateString = [dateFormatter stringFromDate:changeDate];
    NSLog(@"%@",currentDateString);
    return currentDateString;
};

//nsstring转为nsdate
- (NSDate *)stringToDate:(NSString *)changeString andFormat:(NSString *)format{
    //需要转换的字符串
    NSString *dateString = changeString;
    //设置转换格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:format];
    //NSString转NSDate
    NSDate *date=[formatter dateFromString:dateString];
    return date;
};

//将nsdate转换为毫秒数
-(long long)getDateTimeTOMilliSeconds:(NSDate *)datetime{
    NSTimeInterval interval = [datetime timeIntervalSince1970];
    long long totalMilliseconds = interval*1000 ;
    return totalMilliseconds;
}

//将毫秒数转换为nsdate
- (NSDate *)changeMillionsToDate:(long long)millons{
    return [[NSDate alloc]initWithTimeIntervalSince1970:millons/1000];
};

//本周的所有日期
- (NSMutableArray *)weekArray:(NSDate*)date{
    
    NSMutableArray *weekArray=[NSMutableArray array];
    NSDate *nowDate;
    if (date==nil) {
        nowDate= [NSDate date];
    }else{
        nowDate=date;
    }
    //获取本周第一天和最后一天
    NSArray *weekFAndLArray=[self getFirstAndLastDayOfThisWeek:nowDate];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *firstDay = [formatter stringFromDate:[weekFAndLArray firstObject]];
    NSString *lastDay = [formatter stringFromDate:[weekFAndLArray lastObject]];
    NSDate   *nextDay=[[weekFAndLArray firstObject] dateByAddingDays:3];
    NSString *nextDayStr=[formatter stringFromDate:nextDay];
    
    [weekArray addObject:firstDay];
    [weekArray addObject:nextDayStr];
    [weekArray addObject:lastDay];
    
    return weekArray;
};

//本月的所有日期
- (NSMutableArray *)monthArray:(NSDate*)date{
    
    NSMutableArray *monthArray=[NSMutableArray array];
    NSDate *currentDay;
    if (date==nil) {
        currentDay= [NSDate date];
    }else{
        currentDay=date;
    }
    //本月第一天和最后一天
    NSArray *monthFLArray=[self getFirstAndLastDayOfThisMonth:currentDay];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //设定周一为周首日
    [calendar setFirstWeekday:2];
    //月中
    NSRange     range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:currentDay];
    NSUInteger   addHalfOfMonth;
    if (range.length%2==0) {
        addHalfOfMonth=range.length/2-1;
    }else{
        addHalfOfMonth=floor(range.length/2.0) ;
    }
    NSDate   *halfMonthDay=[[monthFLArray firstObject] dateByAddingDays:addHalfOfMonth];
    //转换规则
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    [myDateFormatter setDateFormat:@"yyyy-MM-dd"];
    //第一天
    NSString *beginString = [myDateFormatter stringFromDate:[monthFLArray firstObject]];
    //中间一天
    NSString *halfMonthString=[myDateFormatter stringFromDate:halfMonthDay];
    //最后一天
    NSString *endString = [myDateFormatter stringFromDate:[monthFLArray lastObject]];
    //添加到数组
    [monthArray addObject:beginString];
    [monthArray addObject:halfMonthString];
    [monthArray addObject:endString];
    
    return monthArray;
};

//上半年的所有日期
- (NSMutableArray *)halfYearArray:(NSDate*)date{

    NSMutableArray *halfYearArray=[NSMutableArray array];
    //当前日期
    NSDate *currentDay;
    if (date==nil) {
        currentDay= [NSDate date];
    }else{
        currentDay=date;
    }
    //后三个月
    NSDate *afterThreeMonthDay=[currentDay dateByAddingMonths:3];
    //前三个月
    NSDate *beforeThreeMonthDay=[currentDay dateBySubtractingMonths:3];
    
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    [myDateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *before60DayString=[myDateFormatter stringFromDate:beforeThreeMonthDay];
    NSString *currentDayString=[myDateFormatter stringFromDate:currentDay];
    NSString *after60DayString=[myDateFormatter stringFromDate:afterThreeMonthDay];
    
    [halfYearArray addObject:before60DayString];
    [halfYearArray addObject:currentDayString];
    [halfYearArray addObject:after60DayString];
    
    return halfYearArray;
};

//本年所有日期
- (NSMutableArray *)yearArray:(NSDate*)date{
    
    NSMutableArray *yearArray=[NSMutableArray array];
    
    NSDate *currentDay;
    if (date==nil) {
        currentDay= [NSDate date];
    }else{
        currentDay=date;
    }
    
    //获取本年的第一天和最后一天
    NSArray *yearFlArray=[self getFirstAndLastDayOfThisYear:currentDay];
    //本年相聚天数
    NSInteger count=[self getNumberBetweenTwoDate:[yearFlArray firstObject] afterDate:[yearFlArray lastObject]];
    
    NSUInteger   addHalfOfYear;
    if (count%2==0) {
        addHalfOfYear=count/2-1;
    }else{
        addHalfOfYear=floor(count/2.0) ;
    }
    NSDate     *halfYearDay=[[yearFlArray firstObject] dateByAddingDays:addHalfOfYear];
    //转换规则
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    [myDateFormatter setDateFormat:@"yyyy-MM-dd"];
    //第一天
    NSString *beginString = [myDateFormatter stringFromDate:[yearFlArray firstObject]];
    //中间一天
    NSString *halfYearString=[myDateFormatter stringFromDate:halfYearDay];
    //最后一天
    NSString *endString = [myDateFormatter stringFromDate:[yearFlArray lastObject]];
    //添加到数组
    [yearArray addObject:beginString];
    [yearArray addObject:halfYearString];
    [yearArray addObject:endString];
    return yearArray;
};

//获取今天是本周第几天
- (NSInteger)getNowWeekday:(NSDate*)date{
    
    NSDate *currentDay;
    if (date==nil) {
        currentDay= [NSDate date];
    }else{
        currentDay=date;
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday  fromDate:currentDay];
    
    // 获取今天是周几
    NSInteger weekDay = [comp weekday];
    switch (weekDay) {
        case 0:
            return 5;
            break;
        case 1:
            return 6;
            break;
        case 2:
            return 0;
            break;
        case 3:
            return 1;
            break;
        case 4:
            return 2;
            break;
        case 5:
            return 3;
            break;
        case 6:
            return 4;
            break;
        default:
            break;
    }
    return 0;
}

//获取今天是本月第几天
- (NSInteger)getNowMonthday:(NSDate*)date;{
    NSDate *currentDay;
    if (date==nil) {
        currentDay= [NSDate date];
    }else{
        currentDay=date;
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday  fromDate:currentDay];
    // 获取今天是是本月第几天
    NSInteger weekDay = [comp day]-1;
    return weekDay;
}

//获取今天是半年的第几天
- (NSInteger)getNowHalfYearday:(NSDate *)date{
    NSDate *currentDay;
    if (date==nil) {
        currentDay= [NSDate date];
    }else{
        currentDay=date;
    }
    //计算三个月前的日期
    NSDate *beforeThreeMonthDay=[currentDay dateBySubtractingMonths:3];
    
    //计算两者之间差值
    NSTimeInterval time=[currentDay timeIntervalSinceDate:beforeThreeMonthDay];
    
    return ((int)time)/(3600*24);
};

//获取今天是本年的第几天
- (NSInteger)getNowYearday:(NSDate*)date{
    NSDate *currentDay;
    if (date==nil) {
        currentDay= [NSDate date];
    }else{
        currentDay=date;
    }
    
    double interval = 0;
    NSDate *beginDate = nil;

    NSCalendar *calendar = [NSCalendar currentCalendar];
    //设定周一为周首日
    [calendar setFirstWeekday:2];
    [calendar rangeOfUnit:NSCalendarUnitYear startDate:&beginDate interval:&interval forDate:currentDay];
    
    //计算两者之间差值
    NSTimeInterval time=[currentDay timeIntervalSinceDate:beginDate];
    
    return ((int)time)/(3600*24);
};


//获取今年的总天数
- (int)getCurrentAllDays:(NSDate *)date{
    NSDate *currentDay;
    if (date==nil) {
        currentDay= [NSDate date];
    }else{
        currentDay=date;
    }
    
    //获取本年的第一天和最后一天
    NSArray *yearFlArray=[self getFirstAndLastDayOfThisYear:currentDay];
    //本年相聚天数
    NSInteger count=[self getNumberBetweenTwoDate:[yearFlArray firstObject] afterDate:[yearFlArray lastObject]];
    
    return (int)count+1;
};

//获取近6个月的总天数
- (int)getSixMonthDays:(NSDate *)date{
    NSDate *currentDay;
    if (date==nil) {
        currentDay= [NSDate date];
    }else{
        currentDay=date;
    }
    //计算三个月前的日期
    NSDate *beforeThreeMonthDay=[currentDay dateBySubtractingMonths:3];
    //后三个月
    NSDate *afterThreeMonthDay=[currentDay dateByAddingMonths:3];
    //计算两者之间差值
    return (int)[self getNumberBetweenTwoDate:beforeThreeMonthDay afterDate:afterThreeMonthDay]+1;
    
};

//获取本月有多少天
- (int)getCurrentMobthDays:(NSDate *)date{
    NSDate *currentDay;
    if (date==nil) {
        currentDay= [NSDate date];
    }else{
        currentDay=date;
    }
    NSArray *monthFLa=[self getFirstAndLastDayOfThisMonth:currentDay];
    return (int)[self getNumberBetweenTwoDate:[monthFLa firstObject] afterDate:[monthFLa lastObject]]+1;
};

//获取本周周一是今年的第几天
- (int)getCurrntWeekFirstDayInThisYear:(NSDate *)date{
    NSDate *nowDate;
    if (date==nil) {
        nowDate= [NSDate date];
    }else{
        nowDate=date;
    }
    //获取本周周一的日期
    NSArray *weekArray=[self getFirstAndLastDayOfThisWeek:nowDate];
    //获取本年的第一天
    NSArray *yearWeek=[self getFirstAndLastDayOfThisYear:nowDate];
    return (int)[self getNumberBetweenTwoDate:[yearWeek firstObject] afterDate:[weekArray firstObject]];
};

//获取本月第一天是今年的第几天
- (int)getCurrntMonthFirstDayInThisYear:(NSDate *)date{
    NSDate *nowDate;
    if (date==nil) {
        nowDate= [NSDate date];
    }else{
        nowDate=date;
    }
    //获取本月第一天日期
    NSArray *monthArray=[self getFirstAndLastDayOfThisMonth:nowDate];
    //获取本年的第一天
    NSArray *yearWeek=[self getFirstAndLastDayOfThisYear:nowDate];
    return (int)[self getNumberBetweenTwoDate:[yearWeek firstObject] afterDate:[monthArray firstObject]];
};

//获取近6个月的第一天是本年的第几天
- (int)getSixMonthFirstDayInThisYear:(NSDate *)date{
    NSDate *nowDate;
    if (date==nil) {
        nowDate= [NSDate date];
    }else{
        nowDate=date;
    }
    //前三个月的第一天
    NSDate *beforeThreeMonthDay=[nowDate dateBySubtractingMonths:3];
    //获取本年的第一天
    NSArray *yearWeek=[self getFirstAndLastDayOfThisYear:nowDate];
    return (int)[self getNumberBetweenTwoDate:[yearWeek firstObject] afterDate:beforeThreeMonthDay];
};

//获取指定日期到当前前的第一天的天数
- (int)getBetweenNextYearAndCurrentYearFirst:(NSDate *)currentDate nextYearDate:(NSDate *)nextYearDay{
    NSDate *nowDate;
    if (currentDate==nil) {
        nowDate= [NSDate date];
    }else{
        nowDate=currentDate;
    }
    NSArray *yearFLArray=[self getFirstAndLastDayOfThisYear:nowDate];
    int days=(int)[self getNumberBetweenTwoDate:[yearFLArray firstObject] afterDate:nextYearDay];
    return days;
};

//是否大于今年的最后一天
- (BOOL)thanCurrentYearLastDay:(NSDate *)currentDate andNextDay:(NSDate *)nextDate{
    NSDate *nowDate;
    if (currentDate==nil) {
        nowDate= [NSDate date];
    }else{
        nowDate=currentDate;
    }
    NSArray *yearFLArray=[self getFirstAndLastDayOfThisYear:nowDate];
    //今年的最后一天
    NSDate  *yearLastDate=[yearFLArray lastObject];
    return [nextDate isLaterThan:yearLastDate];
};


//获取今年的第一天和最后一天
-(NSArray *)getFirstAndLastDayOfThisYear:(NSDate *)date{
    //通过2月天数的改变，来确定全年天数
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"yyyy"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    dateStr = [dateStr stringByAppendingString:@"-02-14"];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *aDayOfFebruary = [formatter dateFromString:dateStr];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *firstDay;
    [calendar rangeOfUnit:NSCalendarUnitYear startDate:&firstDay interval:nil forDate:date];
    NSDateComponents *lastDateComponents = [calendar components:NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitDay fromDate:firstDay];
    NSUInteger dayNumberOfFebruary = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:aDayOfFebruary].length;
    NSInteger day = [lastDateComponents day];
    [lastDateComponents setDay:day+337+dayNumberOfFebruary-1];
    NSDate *lastDay = [calendar dateFromComponents:lastDateComponents];
    
    return [NSArray arrayWithObjects:firstDay,lastDay, nil];
}

//获取本月的最后一天和第一天
-(NSArray *)getFirstAndLastDayOfThisMonth:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *firstDay;
    [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&firstDay interval:nil forDate:date];
    NSDateComponents *lastDateComponents = [calendar components:NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitDay fromDate:firstDay];
    NSUInteger dayNumberOfMonth = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
    NSInteger day = [lastDateComponents day];
    [lastDateComponents setDay:day+dayNumberOfMonth-1];
    NSDate *lastDay = [calendar dateFromComponents:lastDateComponents];
    return [NSArray arrayWithObjects:firstDay,lastDay, nil];
}

//获得本周的最后一天和第一天
-(NSArray *)getFirstAndLastDayOfThisWeek:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSInteger weekday = [dateComponents weekday];   //第几天(从sunday开始)
    NSInteger firstDiff,lastDiff;
    if (weekday == 1) {
        firstDiff = -6;
        lastDiff = 0;
    }else {
        firstDiff =  - weekday + 2;
        lastDiff = 8 - weekday;
    }
    NSInteger day = [dateComponents day];
    NSDateComponents *firstComponents = [calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    [firstComponents setDay:day+firstDiff];
    NSDate *firstDay = [calendar dateFromComponents:firstComponents];
    
    NSDateComponents *lastComponents =[calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    [lastComponents setDay:day+lastDiff];
    NSDate *lastDay = [calendar dateFromComponents:lastComponents];
    return [NSArray arrayWithObjects:firstDay,lastDay, nil];
}

//获取两个日期相隔天数
-(NSInteger)getNumberBetweenTwoDate:(NSDate *)beforDate afterDate:(NSDate *)toDate{
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setFirstWeekday:2];
    NSDateComponents *dayComponents = [gregorian components:NSCalendarUnitDay fromDate:beforDate toDate:toDate options:0];
    return dayComponents.day;
}

//用*代替电话数字
- (NSString *)placeNumber:(NSString *)str{
    if (7>str.length) {
        return str;
    }
    NSMutableString *cardIdStr=[[NSMutableString alloc]initWithString:str];
    for (int i=3; i<cardIdStr.length-4; i++) {
        [cardIdStr replaceCharactersInRange:NSMakeRange(i, 1) withString:@"*"];
    }
    return cardIdStr;
}


//提示
- (void)toastMessage:(NSString *)toastMessage{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"提醒" message:toastMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel=[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:cancel];
    [KeyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}


//判断和获取相机权限
- (void)CameraPermissionSuceess:(void (^)(void)) successBlock Failed:(void (^)(void)) faild{
    //判断相机权限
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self toastMessage:@"请在iphone的“设置-隐私-相机”选项中，允许计时保使用您的相机"];
            faild?faild():nil;
        });
    }else if(authStatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock?successBlock():nil;
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self toastMessage:@"请在iphone的“设置-隐私-相机”选项中，允许计时保使用您的相机"];
                    faild?faild():nil;
                });
            }
        }];
    }else if(authStatus == AVAuthorizationStatusAuthorized){
        dispatch_async(dispatch_get_main_queue(), ^{
            successBlock?successBlock():nil;
        });
    }
};


//判断相册使用权限
- (void)PhotoLibararyPermissionSuceess:(void (^)(void)) successBlock Failed:(void (^)(void)) faild{
    WeakSelf;
    PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf toastMessage:@"请在iphone的“设置-隐私-照片”选项中，允许计时保访问您的手机相册"];
            faild?faild():nil;
        });
    }else if(author == ALAuthorizationStatusNotDetermined){
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf toastMessage:@"请在iphone的“设置-隐私-照片”选项中，允许计时保访问您的手机相册"];
                    faild?faild():nil;
                });
            }else if (status == PHAuthorizationStatusAuthorized){
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock?successBlock():nil;
                });
            }
        }];
    }else if(author == ALAuthorizationStatusAuthorized){
        successBlock?successBlock():nil;
    }
};


//获取当前的uiviewController
- (UIViewController *)getTopViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        return [self getTopViewController:[(UITabBarController *)viewController selectedViewController]];
    } else if ([viewController isKindOfClass:[UINavigationController class]]) {
        return [self getTopViewController:[(UINavigationController *)viewController topViewController]];
    } else if (viewController.presentedViewController) {
        return [self getTopViewController:viewController.presentedViewController];
    } else {
        return viewController;
    }
    
}

//微信，qq，微博登录(0:微信，1:qq，2:微博)
- (void)thirdLogin:(int)type successBlock:(void (^) (NSDictionary *dic))successBlock{
    UMSocialPlatformType platformType;
    if (type==0) {
        platformType=UMSocialPlatformType_WechatSession;
    }else if (type==1){
        platformType=UMSocialPlatformType_QQ;
    }else if (type==2){
        platformType=UMSocialPlatformType_Sina;
    }else{
        NSLog(@"类型错误");
        return;
    }
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:platformType currentViewController:nil completion:^(id result, NSError *error) {
        if (error) {
            NSLog(@"错误原因%@",error.description);
        } else {
            UMSocialUserInfoResponse *resp = result;
            // 授权数据
            NSLog(@" uid: %@", resp.uid);
            NSLog(@" openid: %@", resp.openid);
            NSLog(@" accessToken: %@", resp.accessToken);
            NSLog(@" refreshToken: %@", resp.refreshToken);
            NSLog(@" expiration: %@", resp.expiration);
            
            // 用户数据
            NSLog(@" name: %@", resp.name);
            NSLog(@" iconurl: %@", resp.iconurl);
            NSLog(@" gender: %@", resp.unionGender);
            
            //组织返回数据
            NSDictionary *backDic=@{@"uid":resp.uid,@"name":resp.name,@"iconurl":resp.iconurl,@"gender":resp.unionGender};
            successBlock?successBlock(backDic):nil;
        }
    }];
};

//取消第三方授权
- (void)cancelThirdLogin:(int)type successBlock:(void(^)(void))successBlock failBlock:(void (^)(void))failBlock{
    UMSocialPlatformType platformType;
    if (type==0) {
        platformType=UMSocialPlatformType_WechatSession;
    }else if (type==1){
        platformType=UMSocialPlatformType_QQ;
    }else if (type==2){
        platformType=UMSocialPlatformType_Sina;
    }else{
        failBlock?failBlock():nil;
        return;
    }
    [[UMSocialManager defaultManager] cancelAuthWithPlatform:platformType completion:^(id result, NSError *error) {
        if (error) {
            failBlock?failBlock():nil;
        }else{
            successBlock?successBlock():nil;
        }
     }];
};

//是否装了第三方app(微信，微博，qq)
- (BOOL)isHaveThirdApps:(int)type{
    UMSocialPlatformType platformType;
    if (type==0) {
        platformType=UMSocialPlatformType_WechatSession;
    }else if (type==1){
        platformType=UMSocialPlatformType_QQ;
    }else if (type==2){
        platformType=UMSocialPlatformType_Sina;
    }else{
        NSLog(@"类型错误");
        return nil;
    }
    return [[UMSocialManager defaultManager] isInstall:platformType];
};


#pragma mark 分享
- (void)shareImageUrl:(NSString *)shareImageUrl  shareUrl:(NSString *)shareUrl  title:(NSString *)shareTile subTitle:(NSString *)subTitle shareType:(NSInteger )type{
    WeakSelf;
    //排序
    [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_QQ),@(UMSocialPlatformType_Qzone),@(UMSocialPlatformType_Sina)]];
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        [weakSelf shareWebPageToPlatformType:platformType ImageUrl:shareImageUrl shareUrl:shareUrl title:shareTile subTitle:subTitle shareType:type] ;
    }];
}

//分享
- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType ImageUrl:(NSString *)shareImageUrl  shareUrl:(NSString *)shareUrl  title:(NSString *)shareTile subTitle:(NSString *)subTitle shareType:(NSInteger )type{
    //创建分享对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    if (type==0) {
        //分享网页
        NSString *thumbURL=(0==shareImageUrl.length?@"":shareImageUrl);
        UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:(0==shareTile.length?@" ":shareTile) descr:(0==subTitle.length?@" ":subTitle) thumImage:thumbURL];
        shareObject.webpageUrl = (0==shareUrl.length?@"":shareUrl);
        messageObject.shareObject = shareObject;
    }else if (type==1){
        //分享图片(url)
        UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
        NSString *thumbURL=(0==shareImageUrl.length?@"":shareImageUrl);
        [shareObject setShareImage:thumbURL];
        messageObject.shareObject = shareObject;
    }else if (type==2){
        //分享文本
        messageObject.text = shareTile;
    }else if (type==3){
        //分享图片(base64)
        UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
        [shareObject setShareImage:[[ToolsManager share] imageFromString:shareImageUrl]];
        messageObject.shareObject = shareObject;
    }else if (type==4) {
        //分享网页(本地图片，参数为本地地址名)
        UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:(0==shareTile.length?@" ":shareTile) descr:(0==subTitle.length?@" ":subTitle) thumImage:[UIImage imageNamed:shareImageUrl]];
        shareObject.webpageUrl = (0==shareUrl.length?@"":shareUrl);
        messageObject.shareObject = shareObject;
    }
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:nil completion:^(id data, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
//                [MBProgressHUD ToastInformation:@"分享失败"];
                NSLog(@"错误原因%@",error.description);
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
//                [MBProgressHUD ToastInformation:@"分享成功"];
                 NSLog(@"分享成功");
            });
        }
    }];
}


//保存图片(url)
- (void)saveImageWithUrl:(NSString *)url{
    [self PhotoLibararyPermissionSuceess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD showHUDWithTitle:@"正在保存"];
        });
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSData *imageData=[NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            UIImage *saveImage=[UIImage imageWithData:imageData];
            if (saveImage) {
                UIImageWriteToSavedPhotosAlbum(saveImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [MBProgressHUD ToastInformation:@"图片错误"];
                });
            }
        });
    } Failed:^{
        
    }];
}

//保存图片(url)
- (void)saveImageWithUrl:(NSString *)urlStr  Success:(void (^) (void)) successBlock Faild:(void (^) (int  type)) faileBlock{
    [self PhotoLibararyPermissionSuceess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD showHUDWithTitle:@"图片正在保存"];
        });
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSData *imageData=[NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
            UIImage *saveImage=[UIImage imageWithData:imageData];
            if (saveImage) {
                UIImageWriteToSavedPhotosAlbum(saveImage, self,  @selector(image:didFinishWithError:contextInfo:), NULL);
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock?successBlock():nil;
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [MBProgressHUD hiddenHUD];
                    faileBlock?faileBlock(0):nil;
                });
            }
        });
    } Failed:^{
         faileBlock?faileBlock(1):nil;
    }];
};


//保存图片(base64)
- (void)saveImageWithBase64:(NSString *)base64String{
    [self PhotoLibararyPermissionSuceess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD showHUDWithTitle:@"正在保存"];
        });
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage  *saveImage=[self imageFromString:base64String];
            if (saveImage) {
                UIImageWriteToSavedPhotosAlbum(saveImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [MBProgressHUD ToastInformation:@"图片格式不正确"];
                });
            }
        });
    } Failed:^{
        
    }];
}

//保存图片(nsdata)
- (void)saveImageWithImageData:(NSData *)imageData{
    [self PhotoLibararyPermissionSuceess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD showHUDWithTitle:@"正在保存"];
        });
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *saveImage=[UIImage imageWithData:imageData];
            if (saveImage) {
                UIImageWriteToSavedPhotosAlbum(saveImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [MBProgressHUD ToastInformation:@"图片格式不正确"];
                });
            }
        });
    } Failed:^{
        
    }];
};


//保存图片回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD showSuccess:@"保存失败"];
        });
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD showSuccess:@"图片已保存到相册"];
        });
    }
}

//保存图片回调
- (void)image:(UIImage *)image didFinishWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD hiddenHUD];
        });
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD hiddenHUD];
        });
    }
}


//发送邮件
- (void)sentMail:(NSString *)mailAddress{
    NSString *url = [NSString stringWithFormat:@"mailto://%@",mailAddress];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
//                [MBProgressHUD ToastInformation:@"您的设备不支持邮件发送"];
            });
        }
    });
};

//打开微信
- (void)openWechat{
    NSURL * wechat_url = [NSURL URLWithString:@"weixin://"];
    if ([[UIApplication sharedApplication] canOpenURL:wechat_url]) {
        [[UIApplication sharedApplication] openURL:wechat_url];
    }else{
//        [MBProgressHUD ToastInformation:@"微信不可用"];
    }
}

#pragma mark 拨打电话
- (void)toCall:(NSString *)phoneNum{
    NSString *callPhone = [NSString stringWithFormat:@"telprompt://%@", phoneNum];
    /// 防止iOS 10及其之后，拨打电话系统弹出框延迟出现
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:callPhone]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callPhone]];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
//                [MBProgressHUD ToastInformation:@"您的设备不支持电话拨打"];
            });
        }
    });
}



//计算多行文本高度
-(CGFloat)changeStationWidth:(NSString *)string anWidthTxtt:(CGFloat)widthText anfont:(CGFloat)fontSize{
    
    UIFont * tfont = SystemFont(fontSize);
    
    //高度估计文本大概要显示几行，宽度根据需求自己定义。 MAXFLOAT 可以算出具体要多高
    
    CGSize size = CGSizeMake(widthText,CGFLOAT_MAX);
    
    //    获取当前文本的属性
    
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
    
    //ios7方法，获取文本需要的size，限制宽度
    
    CGSize  actualsize =[string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    
    return actualsize.height;
    
}

//设置银行卡号样式
- (NSString *)BankNum:(NSString *)bankID{
    if (0==bankID.length) {
        return @"";
    }
    if (6>=bankID.length) {
        return bankID;
    }
    long long bankCard=[bankID longLongValue];
    NSNumber *number = [NSNumber numberWithLongLong:bankCard];
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setUsesGroupingSeparator:YES];
    [formatter setGroupingSize:4];
    [formatter setGroupingSeparator:@" "];
    NSMutableString *cardIdStr=[[NSMutableString alloc]initWithString:[formatter stringFromNumber:number]];
    for (int i=0; i<cardIdStr.length-5; i++) {
        NSString *str=[cardIdStr substringWithRange:NSMakeRange(i, 1)];
        if ([str isEqualToString:@" "]==NO) {
            [cardIdStr replaceCharactersInRange:NSMakeRange(i, 1) withString:@"*"];
        }
    }
    return cardIdStr;
}

//微信支付
- (void)weixinPay:(NSDictionary *)dict{
    if ([WXApi isWXAppInstalled]) {
        //调起微信支付
        PayReq* req             = [[PayReq alloc] init];
        req.openID              = [dict objectForKey:@"appid"];
        req.partnerId           = [dict objectForKey:@"partnerid"];
        req.prepayId            = [dict objectForKey:@"prepayid"];
        req.nonceStr            = [dict objectForKey:@"noncestr"];
        req.timeStamp           = [[dict objectForKey:@"timestamp"] intValue];
        req.package             = [dict objectForKey:@"package"];
        req.sign                = [dict objectForKey:@"sign"];
        [WXApi registerApp:req.openID ];
        [WXApi sendReq:req];
    }else{
        NSLog(@"尚未安装微信客户端,无法使用微信支付");
    }
};


#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp{
    if([resp isKindOfClass:[PayResp class]]){
        switch (resp.errCode) {
            case 0:
                NSLog(@"微信支付成功");
                break;
            case -1:
                NSLog(@"微信支付错误");
                break;
            case -2:
                NSLog(@"用户取消支付");
                break;
            default:
                break;
        }
    }
}

//支付宝支付
- (void)alipay:(NSString *)orderString{
    if (0<orderString.length) {
        /**
         *  支付接口
         *  orderStr       订单信息
         *  schemeStr      调用支付的app注册在info.plist中的scheme
         *  completionBlock 支付结果回调Block，用于wap支付结果回调（非跳转钱包支付）
         */
        NSString *appScheme = @"OrangeBenchAliPay";
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            [self alipayStatus:resultDic];
        }];
    }else{
        NSLog(@"系统繁忙，请重试");
    }
};

//支付宝支付结果校验
- (void)alipayStatus:(NSDictionary *)dic{
    if (dic) {
        NSString *StatusCode=[NSString stringWithFormat:@"%@",[dic objectForKey:@"resultStatus"]];
        if ([StatusCode isEqual:@"9000"])  {
            NSLog(@"支付成功");
        }else if([StatusCode isEqual:@"8000"]){
            NSLog(@"正在处理中")
        }else if([StatusCode isEqual:@"4000"]){
            NSLog(@"订单支付失败")
        }else if([StatusCode isEqual:@"5000"]){
            NSLog(@"重复请求")
        }else if([StatusCode isEqual:@"6001"]){
            NSLog(@"用户中途取消")
        }else if([StatusCode isEqual:@"6002"]){
            NSLog(@"网络连接出错")
        }else if([StatusCode isEqual:@"6004"]){
            NSLog(@"支付结果未知,有可能已经支付成功，请查询商户订单列表中订单的支付状态")
        }else{
            NSLog(@"其它支付错误")
        }
    }
};

@end
