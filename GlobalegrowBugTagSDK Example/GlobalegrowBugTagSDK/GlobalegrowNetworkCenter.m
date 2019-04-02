//
//  GlobalegrowNetworkCenter.m
//  GGAppsflyerAnalyticsSDK
//
//  Created by 张行 on 2019/3/13.
//

#import "GlobalegrowNetworkCenter.h"
#import <YYModel/YYmodel.h>


static NSMutableArray<GlobalegrowNetworkCenter *> *centerManager;

@implementation GlobalegrowNetworkCenter {
    Class _className;
    void(^_successBlock)(NSURLSessionDataTask * _Nonnull task, GlobalegrowBaseModel *model);
    void(^_failureBlock)(NSURLSessionDataTask * _Nullable task, NSString * _Nonnull error);
    NSString *_serverURL;
}

- (instancetype)initWithClassName:(Class)className
                        serverURL:(NSString *)serverURL {
    if (self = [super init]) {
        _className = className;
        _serverURL = serverURL;
    }
    return self;
}

- (void)pushStack {
    if (!centerManager) {
        centerManager = [NSMutableArray array];
    }
    [centerManager addObject:self];
}

- (void)popStack {
    [centerManager removeObject:self];
}

- (void)setSuccessBlock:(void (^)(NSURLSessionDataTask * _Nonnull, GlobalegrowBaseModel<id> * _Nonnull))successBlock {
    _successBlock = successBlock;
}

- (void)setFailureBlock:(void (^)(NSURLSessionDataTask * _Nullable, NSString * _Nonnull))failureBlock {
    _failureBlock = failureBlock;
}

- (void(^)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject))afSuccessBlock {
    return ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        printf([[NSString stringWithFormat:@"\n👉🏻%@",responseObject] UTF8String]);
        GlobalegrowBaseModel *model = [[GlobalegrowBaseModel alloc] initWithModelResponse:responseObject className:_className];
        if (self->_successBlock && model.state == 200) {
            self->_successBlock(task, model);
        } else {
            if (self->_failureBlock) {
                self->_failureBlock(task, model.message);
            }
        }
        [self popStack];
    };
}

- (void(^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))afFailureBlock {
    return ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        printf([[NSString stringWithFormat:@"\n👉🏻%@",error.localizedDescription] UTF8String]);
        NSString *message = error.localizedDescription;
        if (self->_failureBlock) {
            self->_failureBlock(task, message);
        }
        [self popStack];
    };
}

- (AFHTTPSessionManager *)sessionManager {
    return [AFHTTPSessionManager manager];
}

- (NSString *)urlWithPath:(NSString *)path {
    return [NSString stringWithFormat:@"%@/%@",_serverURL,path];
}

@end

@implementation GlobalegrowNetworkCenter (MD5)

- (void)verifyMD5s:(NSArray<NSString *> *)md5s {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [[[AFHTTPSessionManager manager] POST:[self urlWithPath:@"md5Verify"]
                               parameters:@{
                                            @"md5s":md5s
                                            }
                                 progress:nil
                                  success:[self afSuccessBlock]
                                  failure:[self afFailureBlock]] resume];

    [self pushStack];
}

@end

@implementation GlobalegrowNetworkCenter (UploadFiles)

- (void)uploadFilesFormDataBlock:(void(^)(id<AFMultipartFormData>  _Nonnull formData))formDataBlock {
    [[[AFHTTPSessionManager manager] POST:[self urlWithPath:@"uploadFile"]
                               parameters:@{
                                            @"uuid":[UIDevice currentDevice].identifierForVendor.UUIDString ?: @"",
                                            }
                constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                    if (formDataBlock) {
                        formDataBlock(formData);
                    }
                }
                                 progress:nil
                                  success:[self afSuccessBlock]
                                  failure:[self afFailureBlock]] resume];
    [self pushStack];
}

@end

@implementation GlobalegrowNetworkCenter (LoggerInfo)

- (void)uploadLoggerInfoWithLoggerJson:(NSString *)loggerJson isCrash:(NSString *)isCrash {
    if (!loggerJson) {
        return;
    }
    [[[AFHTTPSessionManager manager] POST:[self urlWithPath:@"loggerInfo"] parameters:@{
                                                                     @"uuid":[UIDevice currentDevice].identifierForVendor.UUIDString ?: @"",
                                                                     @"LoggerJson":loggerJson,
                                                                     @"isCrash" : isCrash
                                                                     } progress:nil success:[self afSuccessBlock] failure:[self afFailureBlock]] resume];
    [self pushStack];
}

@end

