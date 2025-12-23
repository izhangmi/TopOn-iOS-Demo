//
//  ATAMPSCustomInterstitialAdapter.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import "ATAMPSCustomInterstitialAdapter.h"
#import "../Base/ATAMPSCustomInitAdapter.h"
#import "ATAMPSCustomInterstitialDelegate.h"
#import "../Bidding/ATAMPSCustomBiddingRequest.h"
#import "../Bidding/ATAMPSC2SBiddingRequestManager.h"
#import <AMPSAdSDK/AMPSAdSDK.h>

@interface ATAMPSCustomInterstitialAdapter ()

@property (nonatomic, strong) ATAMPSCustomInterstitialDelegate *interstitialDelegate;
@property (nonatomic, strong) AMPSInterstitialAd *interstitialAd;

@end

@implementation ATAMPSCustomInterstitialAdapter

#pragma mark - lazy
- (ATAMPSCustomInterstitialDelegate *)interstitialDelegate {
    if (_interstitialDelegate == nil) {
        _interstitialDelegate = [[ATAMPSCustomInterstitialDelegate alloc] init];
        _interstitialDelegate.adStatusBridge = self.adStatusBridge;
    }
    return _interstitialDelegate;
}

#pragma mark - Ad load
// AAAAA: 这是非竞价模式（普通加载）
- (void)loadADWithArgument:(ATAdMediationArgument *)argument {
    NSDictionary *serverInfo = argument.serverContentDic;
    NSDictionary *localInfo = argument.localInfoDic ?: @{};
    
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
    
    self.interstitialDelegate = [self interstitialDelegate];
    self.interstitialDelegate.adStatusBridge = self.adStatusBridge;
    self.interstitialDelegate.serverInfo = serverInfo;
    self.interstitialDelegate.localInfo = localInfo;
    self.interstitialDelegate.spaceId = unitID;
    
    // 设置 networkUnitId，TopOn SDK 需要此信息才能正确统计数据
    if (self.adStatusBridge && unitID) {
        [self.adStatusBridge setNetworkUnitId:unitID];
    }
    
    NSTimeInterval timeout = [serverInfo[@"timeout"] doubleValue] > 0 ? [serverInfo[@"timeout"] doubleValue] : 5000;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        AMPSAdConfiguration *adConfig = [[AMPSAdConfiguration alloc] init];
        adConfig.spaceId = unitID;
        adConfig.timeoutInterval = timeout;
        
        self.interstitialAd = [[AMPSInterstitialAd alloc] initWithAdConfiguration:adConfig];
        self.interstitialAd.delegate = self.interstitialDelegate;
        [self.interstitialAd loadInterstitialAd];
    });
}

#pragma mark - Ad show
- (void)showInterstitialInViewController:(UIViewController *)viewController {
    if (self.interstitialAd && viewController) {
        [self.interstitialAd showInterstitialAdWithRootViewController:viewController];
    }
}

- (BOOL)adReadyInterstitialWithInfo:(NSDictionary *)info {
    return (self.interstitialAd != nil);
}

#pragma mark - C2S Bidding
// AAAAA: 这是竞价模式（C2S Bidding）
+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel 
                       unitGroupModel:(ATUnitGroupModel*)unitGroupModel 
                                 info:(NSDictionary*)info 
                           completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
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
- (void)didReceiveBidResult:(ATBidWinLossResult *)result {
}

@end

