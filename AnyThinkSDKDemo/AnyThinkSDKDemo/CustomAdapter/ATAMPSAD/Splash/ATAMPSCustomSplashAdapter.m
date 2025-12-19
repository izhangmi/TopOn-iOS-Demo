//
//  ATAMPSCustomSplashAdapter.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//
// HJC: 按照文档 https://help.takuad.com/docs/UpnVkNF1 实现
// HJC: 开屏广告适配器实现文件

#import "ATAMPSCustomSplashAdapter.h"
#import "../Base/ATAMPSCustomInitAdapter.h"
#import "ATAMPSCustomSplashDelegate.h"
#import "../ATAMPSCustomBiddingRequest.h"
#import "../ATAMPSC2SBiddingRequestManager.h"
#import <AMPSAdSDK/AMPSAdSDK.h>

// HJC: ATAMPS 开屏广告适配器实现
// HJC: 按照文档 4.4 实现
@interface ATAMPSCustomSplashAdapter ()

// HJC: 按照文档 4.4，添加属性
@property (nonatomic, strong) ATAMPSCustomSplashDelegate *splashDelegate;
@property (nonatomic, strong) AMPSSplashAd *splashAd;

@end

@implementation ATAMPSCustomSplashAdapter

#pragma mark - lazy
// HJC: 按照文档 4.4，懒加载初始化 splashDelegate
- (ATAMPSCustomSplashDelegate *)splashDelegate {
    if (_splashDelegate == nil) {
        _splashDelegate = [[ATAMPSCustomSplashDelegate alloc] init];
        _splashDelegate.adStatusBridge = self.adStatusBridge;
    }
    return _splashDelegate;
}

#pragma mark - Ad load
// HJC: 按照文档 2，实现广告加载方法
// HJC: 开发者调用广告加载 API 时，会调用到自定义 Adapter 的 loadADWithArgument: 方法
- (void)loadADWithArgument:(ATAdMediationArgument *)argument {
    // AAAAA: 这是非竞价模式（普通加载）
    // 竞价/非竞价是在 TopOn 后台配置的：
    // - 非竞价：TopOn SDK 会调用此方法 loadADWithArgument:
    // - 竞价（C2S）：TopOn SDK 会调用 bidRequestWithPlacementModel:unitGroupModel:info:completion:
    // 如需测试竞价，请在 TopOn 后台将广告源配置为竞价模式
    NSLog(@"HJC测试: ATAMPSCustomSplashAdapter loadADWithArgument 被调用（这是非竞价模式）");
    
    NSDictionary *serverInfo = argument.serverContentDic;
    NSDictionary *localInfo = argument.localInfoDic ?: @{};
    
    NSLog(@"HJC测试: 加载广告时的 serverInfo = %@", serverInfo);
    
    // HJC: 检查 serverInfo 有效性
    if (!serverInfo || ![serverInfo isKindOfClass:[NSDictionary class]]) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain 
                                             code:ATAdErrorCodeThirdPartySDKNotImportedProperly 
                                         userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", 
                                                   NSLocalizedFailureReasonErrorKey:@"Invalid server info."}];
        if (self.adStatusBridge) {
            [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
        }
        return;
    }
    
    NSString *unitID = serverInfo[@"unitid"];
    NSLog(@"HJC测试: 获取 unitID = %@", unitID);
    
    if (!unitID || unitID.length == 0) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain 
                                             code:ATAdErrorCodeThirdPartySDKNotImportedProperly 
                                         userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", 
                                                   NSLocalizedFailureReasonErrorKey:@"UnitID missing in server info."}];
        if (self.adStatusBridge) {
            [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
        }
        return;
    }
    
    // HJC: 初始化 splashDelegate（确保 adStatusBridge 已设置）
    self.splashDelegate = [self splashDelegate];
    self.splashDelegate.adStatusBridge = self.adStatusBridge;
    self.splashDelegate.serverInfo = serverInfo;
    self.splashDelegate.localInfo = localInfo;
    self.splashDelegate.spaceId = unitID;
    
    // HJC: 设置 containerView（如果有）
    if (localInfo[kATSplashExtraContainerViewKey]) {
        self.splashDelegate.containerView = localInfo[kATSplashExtraContainerViewKey];
        NSLog(@"HJC测试: 设置 containerView = %@", self.splashDelegate.containerView);
    }
    
    // HJC: timeout 从服务器配置获取，单位是毫秒
    NSTimeInterval timeout = [serverInfo[@"timeout"] doubleValue] > 0 ? [serverInfo[@"timeout"] doubleValue] : 5000;
    
    NSLog(@"HJC测试: 开始创建广告对象并加载，unitID = %@, timeout = %.0f 毫秒", unitID, timeout);
    
    // HJC: 创建广告对象并加载
    dispatch_async(dispatch_get_main_queue(), ^{
        AMPSAdConfiguration *adConfig = [[AMPSAdConfiguration alloc] init];
        adConfig.spaceId = unitID;
        adConfig.timeoutInterval = timeout;
        
        NSLog(@"HJC测试: 创建 AMPSSplashAd，spaceId = %@, timeoutInterval = %.0f 毫秒", adConfig.spaceId, adConfig.timeoutInterval);
        
        self.splashAd = [[AMPSSplashAd alloc] initWithAdConfiguration:adConfig];
        self.splashAd.delegate = self.splashDelegate;
        
        NSLog(@"HJC测试: 调用 loadSplashAd");
        [self.splashAd loadSplashAd];
    });
}

#pragma mark - Ad show
// HJC: 按照文档 2，实现广告展示方法
// HJC: 开发者调用广告展示 API 时，会调用到自定义 Adapter 的 showSplashAdInWindow:inViewController:parameter: 方法
- (void)showSplashAdInWindow:(UIWindow *)window inViewController:(UIViewController *)inViewController parameter:(NSDictionary *)parameter {
    NSLog(@"HJC测试: showSplashAdInWindow 被调用，window = %@, inViewController = %@", window, inViewController);
    if (self.splashAd && window) {
        // HJC: 检查是否有底部视图
        if (self.splashDelegate.containerView) {
            NSLog(@"HJC测试: 展示开屏广告，带底部视图");
            [self.splashAd showSplashViewInWindow:window bottomView:self.splashDelegate.containerView];
        } else {
            NSLog(@"HJC测试: 展示开屏广告，不带底部视图");
            [self.splashAd showSplashViewInWindow:window];
        }
    } else {
        NSLog(@"HJC测试: ⚠️ 无法展示广告，splashAd = %@, window = %@", self.splashAd, window);
    }
}
 
// HJC: 按照文档 2，实现广告准备状态检查方法
// HJC: 开发者调用广告准备状态检查 API 时，会调用到自定义 Adapter 的 adReadySplashWithInfo: 方法
- (BOOL)adReadySplashWithInfo:(NSDictionary *)info {
    NSLog(@"HJC测试: adReadySplashWithInfo 被调用，info = %@", info);
    NSLog(@"HJC测试: self.splashAd = %@", self.splashAd);
    
    BOOL ready = (self.splashAd != nil);
    
    NSLog(@"HJC测试: adReadySplashWithInfo 返回 %@", ready ? @"YES" : @"NO");
    return ready;
}

#pragma mark - C2S Bidding
// HJC: 按照 C2S 竞价文档 https://help.takuad.com/docs/9IQVOUk5，实现竞价请求类方法
+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel 
                       unitGroupModel:(ATUnitGroupModel*)unitGroupModel 
                                 info:(NSDictionary*)info 
                           completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    // AAAAA: 这是竞价模式（C2S Bidding）
    // 竞价/非竞价是在 TopOn 后台配置的：
    // - 非竞价：TopOn SDK 会调用 loadADWithArgument: 方法
    // - 竞价（C2S）：TopOn SDK 会调用此方法 bidRequestWithPlacementModel:unitGroupModel:info:completion:
    // 如需测试非竞价，请在 TopOn 后台将广告源配置为非竞价模式
    NSLog(@"HJC测试: ATAMPSCustomSplashAdapter bidRequestWithPlacementModel 被调用（这是 C2S 竞价模式）");
    
    // HJC: 检查 SDK 是否初始化（通过 InitAdapter 处理，这里不做初始化）
    // HJC: SDK 初始化应该由 ATAMPSCustomInitAdapter 统一管理
    
    NSDate *curDate = [NSDate date];
    ATAMPSCustomSplashDelegate *customDelegate = [[ATAMPSCustomSplashDelegate alloc] initWithInfo:info localInfo:info];
    customDelegate.isC2SBiding = YES;
    customDelegate.spaceId = info[@"unitid"];
    NSTimeInterval tolerateTimeout = [info[@"timeout"] doubleValue] > 0 ? [info[@"timeout"] doubleValue] / 1000.0 : 5.0;
    customDelegate.expireDate = [curDate dateByAddingTimeInterval:tolerateTimeout];
    if (info[kATSplashExtraContainerViewKey]) {
        customDelegate.containerView = info[kATSplashExtraContainerViewKey];
    }
    
    ATAMPSC2SBiddingRequestManager *biddingManage = [ATAMPSC2SBiddingRequestManager sharedInstance];
    ATAMPSCustomBiddingRequest *request = [ATAMPSCustomBiddingRequest new];
    request.unitGroup = unitGroupModel;
    request.placementID = placementModel.placementID;
    request.bidCompletion = completion;
    request.unitID = info[@"unitid"];
    request.extraInfo = info;
    request.adType = ATAMPSAdFormatSplash;
    request.customEvent = customDelegate; // HJC: 使用 customEvent 字段存储 delegate
    
    dispatch_async(dispatch_get_main_queue(), ^{
        AMPSAdConfiguration *adConfig = [[AMPSAdConfiguration alloc] init];
        adConfig.spaceId = info[@"unitid"];
        adConfig.timeoutInterval = [info[@"timeout"] doubleValue] > 0 ? [info[@"timeout"] doubleValue] : 5000;
        
        AMPSSplashAd *splash = [[AMPSSplashAd alloc] initWithAdConfiguration:adConfig];
        request.customObject = splash;
        [biddingManage startWithRequestItem:request];
        splash.delegate = customDelegate;
        [splash loadSplashAd];
    });
}

// HJC: 发送竞价成功通知
+ (void)sendWinnerNotifyWithCustomObject:(id)customObject 
                              secondPrice:(NSString*)price 
                                 userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    AMPSSplashAd *ampsSplash = (AMPSSplashAd *)customObject;
    NSMutableDictionary *winInfo = [[NSMutableDictionary alloc] init];
    [winInfo setObject:[NSString stringWithFormat:@"%ld", (long)[ampsSplash eCPM]] forKey:@"AMPS_WIN_PRICE"];
    [winInfo setObject:@"9999" forKey:@"AMPS_WIN_ADNID"];
    
    if (price && price.length > 0) {
        [winInfo setObject:price forKey:@"AMPS_HIGHRST_LOSS_PRICE"];
    } else {
        [winInfo setObject:@"0" forKey:@"AMPS_HIGHRST_LOSS_PRICE"];
    }
    
    [ampsSplash sendWinNotificationWithInfo:winInfo];
}

// HJC: 发送竞价失败通知
+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject 
                               lossType:(ATBiddingLossType)lossType 
                                winPrice:(nonnull NSString *)price 
                                userInfo:(NSDictionary *)userInfo {
    AMPSSplashAd *ampsSplash = (AMPSSplashAd *)customObject;
    NSMutableDictionary *lossInfo = [[NSMutableDictionary alloc] init];
    
    if (price && price.length > 0) {
        [lossInfo setObject:price forKey:@"AMPS_WIN_PRICE"];
    } else {
        [lossInfo setObject:@"0" forKey:@"AMPS_WIN_PRICE"];
    }
    [lossInfo setObject:@"9999" forKey:@"AMPS_WIN_ADNID"];
    
    if (lossType == ATBiddingLossWithLowPriceInNormal || lossType == ATBiddingLossWithLowPriceInHB) {
        [lossInfo setObject:@"1" forKey:@"AMPS_LOSS_REASON"];
    } else if (lossType == ATBiddingLossWithBiddingTimeOut) {
        [lossInfo setObject:@"2" forKey:@"AMPS_LOSS_REASON"];
    } else {
        [lossInfo setObject:@"999" forKey:@"AMPS_LOSS_REASON"];
    }
    
    [ampsSplash sendLossNotificationWithInfo:lossInfo];
}

#pragma mark - C2S Bidding Result
// HJC: 按照 C2S 竞价文档 https://help.takuad.com/docs/9IQVOUk5，实现 didReceiveBidResult: 处理竞价结果
- (void)didReceiveBidResult:(ATBidWinLossResult *)result {
    NSLog(@"HJC测试: didReceiveBidResult 被调用，bidResultType = %ld", (long)result.bidResultType);
    
    if (result.bidResultType == ATBidWinLossResultTypeWin) {
        NSLog(@"HJC测试: ✅ 竞价成功，winPrice = %@", result.winPrice);
    } else if (result.bidResultType == ATBidWinLossResultTypeLoss) {
        NSLog(@"HJC测试: ❌ 竞价失败，lossReasonType = %ld", (long)result.lossReasonType);
    }
}

@end

