//
//  GlobalegrowNetworkCenter.h
//  GGAppsflyerAnalyticsSDK
//
//  Created by 张行 on 2019/3/13.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "GlobalegrowBaseModel.h"
#import "GlobalegrowMd5Model.h"
#import "GlobalegrowUploadFileModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GlobalegrowNetworkCenter<T> : NSObject

- (instancetype)initWithClassName:(Class)className
                        serverURL:(NSString *)serverURL;

- (void)pushStack;
- (void)popStack;

- (void)setSuccessBlock:(void (^)(NSURLSessionDataTask * _Nonnull task, GlobalegrowBaseModel<T> *model))successBlock;
- (void)setFailureBlock:(void (^)(NSURLSessionDataTask * _Nullable task, NSString * _Nonnull message))failureBlock;

@end

@interface GlobalegrowNetworkCenter<T> (MD5)

- (void)verifyMD5s:(NSArray<NSString *> *)md5s;

@end


@interface GlobalegrowNetworkCenter (UploadFiles)

- (void)uploadFilesFormDataBlock:(void(^)(id<AFMultipartFormData>  _Nonnull formData))formDataBlock;

@end


@interface GlobalegrowNetworkCenter (LoggerInfo)

- (void)uploadLoggerInfoWithLoggerJson:(NSString *)loggerJson isCrash:(NSString *)isCrash;

@end


NS_ASSUME_NONNULL_END

