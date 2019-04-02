//
//  GlobalegrowBaseModel.m
//  GlobalegrowBugTagSDK
//
//  Created by 张行 on 2019/3/14.
//

#import "GlobalegrowBaseModel.h"
#import <YYModel/YYmodel.h>

@implementation GlobalegrowBaseModel

- (instancetype)initWithModelResponse:(id)modelResponse
                            className:(Class)className {
    if (!modelResponse) {
        return nil;
    }
    if (![modelResponse isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSDictionary *responseDictionary = (NSDictionary *)modelResponse;
    if (self = [super init]) {
        _state = [responseDictionary[@"state"] integerValue];
        _message = responseDictionary[@"message"];
        id data = responseDictionary[@"data"];
        if (data && [data isKindOfClass:[NSArray class]]) {
            _dataArray = [NSArray yy_modelArrayWithClass:className json:data];
        } else if (data && [data isKindOfClass:[NSDictionary class]]) {
            _dataObject = [className yy_modelWithJSON:data];
        }
    }
    return self;
}

@end
