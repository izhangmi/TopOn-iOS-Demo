//
//  ATAMPSInterstitialCustomAdapter.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import "ATAMPSInterstitialCustomAdapter.h"
#import "ATAMPSInterstitialCustomEvent.h"
#import "ATAMPSCustomBiddingRequest.h"
#import "ATAMPSC2SBiddingRequestManager.h"
#import <AnyThinkInterstitial/AnyThinkInterstitial.h>
#import <AMPSAdSDK/AMPSAdSDK.h>

// HJC: AMPSAd Interstitial 广告自定义适配器实现
@interface ATAMPSInterstitialCustomAdapter () <ATAdAdapter>

@property (nonatomic, strong) ATAMPSInterstitialCustomEvent *customEvent;

@property (nonatomic, strong) AMPSInterstitialAd *interstitialAd;

@end

@implementation ATAMPSInterstitialCustomAdapter

// HJC: 初始化适配器，配置 SDK
- (instancetype)initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        // HJC: 检查是否已初始化，避免重复初始化
        if (![[ATAPI sharedInstance] initFlagForNetwork:@"AMPS"]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:@"AMPS"];
            [[ATAPI sharedInstance] setVersion:[AMPSAdSDKManager sdkVersion] forNetwork:@"AMPS"];
            // HJC: 配置个性化推荐
            AMPSAdSDKConfiguration *config = [[AMPSAdSDKConfiguration alloc] init];
            if ([[ATAPI sharedInstance] getPersonalizedAdState] == 2) {
                config.recommend = kAMPSPersonalizedRecommendStateClose;
            } else {
                config.recommend = kAMPSPersonalizedRecommendStateOpen;
            }
            
            // HJC: 异步初始化 SDK
            NSString *appId = serverInfo[@"appid"];
            if (appId && appId.length > 0) {
                [[AMPSAdSDKManager sharedInstance] startAsyncWithAppId:appId configuration:config results:^(AMPSAdSDKInitStatus statusResult) {
                    // HJC: 初始化状态回调处理
                }];
            }
        }
    }
    return self;
}

// HJC: 加载广告
- (void)loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    NSTimeInterval tolerateTimeout = [serverInfo[@"timeout"] integerValue] > 0 ? [serverInfo[@"timeout"] integerValue] : 5000;
    NSDate *curDate = [NSDate date];
    _customEvent = [[ATAMPSInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    _customEvent.expireDate = [curDate dateByAddingTimeInterval:tolerateTimeout];
    
    // HJC: 检查 serverInfo 有效性
    if (!serverInfo || ![serverInfo isKindOfClass:[NSDictionary class]]) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial.", NSLocalizedFailureReasonErrorKey:@"Invalid server info."}];
        [_customEvent trackInterstitialAdLoadFailed:error];
        return;
    }
    
    // HJC: 安全获取 unitid
    NSString *unitID = [serverInfo objectForKey:@"unitid"];
    if (!unitID || unitID.length == 0) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial.", NSLocalizedFailureReasonErrorKey:@"UnitID missing in server info."}];
        [_customEvent trackInterstitialAdLoadFailed:error];
        return;
    }
    
    // HJC: 检查是否有竞价请求
    ATAMPSCustomBiddingRequest *request = [[ATAMPSC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:unitID];
    if (request != nil) {
        if (request.customObject) {
            self.interstitialAd = request.customObject;
            self.interstitialAd.delegate = _customEvent;
            [_customEvent trackInterstitialAdLoaded:self.interstitialAd adExtra:@{}];
        } else {
            // HJC: 竞价失败
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial.", NSLocalizedFailureReasonErrorKey:@"It took too long to load placement strategy."}];
            [_customEvent trackInterstitialAdLoadFailed:error];
        }
        // HJC: 移除请求项
        [[ATAMPSC2SBiddingRequestManager sharedInstance] removeRequestItemWithUnitID:unitID];
    } else {
        // HJC: 普通请求，创建广告对象并加载
        dispatch_async(dispatch_get_main_queue(), ^{
            AMPSAdConfiguration *adConfig = [[AMPSAdConfiguration alloc] init];
            adConfig.spaceId = unitID;
            adConfig.timeoutInterval = tolerateTimeout;
            
            self.interstitialAd = [[AMPSInterstitialAd alloc] initWithAdConfiguration:adConfig];
            self.interstitialAd.delegate = self.customEvent;
            [self.interstitialAd loadInterstitialAd];
        });
    }
}

// HJC: 检查广告是否准备好
+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    AMPSInterstitialAd *interstitial = customObject;
    return interstitial ? YES : NO;
}

// HJC: 检查是否支持该广告类型
+ (BOOL)isSupportAdType:(nonnull ATUnitGroupModel *)unitGroupModel {
    return YES;
}

// HJC: 展示插屏广告
+ (void)showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    AMPSInterstitialAd *interstitialAd = interstitial.customObject;
    interstitial.customEvent.delegate = delegate;
    [interstitialAd showInterstitialAdWithRootViewController:viewController];
}

#pragma mark - Header bidding
#pragma mark - c2s
// HJC: 竞价请求
+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    // HJC: 检查 SDK 是否初始化
    if (![[ATAPI sharedInstance] initFlagForNetwork:@"AMPS"]) {
        [[ATAPI sharedInstance] setInitFlagForNetwork:@"AMPS"];
        [[ATAPI sharedInstance] setVersion:[AMPSAdSDKManager sdkVersion] forNetwork:@"AMPS"];
        
        AMPSAdSDKConfiguration *config = [[AMPSAdSDKConfiguration alloc] init];
        if ([[ATAPI sharedInstance] getPersonalizedAdState] == 2) {
            config.recommend = kAMPSPersonalizedRecommendStateClose;
        } else {
            config.recommend = kAMPSPersonalizedRecommendStateOpen;
        }
        
        NSString *appId = info[@"appid"];
        if (appId && appId.length > 0) {
            [[AMPSAdSDKManager sharedInstance] startAsyncWithAppId:appId configuration:config results:^(AMPSAdSDKInitStatus statusResult) {
                // HJC: 初始化状态回调
            }];
        }
    }
    
    NSDate *curDate = [NSDate date];
    ATAMPSInterstitialCustomEvent *customEvent = [[ATAMPSInterstitialCustomEvent alloc] initWithInfo:info localInfo:info];
    customEvent.isC2SBiding = YES;
    customEvent.spaceId = info[@"unitid"];
    NSTimeInterval tolerateTimeout = [info[@"timeout"] integerValue] > 0 ? [info[@"timeout"] integerValue] : 5000;
    customEvent.expireDate = [curDate dateByAddingTimeInterval:tolerateTimeout];
    
    ATAMPSC2SBiddingRequestManager *biddingManage = [ATAMPSC2SBiddingRequestManager sharedInstance];
    ATAMPSCustomBiddingRequest *request = [ATAMPSCustomBiddingRequest new];
    request.unitGroup = unitGroupModel;
    request.placementID = placementModel.placementID;
    request.bidCompletion = completion;
    request.unitID = info[@"unitid"];
    request.extraInfo = info;
    request.adType = AMPSAdFormatInterstitial;
    request.customEvent = customEvent;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        AMPSAdConfiguration *adConfig = [[AMPSAdConfiguration alloc] init];
        adConfig.spaceId = info[@"unitid"];
        adConfig.timeoutInterval = tolerateTimeout;
        
        AMPSInterstitialAd *interstitial = [[AMPSInterstitialAd alloc] initWithAdConfiguration:adConfig];
        request.customObject = interstitial;
        [biddingManage startWithRequestItem:request];
        interstitial.delegate = customEvent;
        [interstitial loadInterstitialAd];
    });
}

// HJC: 发送竞价成功通知
+ (void)sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
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
+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
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

@end

