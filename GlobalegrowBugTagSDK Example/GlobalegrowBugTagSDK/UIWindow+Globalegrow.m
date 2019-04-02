//
//  UIWindow+Globalegrow.m
//  GlobalegrowBugTagSDK
//
//  Created by 张行 on 2019/3/28.
//

#import "UIWindow+Globalegrow.h"
#import <objc/runtime.h>
#import "GlobalegrowTabbarControllerListen.h"

@implementation UIWindow (Globalegrow)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method setRootViewControllerMethod = class_getInstanceMethod([self class], @selector(setRootViewController:));
        Method globalegrow_setRootViewControllerMethod = class_getInstanceMethod([self class], @selector(globalegrow_setRootViewController:));
        method_exchangeImplementations(setRootViewControllerMethod, globalegrow_setRootViewControllerMethod);
    });
}

- (void)globalegrow_setRootViewController:(UIViewController *)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        [[GlobalegrowTabbarControllerListen shareListen] listenTabbarController:rootViewController];
    }
    [self globalegrow_setRootViewController:rootViewController];
}

@end
