//
//  ATAMPSCustomInterstitialAdapter.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//
// HJC: 按照文档实现插屏广告适配器实现文件

#import "ATAMPSCustomInterstitialAdapter.h"
#import "../Base/ATAMPSCustomInitAdapter.h"
#import "ATAMPSCustomInterstitialDelegate.h"
#import "../ATAMPSCustomBiddingRequest.h"
#import "../ATAMPSC2SBiddingRequestManager.h"
#import <AMPSAdSDK/AMPSAdSDK.h>

// HJC: ATAMPS 插屏广告适配器实现
@interface ATAMPSCustomInterstitialAdapter ()

// HJC: 添加属性
@property (nonatomic, strong) ATAMPSCustomInterstitialDelegate *interstitialDelegate;
@property (nonatomic, strong) AMPSInterstitialAd *interstitialAd;

@end

@implementation ATAMPSCustomInterstitialAdapter

#pragma mark - lazy
// HJC: 懒加载初始化 interstitialDelegate
- (ATAMPSCustomInterstitialDelegate *)interstitialDelegate {
    if (_interstitialDelegate == nil) {
        _interstitialDelegate = [[ATAMPSCustomInterstitialDelegate alloc] init];
        _interstitialDelegate.adStatusBridge = self.adStatusBridge;
    }
    return _interstitialDelegate;
}

#pragma mark - Ad load
// HJC: 实现广告加载方法
- (void)loadADWithArgument:(ATAdMediationArgument *)argument {
    // AAAAA: 这是非竞价模式（普通加载）
    // 竞价/非竞价是在 TopOn 后台配置的：
    // - 非竞价：TopOn SDK 会调用此方法 loadADWithArgument:
    // - 竞价（C2S）：TopOn SDK 会调用 bidRequestWithPlacementModel:unitGroupModel:info:completion:
    // 如需测试竞价，请在 TopOn 后台将广告源配置为竞价模式
    NSLog(@"HJC测试: ATAMPSCustomInterstitialAdapter loadADWithArgument 被调用（这是非竞价模式）");
    
    NSDictionary *serverInfo = argument.serverContentDic;
    NSDictionary *localInfo = argument.localInfoDic ?: @{};
    
    NSLog(@"HJC测试: 加载广告时的 serverInfo = %@", serverInfo);
    
    // HJC: 检查 serverInfo 有效性
    if (!serverInfo || ![serverInfo isKindOfClass:[NSDictionary class]]) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain 
                                             code:ATAdErrorCodeThirdPartySDKNotImportedProperly 
                                         userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial.", 
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
                                         userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial.", 
                                                   NSLocalizedFailureReasonErrorKey:@"UnitID missing in server info."}];
        if (self.adStatusBridge) {
            [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
        }
        return;
    }
    
    // HJC: 初始化 interstitialDelegate（确保 adStatusBridge 已设置）
    self.interstitialDelegate = [self interstitialDelegate];
    self.interstitialDelegate.adStatusBridge = self.adStatusBridge;
    self.interstitialDelegate.serverInfo = serverInfo;
    self.interstitialDelegate.localInfo = localInfo;
    self.interstitialDelegate.spaceId = unitID;
    
    // HJC: timeout 从服务器配置获取，单位是毫秒
    NSTimeInterval timeout = [serverInfo[@"timeout"] doubleValue] > 0 ? [serverInfo[@"timeout"] doubleValue] : 5000;
    
    NSLog(@"HJC测试: 开始创建广告对象并加载，unitID = %@, timeout = %.0f 毫秒", unitID, timeout);
    
    // HJC: 创建广告对象并加载
    dispatch_async(dispatch_get_main_queue(), ^{
        AMPSAdConfiguration *adConfig = [[AMPSAdConfiguration alloc] init];
        adConfig.spaceId = unitID;
        adConfig.timeoutInterval = timeout;
        
        NSLog(@"HJC测试: 创建 AMPSInterstitialAd，spaceId = %@, timeoutInterval = %.0f 毫秒", adConfig.spaceId, adConfig.timeoutInterval);
        
        self.interstitialAd = [[AMPSInterstitialAd alloc] initWithAdConfiguration:adConfig];
        self.interstitialAd.delegate = self.interstitialDelegate;
        
        NSLog(@"HJC测试: 调用 loadInterstitialAd");
        [self.interstitialAd loadInterstitialAd];
    });
}

#pragma mark - Ad show
// HJC: 实现广告展示方法
- (void)showInterstitialInViewController:(UIViewController *)viewController {
    NSLog(@"HJC测试: showInterstitialInViewController 被调用，viewController = %@", viewController);
    
    if (self.interstitialAd && viewController) {
        [self.interstitialAd showInterstitialAdWithRootViewController:viewController];
    } else {
        NSLog(@"HJC测试: ⚠️ 无法展示广告，interstitialAd = %@, viewController = %@", self.interstitialAd, viewController);
    }
}

// HJC: 实现广告准备状态检查方法
- (BOOL)adReadyInterstitialWithInfo:(NSDictionary *)info {
    NSLog(@"HJC测试: adReadyInterstitialWithInfo 被调用，info = %@", info);
    NSLog(@"HJC测试: self.interstitialAd = %@", self.interstitialAd);
    
    BOOL ready = (self.interstitialAd != nil);
    
    NSLog(@"HJC测试: adReadyInterstitialWithInfo 返回 %@", ready ? @"YES" : @"NO");
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
    NSLog(@"HJC测试: ATAMPSCustomInterstitialAdapter bidRequestWithPlacementModel 被调用（这是 C2S 竞价模式）");
    
    ATAMPSCustomInterstitialDelegate *customDelegate = [[ATAMPSCustomInterstitialDelegate alloc] initWithInfo:info localInfo:info];
    customDelegate.isC2SBiding = YES;
    customDelegate.spaceId = info[@"unitid"];
    
    ATAMPSC2SBiddingRequestManager *biddingManage = [ATAMPSC2SBiddingRequestManager sharedInstance];
    ATAMPSCustomBiddingRequest *request = [ATAMPSCustomBiddingRequest new];
    request.unitGroup = unitGroupModel;
    request.placementID = placementModel.placementID;
    request.bidCompletion = completion;
    request.unitID = info[@"unitid"];
    request.extraInfo = info;
    request.adType = ATAMPSAdFormatInterstitial;
    request.customEvent = customDelegate;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        AMPSAdConfiguration *adConfig = [[AMPSAdConfiguration alloc] init];
        adConfig.spaceId = info[@"unitid"];
        adConfig.timeoutInterval = [info[@"timeout"] doubleValue] > 0 ? [info[@"timeout"] doubleValue] : 5000;
        
        AMPSInterstitialAd *interstitial = [[AMPSInterstitialAd alloc] initWithAdConfiguration:adConfig];
        request.customObject = interstitial;
        [biddingManage startWithRequestItem:request];
        interstitial.delegate = customDelegate;
        [interstitial loadInterstitialAd];
    });
}

// HJC: 发送竞价成功通知
+ (void)sendWinnerNotifyWithCustomObject:(id)customObject 
                              secondPrice:(NSString*)price 
                                 userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    AMPSInterstitialAd *ampsInterstitial = (AMPSInterstitialAd *)customObject;
    NSMutableDictionary *winInfo = [[NSMutableDictionary alloc] init];
    [winInfo setObject:[NSString stringWithFormat:@"%ld", (long)[ampsInterstitial eCPM]] forKey:@"AMPS_WIN_PRICE"];
    [winInfo setObject:@"9999" forKey:@"AMPS_WIN_ADNID"];
    
    if (price && price.length > 0) {
        [winInfo setObject:price forKey:@"AMPS_HIGHRST_LOSS_PRICE"];
    } else {
        [winInfo setObject:@"0" forKey:@"AMPS_HIGHRST_LOSS_PRICE"];
    }
    
    [ampsInterstitial sendWinNotificationWithInfo:winInfo];
}

// HJC: 发送竞价失败通知
+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject 
                               lossType:(ATBiddingLossType)lossType 
                                winPrice:(nonnull NSString *)price 
                                userInfo:(NSDictionary *)userInfo {
    AMPSInterstitialAd *ampsInterstitial = (AMPSInterstitialAd *)customObject;
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
    
    [ampsInterstitial sendLossNotificationWithInfo:lossInfo];
}

#pragma mark - C2S Bidding Result
// HJC: 按照 C2S 竞价文档，实现 didReceiveBidResult: 处理竞价结果
- (void)didReceiveBidResult:(ATBidWinLossResult *)result {
    NSLog(@"HJC测试: didReceiveBidResult 被调用，bidResultType = %ld", (long)result.bidResultType);
    
    if (result.bidResultType == ATBidWinLossResultTypeWin) {
        NSLog(@"HJC测试: ✅ 竞价成功，winPrice = %@", result.winPrice);
    } else if (result.bidResultType == ATBidWinLossResultTypeLoss) {
        NSLog(@"HJC测试: ❌ 竞价失败，lossReasonType = %ld", (long)result.lossReasonType);
    }
}

@end

