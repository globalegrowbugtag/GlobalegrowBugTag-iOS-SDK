//
//  UIImage+GlobalegrowBugTag.m
//  GlobalegrowBugTagSDK
//
//  Created by 张行 on 2019/3/5.
//

#import "UIImage+GlobalegrowBugTag.h"

@implementation UIImage (GlobalegrowBugTag)

+ (UIImage *)globalegrow_ImageName:(NSString *)imageName {
    NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(@"GlobalegrowBugTag")];
    NSBundle *imageBundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/GlobalegrowBugTagSDK.bundle",bundle.resourcePath]];
    return [UIImage imageNamed:imageName inBundle:imageBundle compatibleWithTraitCollection:nil];
}

@end
