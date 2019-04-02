//
//  GlobalegrowBugTagModel.h
//  GlobalegrowBugTagSDK
//
//  Created by 张行 on 2019/3/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GlobalegrowBugTagDetailModel;
@class GlobalegrowBugTagPhoneInfoModel;

@interface GlobalegrowBugTagModel : NSObject

@property (nonatomic, copy) NSString *screenImagePath;
@property (nonatomic, strong) GlobalegrowBugTagDetailModel *detail;
@property (nonatomic, copy) NSString *note;
/* 0代表主动上报 1代表崩溃上报 */
@property (nonatomic, copy) NSString *isCrash;

@end

NS_ASSUME_NONNULL_END

@interface GlobalegrowBugTagDetailModel : NSObject

@property (nonatomic, strong) GlobalegrowBugTagPhoneInfoModel *deviceInfo;
@property (nonatomic, copy) NSString *logFilePath;
@property (nonatomic, copy) NSString *networkLogFilePath;
@property (nonatomic, copy) NSString *operatingSetpFilePath;

@end


@interface GlobalegrowBugTagPhoneInfoModel : NSObject

/**
 设备的版本 比如 iOS12.0
 */
@property (nonatomic, copy) NSString *deviceVersion;
/**
 设备的名称 比如 iPhone X
 */
@property (nonatomic, copy) NSString *deviceName;
/**
 分辨率 比如 750x1334
 */
@property (nonatomic, copy) NSString *screenSize;
/**
 可用内存大小 比如0.12G
 */
@property (nonatomic, copy) NSString *availableMemory;
/**
 CPU频率 比如1.5GHZ
 */
@property (nonatomic, copy) NSString *CPUFrequency;
/**
 CPU的内核数量
 */
@property (nonatomic, copy) NSString *CPUCoreNumber;
/**
 CPU 的二级缓存大小
 */
@property (nonatomic, copy) NSString *CPUL2CacheSize;
/**
 手机运营商
 */
@property (nonatomic, copy) NSString *mobileOperator;
/**
 电池的电量
 */
@property (nonatomic, copy) NSString *betty;
/**
 定位所在的国家
 */
@property (nonatomic, copy) NSString *location;
/**
 App 版本
 */
@property (nonatomic, copy) NSString *appVersion;
/**
 手机运行的时间
 */
@property (nonatomic, copy) NSString *appRuningTime;
/**
 SDK 的版本号
 */
@property (nonatomic, copy) NSString *SDKVersion;
/* 唯一数据编号 */
@property (nonatomic, copy) NSString *UUIDString;
/* 0代表主动上报 1代表崩溃上报 */
@property (nonatomic, copy) NSString *isCrash;


@end

@interface GlobalegrowBugTagLoggerModel : NSObject

@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, copy) NSString *log;

@end

