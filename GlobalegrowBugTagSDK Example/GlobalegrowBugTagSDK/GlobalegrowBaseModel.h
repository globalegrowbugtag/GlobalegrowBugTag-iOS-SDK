//
//  GlobalegrowBaseModel.h
//  GlobalegrowBugTagSDK
//
//  Created by 张行 on 2019/3/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GlobalegrowBaseModel<T> : NSObject

@property (nonatomic, assign, readonly) NSInteger state;
@property (nonatomic, copy, readonly) NSString *message;
@property (nonatomic, strong, readonly) T dataObject;
@property (nonatomic, strong, readonly) NSArray<T> *dataArray;

- (instancetype)initWithModelResponse:(id)modelResponse className:(Class)className;

@end

NS_ASSUME_NONNULL_END
