//
//  GlobalegrowMd5Model.h
//  GlobalegrowBugTagSDK
//
//  Created by 张行 on 2019/3/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GlobalegrowMd5Model : NSObject

/**
 是否已经上传
 */
@property (nonatomic, assign) BOOL isUpload;
/**
 文件的md5
 */
@property (nonatomic, copy) NSString *md5;
/**
 文件所在的路径
 */
@property (nonatomic, copy) NSString *filePath;

@end

NS_ASSUME_NONNULL_END
