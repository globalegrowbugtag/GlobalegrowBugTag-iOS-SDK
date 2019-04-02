//
//  GlobalegrowBugTag.h
//  Pods
//
//  Created by 张行 on 2019/3/4.
//

#import <Foundation/Foundation.h>

@class GlobalegrowBugTagLoggerModel;

extern NSString *GBT_LOG_PRINT(NSDate *date, Class class, NSUInteger line,NSString *formatter,...);
/*
 代替 NSLog 等其他 LOG 宏 返回 Log 信息
 会在 DEBUG 情况打印日志 如果在 Release下 需要在Scheme 配置参数 GBT_LOG才可以打开输出日志
 */
#define GBT_LOG(...) GBT_LOG_PRINT([NSDate date], [self class], __LINE__,__VA_ARGS__)



NS_ASSUME_NONNULL_BEGIN

@interface GlobalegrowBugTag : NSObject

/* 设置服务器的请求地址 */
@property (nonatomic, copy) NSString *serverURL;

/**
 获取对象的单利

 @return GlobalegrowBugTag对象
 */
+ (instancetype)shareGlobalegrowBugTag;

/**
  运行在后台
 */
- (void)runBackground;

/**
 展示bug提交工具
 */
- (void)showBugTag;

/**
 关闭bug提交工具
 */
- (void)closeBugTag;
/**
 @param note:备注信息 允许为空
 */
- (void)submitBugNote:(NSString *)note;

- (void)writeLogInLogFile:(GlobalegrowBugTagLoggerModel *)log;

@end

NS_ASSUME_NONNULL_END
