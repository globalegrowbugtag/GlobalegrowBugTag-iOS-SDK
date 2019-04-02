
# BUG收集框架接入指南

## 安装

```ruby
pod 'GlobalegrowBugTagSDK', :git => "https://github.com/globalegrowbugtag/GlobalegrowBugTag-iOS-SDK", :tag => "0.1.0"
```

## 配置初始化

1 在 AppDelegate.m引入框架

```objc
#import <GlobalegrowBugTagSDK/GlobalegrowBugTag.h>
```

2 在 didFinishLaunchingWithOptions方法最后一行添加以下代码

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 一定需要在最后一行 因为需要监听崩溃
    GlobalegrowBugTag *bugTag = [GlobalegrowBugTag shareGlobalegrowBugTag];
    // 设置部署的服务器地址
    bugTag.serverURL = @"";
    [bugTag runBackground];
    return YES;
}
```

## 展示入口主动上报

在需要展示点击事件中添加下面代码

```objc
[[GlobalegrowBugTag shareGlobalegrowBugTag] showBugTag];
```

关闭

```objc
[[GlobalegrowBugTag shareGlobalegrowBugTag] closeBugTag];
```

## 接入 Log 日志统计

将项目里面所有 `NSLog` 或者其他的打印 `Log` 宏换成`GBT_LOG`

```objc
GBT_LOG(@"this is test log");
```

- 如果想自己打印怎么办？

  ```objc
  NSLog(@"%@",GBT_LOG(@"this is test log")));
  ```

- 如果想在 `Release` 开发模式打印 `Log`,在 `Secheme`->`Run`->`Arguments`->`Envirenment Vaiables` 添加`GBT_LOG`参数勾选即可

  ![image-20190328173655363](http://ipicimage-1251019290.coscd.myqcloud.com/2019-03-28-093655.png)

  
