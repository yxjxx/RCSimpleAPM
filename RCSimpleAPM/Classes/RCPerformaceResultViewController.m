//
//  RCPerformaceResultViewController.m
//  RCWebImage_Example
//
//  Created by yxj on 07/03/2018.
//  Copyright © 2018 yxjxx. All rights reserved.
//

#import "RCPerformaceResultViewController.h"
#import "RCPerformanceRecorder.h"
#import <PerformanceChart/XLineChart.h>
#import <PerformanceChart/XLineChartPoint.h>
#import <PerformanceChart/XLineChartGradientLine.h>
#import <PerformanceChart/XAreaLineChartConfiguration.h>
#import <PerformanceChart/XLineChartView.h>

@interface RCPerformaceResultViewController ()<XLineChartDelegate>

@property (nonatomic, strong) XLineChart *cpuLineChart;
@property (nonatomic, strong) XLineChart *memLineChart;
@property (nonatomic, strong) NSMutableArray *cpuNumbersArray;
@property (nonatomic, strong) NSMutableArray *memNumbersArray;
@property (nonatomic, strong) NSArray<UIColor *> *colorArray;

@end

@implementation RCPerformaceResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.colorArray = @[[UIColor redColor], [UIColor yellowColor], [UIColor blueColor], [UIColor greenColor]];
    self.cpuNumbersArray = [[NSMutableArray alloc] init];
    self.memNumbersArray = [[NSMutableArray alloc] init];
    NSArray *dirArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:RC_DataLocation error:nil];
    
    NSMutableDictionary *markVDict = [@{} mutableCopy];
    NSInteger idx = 0;
    for (NSString *folderName in dirArr) {
        [markVDict setObject:self.colorArray[idx] forKey:folderName];
        NSString *cpuInfoPath = [NSString stringWithFormat:@"%@/%@/CPU",RC_DataLocation,folderName];
        NSString *memInfoPath = [NSString stringWithFormat:@"%@/%@/MEMORY",RC_DataLocation, folderName];
        [self.cpuNumbersArray addObject:[[RCPerformanceRecorder sharedRecorder] readMutableArrayAtPath:cpuInfoPath]];
        [self.memNumbersArray addObject:[[RCPerformanceRecorder sharedRecorder] readMutableArrayAtPath:memInfoPath]];
        idx++;
    }
    [self.view addSubview:self.cpuLineChart];
    [self.view addSubview:self.memLineChart];
    XLineMarkView *markView = [[XLineMarkView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 70, 70, 70, 40) colorLineNameMap:markVDict];
    [self.view addSubview:markView];
    
#pragma mark 数据源更新后，调用这个方法
//    [self.cpuLineChart.lineChartView refreshContent];
//    [self.memLineChart.lineChartView refreshContent];
    
}

#pragma mark XLineChartDelegate

/// Point
/// Create Point
- (XLineChartPoint*)lineChart:(XLineChart*)lineChart pointForLineAtIndexPath:(NSIndexPath*)indexPath {
    XLineChartPoint *point = [[XLineChartPoint alloc] init];
    point.fillColor = [UIColor redColor].CGColor;
    point.diameter = 4;
    point.pointType = XPointAnnular;
    return point;
}

/// Point value(number)
/// according to value to calculate point position in ios coordinate system
- (CGFloat)lineChart:(XLineChart*)lineChart valueOfPointAtIndexPath:(NSIndexPath*)indexPath {
    if (lineChart.tag == 1) {
        return [(NSNumber *)self.cpuNumbersArray[indexPath.section][indexPath.row] floatValue];
    } else {
        return [(NSNumber *)self.memNumbersArray[indexPath.section][indexPath.row] floatValue];
    }
    
}

/// Line
/// point number
- (NSInteger)lineChart:(XLineChart*)lineChart numberOfPointsInLine:(NSInteger)section {
    if (lineChart.tag == 1) {
        return ((NSMutableArray*)self.cpuNumbersArray[section]).count;
    } else {
        return ((NSMutableArray*)self.memNumbersArray[section]).count;
    }
    
}
- (XLineChartGradientLine*)lineChart:(XLineChart*)lineChart lineForLineChartAtIndex:(NSInteger)index {
    if (index == 0) {
        XLineChartGradientLine *line = [[XLineChartGradientLine alloc] init];
        line.lineWidth = 1.5;
        line.lineMode = XStraightLine;
        line.colors = @[
                        (__bridge id)self.colorArray[index].CGColor,
                        (__bridge id)[UIColor whiteColor].CGColor
                        ];
        line.opacity = 0.6;
        return line;
    } else {
        XLineChartGradientLine *line = [[XLineChartGradientLine alloc] init];
        line.lineWidth = 1.5;
        line.lineMode = XStraightLine;
        line.colors = @[
                        (__bridge id)self.colorArray[index].CGColor,
                        (__bridge id)[UIColor whiteColor].CGColor
                        ];
        line.opacity = 0.6;
        return line;
    }

}

/// Chart
/// line number
- (NSInteger)numberOfLinesInLineChart:(XLineChart*)lineChart {
    if (lineChart.tag == 1) {
        return self.cpuNumbersArray.count;
    } else {
        return self.memNumbersArray.count;
    }}

- (NSString*)lineChart:(XLineChart*)lineChart titleForAbscissaAtIndex:(NSInteger)index {
    if (lineChart.tag == 1) {
        return @"CPU";
    } else {
        return @"MEM";
    }
}

-(XLineChart *)cpuLineChart {
    if (!_cpuLineChart) {
        XAreaLineChartConfiguration* configuration =
        [[XAreaLineChartConfiguration alloc] init];
        configuration.isShowPoint = YES;
        configuration.lineMode = XCurveLine;
        configuration.isShowAuxiliaryDashLine = NO;
        _cpuLineChart = [[XLineChart alloc] initWithFrame:CGRectMake(0, 65, self.view.bounds.size.width, 200)
                                topNumber:@(200)
                             bottomNumber:@(0)
                                graphMode:AreaLineGraph
                       chartConfiguration:configuration];
        _cpuLineChart.delegate = self;
        _cpuLineChart.tag = 1;
    }
    return _cpuLineChart;
}

- (XLineChart *)memLineChart {
    if (!_memLineChart) {
        XAreaLineChartConfiguration* configuration =
        [[XAreaLineChartConfiguration alloc] init];
        configuration.isShowPoint = YES;
        configuration.lineMode = XCurveLine;
        configuration.isShowAuxiliaryDashLine = NO;
        _memLineChart = [[XLineChart alloc] initWithFrame:CGRectMake(0, 300, self.view.bounds.size.width, 300)
                                                topNumber:@(300)
                                             bottomNumber:@(0)
                                                graphMode:AreaLineGraph
                                       chartConfiguration:configuration];
        _memLineChart.delegate = self;
        _memLineChart.tag = 2;
    }
    return _memLineChart;
}


@end
