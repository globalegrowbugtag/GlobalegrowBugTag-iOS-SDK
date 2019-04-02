//
//  UINavigationController+Globalegrow.m
//  GlobalegrowBugTagSDK
//
//  Created by 张行 on 2019/3/28.
//

#import "UINavigationController+Globalegrow.h"
#import <objc/runtime.h>

NSNotificationName const GlobalegrowListenNavigationControllerNotification = @"GlobalegrowListenNavigationControllerNotification";

@implementation UINavigationController (Globalegrow)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self exchangeMethodName:@selector(pushViewController:animated:) replaceMethodName:@selector(globalegrow_pushViewController:animated:)];
        [self exchangeMethodName:@selector(popViewControllerAnimated:) replaceMethodName:@selector(globalegrow_popViewControllerAnimated:)];
        [self exchangeMethodName:@selector(popToRootViewControllerAnimated:) replaceMethodName:@selector(globalegrow_popToRootViewControllerAnimated:)];
        [self exchangeMethodName:@selector(popToViewController:animated:) replaceMethodName:@selector(globalegrow_popToViewController:animated:)];
    });
}

- (void)globalegrow_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        [self notificationAction:[NSString stringWithFormat:@"%@ push %@",[self.viewControllers.lastObject class],[viewController class]]];
    }
    [self globalegrow_pushViewController:viewController animated:animated];
}

- (UIViewController *)globalegrow_popViewControllerAnimated:(BOOL)animated {
    if (self.viewControllers.count > 2) {
        [self notificationAction:[NSString stringWithFormat:@"%@ pop %@",[self.viewControllers.lastObject class],[self.viewControllers[self.viewControllers.count - 2] class]]];
    }
    return [self globalegrow_popViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)globalegrow_popToRootViewControllerAnimated:(BOOL)animated {
    if (self.viewControllers.count > 1) {
        [self notificationAction:[NSString stringWithFormat:@"%@ pop %@",[self.viewControllers.lastObject class],[self.viewControllers.lastObject class]]];
    }
    return [self globalegrow_popToRootViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)globalegrow_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 1) {
        [self notificationAction:[NSString stringWithFormat:@"%@ pop %@",[self.viewControllers.lastObject class],[viewController class]]];
    }
    return [self globalegrow_popToViewController:viewController animated:animated];
}

- (void)notificationAction:(NSString *)action {
    [[NSNotificationCenter defaultCenter] postNotificationName:GlobalegrowListenNavigationControllerNotification
                                                        object:action];
}

+ (void)exchangeMethodName:(SEL)methodA replaceMethodName:(SEL)methodB  {
    Method AMethod = class_getInstanceMethod([self class], methodA);
    Method BMethod = class_getInstanceMethod([self class], methodB);
    method_exchangeImplementations(AMethod, BMethod);
}

@end
