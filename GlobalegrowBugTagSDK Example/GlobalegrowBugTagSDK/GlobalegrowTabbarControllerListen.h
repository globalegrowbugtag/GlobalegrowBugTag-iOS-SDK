//
//  GlobalegrowTabbarControllerListen.h
//  GlobalegrowBugTagSDK
//
//  Created by 张行 on 2019/3/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const GlobalegrowListenTabbarControllerDidSelectedNotification;

@interface GlobalegrowTabbarControllerListen : NSObject<UITabBarControllerDelegate>

+ (instancetype)shareListen;

- (void)listenTabbarController:(UITabBarController *)tabbarController;

@end

NS_ASSUME_NONNULL_END
