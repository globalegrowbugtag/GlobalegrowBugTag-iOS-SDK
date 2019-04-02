//
//  GlobalegrowBugTag.m
//  Pods
//
//  Created by 张行 on 2019/3/4.
//

#import "GlobalegrowBugTag.h"
#import <WMDragView/WMDragView.h>
#import <Masonry/Masonry.h>
#import <GBDeviceInfo/GBDeviceInfo.h>
#import <FCFileManager/FCFileManager.h>
#import <YYModel/YYModel.h>
#import <AFNetworkActivityLogger/AFNetworkActivityLogger.h>
#import "UIImage+GlobalegrowBugTag.h"
#import "GlobalegrowSubmitNoteView.h"
#import "GlobalegrowConsoleLogger.h"
#import "GlobalegrowBugTagModel.h"
#import <SKYMD5Tool/SKYMD5Tool.h>
#import "GlobalegrowNetworkCenter.h"
#import "GlobalegrowOperatingStepModel.h"
#import "GlobalegrowTabbarControllerListen.h"
#import "UINavigationController+Globalegrow.h"
#import "UIViewController+Globalegrow.h"

static NSUncaughtExceptionHandler *GlobalegrowPreviousHandler;
static NSString *const GlobalegrowExceptionNotificationName = @"GlobalegrowExceptionNotificationName";

void GlobalegrowHandleException(NSException *exception) {
    NSString *json = [NSString stringWithFormat:@"reason:\n%@\n\n\callStackSymbols:\n%@",exception.reason,exception.callStackSymbols];
    [[NSNotificationCenter defaultCenter] postNotificationName:GlobalegrowExceptionNotificationName object:json];
    GlobalegrowPreviousHandler(exception);
}

void GlobalegrowRegisterSignalHandler(void) {
    GlobalegrowPreviousHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(&GlobalegrowHandleException);
}

NSString *GBT_LOG_PRINT(NSDate *date, Class class, NSUInteger line,NSString *formatter,...) {
    va_list args;
    va_start(args, formatter);
    NSString *log = [[NSString alloc] initWithFormat:formatter arguments:args];
    
    
    if (log.length > 0) {
        NSString *printLog = [NSString stringWithFormat:@"%@ %@ %@ %@",date,class,@(line),log];
        GlobalegrowBugTagLoggerModel *logger = [[GlobalegrowBugTagLoggerModel alloc] init];
        logger.log = printLog;
        [[GlobalegrowBugTag shareGlobalegrowBugTag] writeLogInLogFile:logger];
#ifdef DEBUG
        NSLog(@"%@",log);
#else
        if ([NSProcessInfo processInfo].environment[@"GBT_LOG"]) {
            NSLog(@"%@",log);
        }
#endif
    }
    va_end(args);
    return log;
}

@interface GlobalegrowBugTag ()

/**
 bug提交的按钮
 */
@property (nonatomic, strong) WMDragView *dragView;
/**
 关闭按钮
 */
@property (nonatomic, strong) UIButton *closeButton;
/**
 提交 BUG的按钮
 */
@property (nonatomic, strong) UIButton *submitBugButton;

@end

@implementation GlobalegrowBugTag {
    /* 开始运行的时间戳 */
    NSTimeInterval _startRunTimeInterval;
    GlobalegrowConsoleLogger *_logger;
    void(^_customLogPrintBlock)(NSString *log);
}

+ (instancetype)shareGlobalegrowBugTag {
    static GlobalegrowBugTag *globalegrowBugTag;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        globalegrowBugTag = [[GlobalegrowBugTag alloc] init];
    });
    return globalegrowBugTag;
}

- (void)runBackground {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(exceptionNotification:)
                                                 name:GlobalegrowExceptionNotificationName
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForegroundNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFinishLaunchingNotification:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActiveNotification:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMemoryWarningNotification:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(protectedDataDidBecomeAvailableNotification:)
                                                 name:UIApplicationProtectedDataDidBecomeAvailable
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tabbarControllerDidSelectedNotification:)
                                                 name:GlobalegrowListenTabbarControllerDidSelectedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(navigationControllerNotification:)
                                                 name:GlobalegrowListenNavigationControllerNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewControllerNotification:)
                                                 name:GlobalegrowListenViewControllerNotification
                                               object:nil];
    _startRunTimeInterval = [[NSDate date] timeIntervalSince1970];
    [self createGlobalegrowBugTagDirectory];
    _logger = [[GlobalegrowConsoleLogger alloc] init];
    __weak typeof(self) weakSelf = self;
//    _logger.URLSessionTaskDidStart = ^(GlobalegrowBugTagNetworkLogModel *log) {
//        __strong typeof(weakSelf) strongSelf = weakSelf;
//        [strongSelf writeLogInNetworkFile:log];
//    };
    _logger.URLSessionTaskDidFinish = ^(GlobalegrowBugTagNetworkLogModel *log) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf writeLogInNetworkFile:log];
    };
    [[AFNetworkActivityLogger sharedLogger] addLogger:_logger];
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    GlobalegrowRegisterSignalHandler();
    [self runBackgroundSubmitLog];
}

- (void)listenWindowRootController:(UIViewController *)rootController {
    if ([rootController isKindOfClass:[UITabBarController class]]) {
        [[GlobalegrowTabbarControllerListen shareListen] listenTabbarController:rootController];
    }
}

- (void)exceptionNotification:(NSNotification *)no {
    NSString *json = no.object;
    [self submitBugNote:json isException:YES];
}

- (void)tabbarControllerDidSelectedNotification:(NSNotification *)no {
    [self writeOperatingSetpInFile:no.object];
}

- (void)didEnterBackgroundNotification:(NSNotification *)no {
    [self writeOperatingSetpInFile:@"didEnterBackground"];
}

- (void)willEnterForegroundNotification:(NSNotification *)no {
    [self writeOperatingSetpInFile:@"willEnterForeground"];
}

- (void)didFinishLaunchingNotification:(NSNotification *)no {
    [self writeOperatingSetpInFile:@"didFinishLaunching"];
}

- (void)didBecomeActiveNotification:(NSNotification *)no {
    [self writeOperatingSetpInFile:@"didBecomeActive"];
}

- (void)didReceiveMemoryWarningNotification:(NSNotification *)no {
    [self writeOperatingSetpInFile:@"didReceiveMemoryWarning"];
}

- (void)protectedDataDidBecomeAvailableNotification:(NSNotification *)no {
    [self writeOperatingSetpInFile:@"protectedDataDidBecomeAvailable"];
}

- (void)windowDidBecomeKeyNotification:(NSNotification *)no {
    [self listenWindowRootController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (void)navigationControllerNotification:(NSNotification *)no {
    [self writeOperatingSetpInFile:no.object];
}

- (void)viewControllerNotification:(NSNotification *)no {
    [self writeOperatingSetpInFile:no.object];
}

- (void)submitBugNote:(NSString *)note isException:(BOOL)isException {
    GlobalegrowBugTagPhoneInfoModel *deviceDetailModel = ({
        deviceDetailModel = [[GlobalegrowBugTagPhoneInfoModel alloc] init];
        GBDeviceInfo *device = [GBDeviceInfo deviceInfo];
        deviceDetailModel.deviceVersion = [NSString stringWithFormat:@"%@.%@.%@",@(device.osVersion.major),@(device.osVersion.minor),@(device.osVersion.patch)];
        deviceDetailModel.deviceName = device.modelString;
        deviceDetailModel.screenSize = [NSString stringWithFormat:@"%@x%@",@([UIScreen mainScreen].currentMode.size.width),@([UIScreen mainScreen].currentMode.size.height)];
        deviceDetailModel.availableMemory = [NSString stringWithFormat:@"%@G",@(device.physicalMemory)];
        deviceDetailModel.CPUFrequency = [NSString stringWithFormat:@"%@GHZ",@(device.cpuInfo.frequency)];
        deviceDetailModel.CPUCoreNumber = [NSString stringWithFormat:@"%@个",@(device.cpuInfo.numberOfCores)];
        deviceDetailModel.CPUL2CacheSize = [NSString stringWithFormat:@"%@KB",@(device.cpuInfo.l2CacheSize)];
        deviceDetailModel.appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        deviceDetailModel.SDKVersion = [[[NSBundle bundleForClass:NSClassFromString(@"GlobalegrowBugTag")] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        deviceDetailModel.betty = [@([UIDevice currentDevice].batteryLevel) stringValue];
        deviceDetailModel.UUIDString = [UIDevice currentDevice].identifierForVendor.UUIDString;
        deviceDetailModel.isCrash = isException ? @"1" : @"0";
        deviceDetailModel;
    });
    
    if (![FCFileManager existsItemAtPath:[self uploadBugDirectory]]) {
        [FCFileManager createDirectoriesForPath:[self uploadBugDirectory]];
    }
    NSUInteger time = (NSUInteger)[[NSDate date] timeIntervalSince1970];
    NSString *uploadDirectory = [NSString stringWithFormat:@"%@/%@",[self uploadBugDirectory],@(time)];
    if (![FCFileManager existsItemAtPath:uploadDirectory]) {
        [FCFileManager createDirectoriesForPath:uploadDirectory];
    }
    UIImage *screenImage = [self getCurrentViewImage];
    NSData *screenData = UIImageJPEGRepresentation(screenImage, 1.0);
    [screenData writeToFile:[NSString stringWithFormat:@"%@/screen.jpg",uploadDirectory] atomically:YES];
    NSString *deviceJson = [deviceDetailModel yy_modelToJSONString];
    [deviceJson writeToFile:[NSString stringWithFormat:@"%@/device.json",uploadDirectory] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [note writeToFile:[NSString stringWithFormat:@"%@/note.txt",uploadDirectory] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [FCFileManager copyItemAtPath:[self networkFilePath] toPath:[NSString stringWithFormat:@"%@/network.json",uploadDirectory] overwrite:YES];
    [FCFileManager copyItemAtPath:[self logFilePath] toPath:[NSString stringWithFormat:@"%@/log.json",uploadDirectory] overwrite:YES];
    [FCFileManager copyItemAtPath:[self operatingSetpPath] toPath:[NSString stringWithFormat:@"%@/operating_setp.json",uploadDirectory] overwrite:YES];
    if (!isException) {
        [self runBackgroundSubmitLog];
    }
}

/**
 后台运行提交日志
 */
- (void)runBackgroundSubmitLog {
    NSString *uploadDirectory = [self uploadBugDirectory];
    NSArray<NSString *> *subDirectorys = [FCFileManager listDirectoriesInDirectoryAtPath:uploadDirectory];
    if (subDirectorys.count == 0) {
        return;
    }
    for (NSString *subDirectory in subDirectorys) {
        [self uploadBugInfoWithDirectory:subDirectory];
    }
}

- (void)uploadBugInfoWithDirectory:(NSString *)directory {
    [self verifyFilesMd5WithDirectory:directory];
}

- (NSArray<NSString *> *)needUploadFileNames {
    return @[
             @"screen.jpg",
             @"network.json",
             @"log.json",
             @"operating_setp.json"
             ];
}

- (NSString *)fileMD5WithPath:(NSString *)filePath {
    if (![FCFileManager existsItemAtPath:filePath]) {
        return nil;
    }
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    if (!data) {
        return nil;
    }
    NSString *md5 = [SKYMD5Tool MD5Lower32Digest:data];
    if (!md5 || md5.length == 0) {
        return nil;
    }
    return md5;
}

- (void)verifyFilesMd5WithDirectory:(NSString *)directory {
    NSMutableArray<NSString *> *md5s = [NSMutableArray array];
    [[self needUploadFileNames] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",directory,obj];
        NSString *md5 = [self fileMD5WithPath:filePath];
        if (!md5) {
            return;
        }
        [md5s addObject:md5];
    }];
    GlobalegrowNetworkCenter<GlobalegrowMd5Model *> *center = [[GlobalegrowNetworkCenter alloc] initWithClassName:[GlobalegrowMd5Model class] serverURL:self.serverURL];
    __weak typeof(self) weakSelf = self;
    [center setSuccessBlock:^(NSURLSessionDataTask * _Nonnull task, GlobalegrowBaseModel<GlobalegrowMd5Model *> * _Nonnull model) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf uploadFileWithDirectory:directory
                                  md5Models:model.dataArray];
    }];
    [center verifyMD5s:md5s];
}

- (void)uploadFileWithDirectory:(NSString *)directory
                      md5Models:(NSArray<GlobalegrowMd5Model *> *)md5Models {
    NSMutableArray<NSString *> *uploadFileNames = [NSMutableArray array];
    NSMutableArray<GlobalegrowUploadFileModel *> *uploadFileModels = [NSMutableArray array];
    [[self needUploadFileNames] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",directory,obj];
        NSString *md5 = [self fileMD5WithPath:filePath];
        __block BOOL isUpload = NO;
        GlobalegrowUploadFileModel *model = [[GlobalegrowUploadFileModel alloc] init];
        model.isSuccess = YES;
        [md5Models enumerateObjectsUsingBlock:^(GlobalegrowMd5Model * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.md5 isEqualToString:md5] && obj.isUpload) {
                isUpload = YES;
                model.filePath = obj.filePath;
            }
        }];
        if (!isUpload) {
            [uploadFileNames addObject:obj];
        } else {
            model.fileName = obj;
            [uploadFileModels addObject:model];
        }
    }];
    if (uploadFileNames.count == 0) {
        [self uploadDeviceInfoWithDirectory:directory uploadFileModels:uploadFileModels];
        return;
    }
    __weak typeof(self) weakSelf = self;
    GlobalegrowNetworkCenter<GlobalegrowUploadFileModel *> *center = [[GlobalegrowNetworkCenter alloc] initWithClassName:[GlobalegrowUploadFileModel class] serverURL:self.serverURL];
    [center setSuccessBlock:^(NSURLSessionDataTask * _Nonnull task, GlobalegrowBaseModel<GlobalegrowUploadFileModel *> * _Nonnull model) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [uploadFileModels addObjectsFromArray:model.dataArray];
        [weakSelf uploadDeviceInfoWithDirectory:directory uploadFileModels:uploadFileModels];
    }];
    [center uploadFilesFormDataBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [uploadFileNames enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *filePath = [NSString stringWithFormat:@"%@/%@",directory,obj];
            NSString *mimeType = ({
                mimeType = @"";
                if ([[obj componentsSeparatedByString:@"."].lastObject isEqualToString:@"jpg"]) {
                    mimeType = @"image/jpeg";
                } else if ([[obj componentsSeparatedByString:@"."].lastObject isEqualToString:@"json"]) {
                    mimeType = @"application/json";
                }
                mimeType;
            });
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            if (!data) {
                return;
            }
            [formData appendPartWithFileData:[NSData dataWithContentsOfFile:filePath] name:obj fileName:obj mimeType:mimeType];
        }];
    }];
}

- (void)uploadDeviceInfoWithDirectory:(NSString *)directory
                     uploadFileModels:(NSArray<GlobalegrowUploadFileModel *> *)uploadFileModels {
    GlobalegrowBugTagModel *model = [[GlobalegrowBugTagModel alloc] init];
    GlobalegrowBugTagDetailModel *detailModel = [[GlobalegrowBugTagDetailModel alloc] init];
    __block BOOL allowUpload = YES;
    [uploadFileModels enumerateObjectsUsingBlock:^(GlobalegrowUploadFileModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.isSuccess) {
            allowUpload = NO;
        }
        if ([obj.fileName isEqualToString:@"screen.jpg"]) {
            model.screenImagePath = obj.filePath;
        } else if ([obj.fileName isEqualToString:@"network.json"]) {
            detailModel.networkLogFilePath = obj.filePath;
        } else if ([obj.fileName isEqualToString:@"log.json"]) {
            detailModel.logFilePath = obj.filePath;
        } else if ([obj.fileName isEqualToString:@"operating_setp.json"]) {
            detailModel.operatingSetpFilePath = obj.filePath;
        }
    }];
    NSString *deviceJson = [[NSString alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/device.json",directory] encoding:NSUTF8StringEncoding error:nil];
    if (!deviceJson) {
        return;
    }
    GlobalegrowBugTagPhoneInfoModel *phoneInfoModel = [GlobalegrowBugTagPhoneInfoModel yy_modelWithJSON:deviceJson];
    detailModel.deviceInfo = phoneInfoModel;
    model.detail = detailModel;
    model.isCrash = phoneInfoModel.isCrash;
    NSString *note = [[NSString alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/note.txt",directory] encoding:NSUTF8StringEncoding error:nil];
    if (!note) {
        return;
    }
    model.note = note;
    if (!allowUpload) {
        return;
    }
    GlobalegrowNetworkCenter<id> *center = [[GlobalegrowNetworkCenter alloc] initWithClassName:nil serverURL:self.serverURL];
    [center setSuccessBlock:^(NSURLSessionDataTask * _Nonnull task, GlobalegrowBaseModel<id> * _Nonnull model) {
        [FCFileManager removeItemAtPath:directory];
    }];
    [center uploadLoggerInfoWithLoggerJson:[model yy_modelToJSONString] isCrash:model.isCrash];
}

- (NSString *)printLog:(NSString *)formatter date:(nonnull NSDate *)date class:(nonnull Class)class line:(NSUInteger)line, ...{
    va_list args;
    va_start(args, formatter);
    NSString *log = [[NSString alloc] initWithFormat:formatter arguments:args];
    NSLog(log);
    va_end(args);
    
    if (log.length > 0) {
        NSString *printLog = [NSString stringWithFormat:@"\n%@ %@ %@ %@",date,class,@(line),log];
        GlobalegrowBugTagLoggerModel *logger = [[GlobalegrowBugTagLoggerModel alloc] init];
        logger.log = printLog;
        [self writeLogInLogFile:logger];
#ifdef DEBUG
        NSLog(printLog);
#else
        if ([NSProcessInfo processInfo].environment[@"GBT_LOG"]) {
           NSLog(printLog);
        }
#endif
    }
    return log;
}

- (void)customLogPrintBlock:(void(^)(NSString *log))block {
    _customLogPrintBlock = block;
}

- (void)createGlobalegrowBugTagDirectory {
    NSString *globalegrowBugTagCache = [self globalegrowBugTagCacheDirectory];
    if ([FCFileManager existsItemAtPath:globalegrowBugTagCache]) {
        [FCFileManager removeItemAtPath:globalegrowBugTagCache];
    }
    [FCFileManager createDirectoriesForPath:globalegrowBugTagCache];
}

- (void)writeLogInNetworkFile:(GlobalegrowBugTagNetworkLogModel *)log {
    if (!log) {
        return;
    }
    NSMutableArray<GlobalegrowBugTagNetworkLogModel *> *netwokLogs = [NSMutableArray array];
    NSString *networkFile = [self networkFilePath];
    if ([FCFileManager existsItemAtPath:networkFile]) {
        NSString *json = [[NSString alloc] initWithContentsOfFile:networkFile encoding:NSUTF8StringEncoding error:nil];
        [netwokLogs addObjectsFromArray:[NSArray yy_modelArrayWithClass:[GlobalegrowBugTagNetworkLogModel class] json:json]];
    }
    [netwokLogs addObject:log];
    NSString *json = [netwokLogs yy_modelToJSONString];
    NSError *error;
    [json writeToFile:networkFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
}

- (void)writeLogInLogFile:(GlobalegrowBugTagLoggerModel *)log {
    if (!log) {
        return;
    }
    NSMutableArray<GlobalegrowBugTagLoggerModel *> *logs = [NSMutableArray array];
    NSString *logFile = [self logFilePath];
    if ([FCFileManager existsItemAtPath:logFile]) {
        NSString *json = [[NSString alloc] initWithContentsOfFile:logFile encoding:NSUTF8StringEncoding error:nil];
        [logs addObjectsFromArray:[NSArray yy_modelArrayWithClass:[GlobalegrowBugTagLoggerModel class] json:json]];
    }
    [logs addObject:log];
    NSString *json = [logs yy_modelToJSONString];
    NSError *error;
    [json writeToFile:logFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
}

- (void)writeOperatingSetpInFile:(NSString *)operatingSetp {
    if (operatingSetp.length == 0) {
        return;
    }
    GlobalegrowOperatingStepModel *model = [[GlobalegrowOperatingStepModel alloc] init];
    model.time = [[NSDate date] timeIntervalSince1970];
    model.operatingStep = operatingSetp;
    NSMutableArray<GlobalegrowOperatingStepModel *> *operatingSetps = [NSMutableArray array];
    NSString *operatingSetpPath = [self operatingSetpPath];
    if ([FCFileManager existsItemAtPath:operatingSetpPath]) {
        NSString *json = [[NSString alloc] initWithContentsOfFile:operatingSetpPath encoding:NSUTF8StringEncoding error:nil];
        [operatingSetps addObjectsFromArray:[NSArray yy_modelArrayWithClass:[GlobalegrowOperatingStepModel class] json:json]];
    }
    [operatingSetps addObject:model];
    NSString *json = [operatingSetps yy_modelToJSONString];
    NSError *error;
    [json writeToFile:operatingSetpPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
}

- (NSString *)globalegrowBugTagCacheDirectory {
    return [NSString stringWithFormat:@"%@/GlobalegrowBugTag",[FCFileManager pathForCachesDirectory]];
}

- (NSString *)operatingSetpPath {
    return [NSString stringWithFormat:@"%@/operating_setp.json",[self globalegrowBugTagCacheDirectory]];
}

- (NSString *)uploadBugDirectory {
    return [NSString stringWithFormat:@"%@/GlobalegrowBugTagUpload",[FCFileManager pathForDocumentsDirectory]];
}

- (NSString *)networkFilePath {
    return [NSString stringWithFormat:@"%@/network.json",[self globalegrowBugTagCacheDirectory]];
}

- (NSString *)logFilePath {
    return [NSString stringWithFormat:@"%@/log.json",[self globalegrowBugTagCacheDirectory]];
}

- (void)showBugTag {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (![window isMemberOfClass:[UIWindow class]]) {
        return;
    }
    [window addSubview:self.dragView];
    [self.dragView addSubview:self.closeButton];
    [self.dragView addSubview:self.submitBugButton];
    [self.dragView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_offset(-20);
        make.leading.mas_offset(20);
        make.size.mas_equalTo(CGSizeMake(55, 96));
    }];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.dragView);
        make.bottom.equalTo(self.dragView);
        make.size.mas_equalTo(CGSizeMake(36, 36));
    }];
    [self.submitBugButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(self.dragView);
        make.height.mas_equalTo(55);
    }];
}

- (void)showBugNoteView {
    UIImage *screenImage = [self getCurrentViewImage];
    GlobalegrowSubmitNoteView *noteView = [[GlobalegrowSubmitNoteView alloc] initWithFrame:CGRectZero];
    __weak typeof(self) weakSelf = self;
    noteView.didClickCancelButtonBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [noteView removeFromSuperview];
        strongSelf.dragView.hidden = NO;
    };
    noteView.didClickSubmitNoteButtonClick = ^(NSString * _Nonnull note) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [noteView removeFromSuperview];
        [[GlobalegrowBugTag shareGlobalegrowBugTag] submitBugNote:note isException:NO];
        strongSelf.dragView.hidden = NO;
    };
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (![window isMemberOfClass:[UIWindow class]]) {
        return;
    }
    [window addSubview:noteView];
    [noteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(window);
    }];
}

- (void)closeBugTag {
    [self closeButtonClick];
}

- (void)closeButtonClick {
    self.dragView.hidden = YES;
}

- (void)submitBugButtonClick {
    [self closeBugTag];
    [self showBugNoteView];
}

#pragma mark - Getter
- (WMDragView *)dragView {
    if (!_dragView) {
        _dragView = [[WMDragView alloc] initWithFrame:CGRectZero];
        _dragView.backgroundColor = [UIColor clearColor];
        __weak typeof(self) weakSelf = self;
        _dragView.clickDragViewBlock = ^(WMDragView *dragView) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf submitBugButtonClick];
        };
    }
    return _dragView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage globalegrow_ImageName:@"btg_icon_cancel"]
                      forState:UIControlStateNormal];
        [_closeButton addTarget:self
                         action:@selector(closeButtonClick)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIButton *)submitBugButton {
    if (!_submitBugButton) {
        _submitBugButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_submitBugButton setImage:[UIImage globalegrow_ImageName:@"btg_icon_assistivebutton_submit"]
                          forState:UIControlStateNormal];
        [_submitBugButton addTarget:self action:@selector(submitBugButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitBugButton;
}

- (UIImage *)getCurrentViewImage {
    UIImage *image;
    UIView *view = [UIApplication sharedApplication].keyWindow;
    CGRect screenCaptureRect = view.bounds;
    UIGraphicsBeginImageContextWithOptions(screenCaptureRect.size, NO, 0.0f);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
