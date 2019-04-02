//
//  GlobalegrowUploadFileModel.h
//  GlobalegrowBugTagSDK
//
//  Created by 张行 on 2019/3/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GlobalegrowUploadFileModel : NSObject

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) BOOL isSuccess;

@end

NS_ASSUME_NONNULL_END
