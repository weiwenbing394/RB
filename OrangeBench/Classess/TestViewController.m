//
//  TestViewController.m
//  OrangeBench
//
//  Created by dajiabao on 2017/10/25.
//  Copyright © 2017年 xiaowei. All rights reserved.
//

#import "TestViewController.h"
#import "JSDropDownMenu.h"

@interface TestViewController ()<JSDropDownMenuDataSource,JSDropDownMenuDelegate>{
    //下拉框数据源
    NSMutableArray *_data1;
    NSMutableArray *_data2;
    NSMutableArray *_data3;
    //下拉框选中的index
    NSInteger _currentData1Index;
    NSInteger _currentData2Index;
    NSInteger _currentData3Index;
    NSInteger _currentData1SelectedIndex;
    //下拉控件
    JSDropDownMenu *menu;
    //选中的省
    NSString *province;
    //选中的城市
    NSString *city;
    //选中的性别
    NSString *sex;
}

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //下拉框
    [self initDropDown:CGPointMake(0, 20)];
}

//下拉框
- (void)initDropDown:(CGPoint)point{
    // 指定默认选中
    _currentData1Index = 0;
    //省市数据源
    NSString *path = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"plist"];
    NSArray  *_arrayRoot = [[NSArray alloc]initWithContentsOfFile:path];
    NSMutableArray *privice =[NSMutableArray array];
    NSMutableArray *shi=[NSMutableArray array];
    for (NSDictionary * dic in _arrayRoot) {
        [privice addObject:dic[@"state"]];
        NSArray *shiArray=dic[@"cities"];
        NSMutableArray *cityArr=[NSMutableArray array];
        for (NSDictionary *shiDic in shiArray) {
            [cityArr addObject:shiDic[@"city"]];
        }
        [shi addObject:cityArr];
    }
    _data1=[[NSMutableArray alloc]initWithObjects:@{@"title":@"不限", @"data":@[@"全国"]}, nil];
    for (int i=0;i<privice.count;i++) {
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        [dic setValue:privice[i] forKey:@"title"];
        [dic setValue:shi[i] forKey:@"data"];
        [_data1 addObject:dic];
    }
    _data2 = [NSMutableArray arrayWithObjects:@"不限", @"男", @"女", nil];
    _data3 = [NSMutableArray arrayWithObjects:@"由近到远", @"由远到近", nil];
    //下拉控件
    menu = [[JSDropDownMenu alloc] initWithOrigin:point andHeight:44 inView:self.view];
    menu.indicatorColor = RGB(83, 83, 83);
    menu.separatorColor = RGB(231, 231, 232);
    menu.textColor =[UIColor colorWithHexString:@"#282828"];
    menu.dataSource = self;
    menu.delegate = self;
    [self.view addSubview:menu];
}

#pragma mark 下拉框的代理和数据源
- (NSInteger)numberOfColumnsInMenu:(JSDropDownMenu *)menu {
    return 3;
}

-(BOOL)displayByCollectionViewInColumn:(NSInteger)column{
    return NO;
}

-(BOOL)haveRightTableViewInColumn:(NSInteger)column{
    if (column==0) {
        return YES;
    }
    return NO;
}

-(CGFloat)widthRatioOfLeftColumn:(NSInteger)column{
    if (column==0) {
        return 1/3.0;
    }
    return 1;
}

-(NSInteger)currentLeftSelectedRow:(NSInteger)column{
    if (column==0) {
        return _currentData1Index;
    }
    if (column==1) {
        return _currentData2Index;
    }
    if (column==2) {
        return _currentData3Index;
    }
    return 0;
}

- (NSInteger)menu:(JSDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column leftOrRight:(NSInteger)leftOrRight leftRow:(NSInteger)leftRow{
    if (column==0) {
        if (leftOrRight==0) {
            return _data1.count;
        } else{
            NSDictionary *menuDic = [_data1 objectAtIndex:leftRow];
            return [[menuDic objectForKey:@"data"] count];
        }
    } else if (column==1){
        return _data2.count;
    } else if (column==2){
        return _data3.count;
    }
    return 0;
}

- (NSString *)menu:(JSDropDownMenu *)menu titleForColumn:(NSInteger)column{
    switch (column) {
        case 0: return [[_data1[_currentData1Index] objectForKey:@"data"] objectAtIndex:_currentData1SelectedIndex];
            break;
        case 1: return _data2[_currentData2Index];
            break;
        case 2: return _data3[_currentData3Index];
            break;
        default:
            return nil;
            break;
    }
}

- (NSString *)menu:(JSDropDownMenu *)menu titleForRowAtIndexPath:(JSIndexPath *)indexPath {
    if (indexPath.column==0) {
        if (indexPath.leftOrRight==0) {
            NSDictionary *menuDic = [_data1 objectAtIndex:indexPath.row];
            return [menuDic objectForKey:@"title"];
        } else{
            NSInteger leftRow = indexPath.leftRow;
            NSDictionary *menuDic = [_data1 objectAtIndex:leftRow];
            return [[menuDic objectForKey:@"data"] objectAtIndex:indexPath.row];
        }
    } else if (indexPath.column==1) {
        return _data2[indexPath.row];
    } else {
        return _data3[indexPath.row];
    }
}

- (void)menu:(JSDropDownMenu *)menu didSelectRowAtIndexPath:(JSIndexPath *)indexPath {
    if (indexPath.column == 0) {
        if(indexPath.leftOrRight==0){
            _currentData1Index = indexPath.row;
            return;
        }else if(indexPath.leftOrRight==1){
            _currentData1SelectedIndex=indexPath.row;
        }
    } else if(indexPath.column == 1){
        _currentData2Index = indexPath.row;
    } else{
        _currentData3Index = indexPath.row;
    }
    [self menuDidChange];
}

#pragma mark 下拉框变化
- (void)menuDidChange{
    @try {
        //选中的省
        if ([[_data1[_currentData1Index] objectForKey:@"title"] isEqualToString:@"不限"]) {
            province=@"";
        }else{
            province=[_data1[_currentData1Index] objectForKey:@"title"];
        }
        //选中的市
        if ([[[_data1[_currentData1Index] objectForKey:@"data"] objectAtIndex:_currentData1SelectedIndex] isEqualToString:@"全国"]) {
            city=@"";
        }else{
            city= [[_data1[_currentData1Index] objectForKey:@"data"] objectAtIndex:_currentData1SelectedIndex];
        }
        //选中的性别
        NSString *sexStr=_data2[_currentData2Index];
        if ([sexStr isEqualToString:@"不限"]) {
            sex=@"";
        }else if ([sexStr isEqualToString:@"男"]) {
            sex=@"1";
        }else if ([sexStr isEqualToString:@"女"]) {
            sex=@"0";
        }
        NSLog(@"选中的省=%@,选中的城市=%@,选中的性别=%@",province,city,sex);
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
