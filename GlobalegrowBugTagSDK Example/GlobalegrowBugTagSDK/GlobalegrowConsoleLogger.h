//
//  GlobalegrowConsoleLogger.h
//  GlobalegrowBugTagSDK
//
//  Created by 张行 on 2019/3/7.
//

#import <Foundation/Foundation.h>
#import <AFNetworkActivityLogger/AFNetworkActivityLogger.h>

NS_ASSUME_NONNULL_BEGIN

@class GlobalegrowBugTagNetworkLogModel;

@interface GlobalegrowConsoleLogger : NSObject<AFNetworkActivityLoggerProtocol>

@property (nonatomic, strong) NSPredicate *filterPredicate;
@property (nonatomic, assign) AFHTTPRequestLoggerLevel level;

/* 准备发起请求 */
@property (nonatomic, copy) void(^URLSessionTaskDidStart)(GlobalegrowBugTagNetworkLogModel *log);
@property (nonatomic, copy) void(^URLSessionTaskDidFinish)(GlobalegrowBugTagNetworkLogModel *log);

@end


@interface GlobalegrowBugTagNetworkLogModel : NSObject

@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, assign) NSTimeInterval elapsedTime;
@property (nonatomic, assign) NSInteger responseStatusCode;
@property (nonatomic, assign) NSInteger taskHash;
@property (nonatomic, copy) NSString *HTTPMethod;
@property (nonatomic, copy) NSString *URL;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, strong) NSDictionary *allHTTPHeaderFields;
@property (nonatomic, strong) NSString *responseObject;

@end

NS_ASSUME_NONNULL_END
