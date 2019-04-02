//
//  GlobalegrowTabbarControllerListen.m
//  GlobalegrowBugTagSDK
//
//  Created by 张行 on 2019/3/28.
//

#import "GlobalegrowTabbarControllerListen.h"

NSNotificationName const GlobalegrowListenTabbarControllerDidSelectedNotification = @"GlobalegrowListenTabbarControllerDidSelectedNotification";

@implementation GlobalegrowTabbarControllerListen {
    id<UITabBarControllerDelegate> _delegate;
    UITabBarController *_tabbarController;
}

+ (instancetype)shareListen {
    static GlobalegrowTabbarControllerListen *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[GlobalegrowTabbarControllerListen alloc] init];
    });
    return manager;
}

- (void)listenTabbarController:(UITabBarController *)tabbarController {
    if (![_tabbarController isEqual:tabbarController]) {
        if (_tabbarController) {
            _tabbarController.delegate = _delegate;
        }
        _tabbarController = tabbarController;
        _delegate = tabbarController.delegate;
        tabbarController.delegate = self;
        [self switchTabbarWithViewController:tabbarController.selectedViewController];
    }
}

- (void)switchTabbarWithViewController:(UIViewController *)viewController {
    NSString *className = ({
        className = NSStringFromClass([viewController class]);
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)viewController;
            className = NSStringFromClass([nav.topViewController class]);
        }
        className;
    });
    [[NSNotificationCenter defaultCenter] postNotificationName:GlobalegrowListenTabbarControllerDidSelectedNotification
                                                        object:[NSString stringWithFormat:@"tabbar switch %@",className]];
}

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (_delegate && [_delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)]) {
        return [_delegate tabBarController:tabBarController shouldSelectViewController:viewController];
    }
    return YES;
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    [self switchTabbarWithViewController:viewController];
    if (_delegate && [_delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)]) {
        [_delegate tabBarController:tabBarController didSelectViewController:viewController];
    }
}
- (void)tabBarController:(UITabBarController *)tabBarController willBeginCustomizingViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers {
    if (_delegate && [_delegate respondsToSelector:@selector(tabBarController:willBeginCustomizingViewControllers:)]) {
        [_delegate tabBarController:tabBarController willBeginCustomizingViewControllers:viewControllers];
    }
}
- (void)tabBarController:(UITabBarController *)tabBarController willEndCustomizingViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers changed:(BOOL)changed {
    if (_delegate && [_delegate respondsToSelector:@selector(tabBarController:willEndCustomizingViewControllers:changed:)]) {
        [_delegate tabBarController:tabBarController willEndCustomizingViewControllers:viewControllers changed:changed];
    }
}
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers changed:(BOOL)changed {
    if (_delegate && [_delegate respondsToSelector:@selector(tabBarController:didEndCustomizingViewControllers:changed:)]) {
        [_delegate tabBarController:tabBarController didEndCustomizingViewControllers:viewControllers changed:changed];
    }
}
- (nullable id <UIViewControllerInteractiveTransitioning>)tabBarController:(UITabBarController *)tabBarController
                               interactionControllerForAnimationController: (id <UIViewControllerAnimatedTransitioning>)animationController {
    if (_delegate && [_delegate respondsToSelector:@selector(tabBarController:interactionControllerForAnimationController:)]) {
        return [_delegate tabBarController:tabBarController interactionControllerForAnimationController:animationController];
    }
    return nil;
}
- (nullable id <UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController
                     animationControllerForTransitionFromViewController:(UIViewController *)fromVC
                                                       toViewController:(UIViewController *)toVC {
    if (_delegate && [_delegate respondsToSelector:@selector(tabBarController:fromVC:toVC:)]) {
        return [_delegate tabBarController:tabBarController animationControllerForTransitionFromViewController:fromVC toViewController:toVC];
    }
    return nil;
}
@end
