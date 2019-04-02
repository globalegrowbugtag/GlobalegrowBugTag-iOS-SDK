//
//  GlobalegrowConsoleLogger.m
//  GlobalegrowBugTagSDK
//
//  Created by 张行 on 2019/3/7.
//

#import "GlobalegrowConsoleLogger.h"
#import <YYModel/YYModel.h>

@implementation GlobalegrowConsoleLogger {
    NSMutableArray<GlobalegrowBugTagNetworkLogModel *> *networkLogModels;
}

- (void)URLSessionTaskDidStart:(NSURLSessionTask *)task {
    [self setup];
    NSURLRequest *request = task.originalRequest;
    NSString *body = nil;
    if ([request HTTPBody]) {
        body = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
    }
    GlobalegrowBugTagNetworkLogModel *model = [[GlobalegrowBugTagNetworkLogModel alloc] init];
    model.HTTPMethod = [request HTTPMethod];
    model.URL = [[request URL] absoluteString];
    model.allHTTPHeaderFields = [request allHTTPHeaderFields];
    model.body = body;
    model.taskHash = task.hash;
    [networkLogModels addObject:model];
    if (self.URLSessionTaskDidStart) {
        self.URLSessionTaskDidStart(model);
    }
}

- (void)URLSessionTaskDidFinish:(NSURLSessionTask *)task withResponseObject:(id)responseObject inElapsedTime:(NSTimeInterval )elapsedTime withError:(NSError *)error {
    [self setup];
    NSUInteger responseStatusCode = 0;
    NSDictionary *responseHeaderFields = nil;
    if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
        responseStatusCode = (NSUInteger)[(NSHTTPURLResponse *)task.response statusCode];
        responseHeaderFields = [(NSHTTPURLResponse *)task.response allHeaderFields];
    }
    GlobalegrowBugTagNetworkLogModel *model = [self findModelWithTask:task];
    if (!model) {
        return;
    }
    model.elapsedTime = elapsedTime;
    model.responseStatusCode = responseStatusCode;
    NSString *json = ({
        if ([responseObject isKindOfClass:[NSData class]]) {
            json = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        } else {
            json = [responseObject yy_modelToJSONString];
        }
        json;
    });
    model.responseObject = error ? error.localizedDescription : json;
    if (self.URLSessionTaskDidFinish) {
        self.URLSessionTaskDidFinish(model);
    }
}

- (GlobalegrowBugTagNetworkLogModel *)findModelWithTask:(NSURLSessionTask *)task {
    __block GlobalegrowBugTagNetworkLogModel *model;
    [networkLogModels enumerateObjectsUsingBlock:^(GlobalegrowBugTagNetworkLogModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.taskHash == task.hash) {
            model = obj;
            return;
        }
    }];
    return model;
}

- (void)setup {
    if (!networkLogModels) {
        networkLogModels = [NSMutableArray array];
    }
}

@end

@implementation GlobalegrowBugTagNetworkLogModel

- (instancetype)init {
    if (self = [super init]) {
        _time = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

@end
