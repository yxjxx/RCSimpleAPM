//
//  RCPerformanceRecorder.h
//  RCWebImage_Example
//
//  Created by yxj on 07/03/2018.
//  Copyright © 2018 yxjxx. All rights reserved.
//

#import <Foundation/Foundation.h>
#define RC_DocumentsPath  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define RC_DataLocation [RC_DocumentsPath stringByAppendingPathComponent:@"BDWebImageAMP"]

@interface RCPerformanceRecorder : NSObject

@property (nonatomic, strong, readonly) NSMutableArray<NSNumber *> *cpuInfos;
@property (nonatomic, strong, readonly) NSMutableArray<NSNumber *> *memInfos;

+ (instancetype)sharedRecorder;
- (void)start;
- (void)stop;
- (NSMutableArray *)readMutableArrayAtPath:(NSString *)filePath;

/**
 with default duration 120s and default image engine name : BDWebImage
 */
//- (void)monitorImageLibPerformance;
//
//- (void)monitorImageLibPerformanceWithEngineName:(NSString *)imgEngineName;

- (void)monitorImageLibPerformanceWithEngineName:(NSString *)imgEngineName andDuration:(NSTimeInterval)duration callback:(void (^)(UIViewController  *resultVC))doneBlock;

@end
