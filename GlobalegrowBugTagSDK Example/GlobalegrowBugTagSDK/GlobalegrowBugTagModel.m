//
//  GlobalegrowBugTagModel.m
//  GlobalegrowBugTagSDK
//
//  Created by 张行 on 2019/3/5.
//

#import "GlobalegrowBugTagModel.h"

@implementation GlobalegrowBugTagModel

@end

@implementation GlobalegrowBugTagDetailModel

@end

@implementation GlobalegrowBugTagPhoneInfoModel

@end

@implementation GlobalegrowBugTagLoggerModel

- (instancetype)init {
    if (self = [super init]) {
        _time = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

@end

