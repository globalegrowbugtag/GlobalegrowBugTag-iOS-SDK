//
//  UIViewController+Globalegrow.m
//  GlobalegrowBugTagSDK
//
//  Created by 张行 on 2019/3/28.
//

#import "UIViewController+Globalegrow.h"
#import <objc/runtime.h>

extern NSNotificationName const GlobalegrowListenViewControllerNotification = @"GlobalegrowListenViewControllerNotification";

@implementation UIViewController (Globalegrow)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self exchangeMethodName:@selector(presentViewController:animated:completion:) replaceMethodName:@selector(globalegrow_presentViewController:animated:completion:)];
        [self exchangeMethodName:@selector(dismissViewControllerAnimated:completion:) replaceMethodName:@selector(globalegrow_dismissViewControllerAnimated:completion:)];
        
    });
}

- (void)globalegrow_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^ __nullable)(void))completion {
    NSString *className = ({
        className = NSStringFromClass([viewControllerToPresent class]);
        if ([viewControllerToPresent isKindOfClass:[UINavigationController class]]) {
            className = NSStringFromClass([[(UINavigationController *)viewControllerToPresent viewControllers].lastObject class]);
        }
        className;
    });
    [[NSNotificationCenter defaultCenter] postNotificationName:GlobalegrowListenViewControllerNotification object:[NSString stringWithFormat:@"%@ present %@",NSStringFromClass([self class]),className]];
    [self globalegrow_presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)globalegrow_dismissViewControllerAnimated:(BOOL)flag completion:(void (^ __nullable)(void))completion {
    [[NSNotificationCenter defaultCenter] postNotificationName:GlobalegrowListenViewControllerNotification object:[NSString stringWithFormat:@"%@ dismiss",NSStringFromClass([self class])]];
    [self globalegrow_dismissViewControllerAnimated:flag completion:completion];
}

+ (void)exchangeMethodName:(SEL)methodA replaceMethodName:(SEL)methodB  {
    Method AMethod = class_getInstanceMethod([self class], methodA);
    Method BMethod = class_getInstanceMethod([self class], methodB);
    method_exchangeImplementations(AMethod, BMethod);
}

@end
