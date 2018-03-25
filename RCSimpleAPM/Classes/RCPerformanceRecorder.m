//
//  RCPerformanceRecorder.m
//  RCWebImage_Example
//
//  Created by yxj on 07/03/2018.
//  Copyright © 2018 yxjxx. All rights reserved.
//

#import "RCPerformanceRecorder.h"
#include <mach/mach.h>
#import "RCPerformaceResultViewController.h"

static NSString *RC_ImageEngine = @"BDWebImage";
static NSTimeInterval RC_DefaultDuration = 120;

@interface RCPerformanceRecorder()

@property (nonatomic, strong) NSTimer *fetchInfoTimer;
@property (nonatomic, strong, readwrite) NSMutableArray<NSNumber *> *cpuInfos;
@property (nonatomic, strong, readwrite) NSMutableArray<NSNumber *> *memInfos;

@end

@implementation RCPerformanceRecorder {
    dispatch_queue_t _dcdsDiskQueue;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cpuInfos = [@[] mutableCopy];
        _memInfos = [@[] mutableCopy];
        _dcdsDiskQueue = dispatch_queue_create("com.rico.dcdscache.disk", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_t priority = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_set_target_queue(_dcdsDiskQueue, priority);
    }
    return self;
}

+ (instancetype)sharedRecorder {
    static dispatch_once_t onceToken;
    static RCPerformanceRecorder *recoder;
    dispatch_once(&onceToken, ^{
        recoder = [[RCPerformanceRecorder alloc] init];
    });
    return recoder;
}

- (void)configureImageEngine:(NSString *)imgEngineName {
    RC_ImageEngine = imgEngineName;
}

//- (void)monitorImageLibPerformance{
//    [self monitorImageLibPerformanceWithEngineName:RC_ImageEngine andDuration:RC_DefaultDuration];
//}
//
//- (void)monitorImageLibPerformanceWithEngineName:(NSString *)imgEngineName{
//    [self monitorImageLibPerformanceWithEngineName:imgEngineName andDuration:RC_DefaultDuration];
//}

- (void)monitorImageLibPerformanceWithEngineName:(NSString *)imgEngineName andDuration:(NSTimeInterval)duration callback:(void (^)(UIViewController * resultVC))doneBlock{
    [self configureImageEngine:imgEngineName];
    [self start];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self stop];
        RCPerformaceResultViewController *resultVC = [RCPerformaceResultViewController new];
        doneBlock(resultVC);
    });
}

- (void)start {
    //创建目录
    dispatch_async(_dcdsDiskQueue, ^{
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:self.cpuInfoDiskPath]) {
            [fm createDirectoryAtPath:self.cpuInfoDiskPath.stringByDeletingLastPathComponent withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fm fileExistsAtPath:self.memInfoDiskPath]) {
            [fm createDirectoryAtPath:self.memInfoDiskPath.stringByDeletingLastPathComponent withIntermediateDirectories:YES attributes:nil error:nil];
        }
    });
    self.fetchInfoTimer = [NSTimer timerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(fetchInfo:)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.fetchInfoTimer forMode:NSRunLoopCommonModes];
}

- (void)stop {
    [self.fetchInfoTimer invalidate];
    self.fetchInfoTimer = nil;
    [self saveInfosToDisk];
}

- (void)saveInfosToDisk {
    [self writeMutableArray:self.cpuInfos toPath:self.cpuInfoDiskPath];
    [self writeMutableArray:self.memInfos toPath:self.memInfoDiskPath];
}

- (NSString *)cpuInfoDiskPath {
    return [self filePathWithInfoType:@"CPU"];
}

- (NSString *)memInfoDiskPath {
    return [self filePathWithInfoType:@"MEMORY"];
}

- (NSString *)filePathWithImageEngine:(NSString *)engine infoType:(NSString *)type {
    NSString *path = [RC_DataLocation stringByAppendingPathComponent:engine];
    return [path stringByAppendingPathComponent:type];
}

- (NSString *)filePathWithInfoType:(NSString *)type {
    return [self filePathWithImageEngine:RC_ImageEngine infoType:type];
}

- (void)writeMutableArray:(NSMutableArray *)arrM toPath:(NSString *)filePath{
    if (arrM.count <= 0) {
        return;
    }
    dispatch_async(_dcdsDiskQueue, ^{
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:filePath]) {
            [fm createDirectoryAtPath:filePath.stringByDeletingLastPathComponent withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [arrM writeToFile:filePath atomically:YES];
    });
}

- (NSMutableArray *)readMutableArrayAtPath:(NSString *)filePath {
    __block NSMutableArray *arrM;
    dispatch_sync(_dcdsDiskQueue, ^{
        arrM = [NSMutableArray arrayWithContentsOfFile:filePath];
    });
    if (!arrM) {
        arrM = [NSMutableArray array];
    }
    return arrM;
}

- (void)fetchInfo:(NSTimer *)inTimer {
    CGFloat cpuUsage = cpu_usage();
    [self.cpuInfos addObject:@(cpuUsage)];
    CGFloat memoryUsage = instruments_memoryUsage_in_megabytes();
    [self.memInfos addObject:@(memoryUsage)];
    NSLog(@"* CPU Usage: %.4f, Mem Usage: %.4f", cpuUsage, memoryUsage);
    
}

// from http://www.g8production.com/post/68155681673/get-cpu-usage-in-ios
float cpu_usage() {
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0;
    
    basic_info = (task_basic_info_t)tinfo;
    
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    }
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

// http://stackoverflow.com/questions/787160/programmatically-retrieve-memory-usage-on-iphone
CGFloat memory_usage_in_megabytes() {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        return info.resident_size / (1024 * 1024);
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
    return 0;
}

// http://www.samirchen.com/ios-app-memory-usage/
int64_t instruments_memoryUsage_in_megabytes() {
    int64_t memoryUsageInByte = 0;
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernelReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if(kernelReturn == KERN_SUCCESS) {
        memoryUsageInByte = (int64_t) vmInfo.phys_footprint;
        NSLog(@"Memory in use (in bytes): %lld", memoryUsageInByte);
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kernelReturn));
    }
    return memoryUsageInByte / (1024 * 1024);
}

@end
