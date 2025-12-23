//
//  ATAMPSCustomSplashAdapter.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import "ATAMPSCustomSplashAdapter.h"
#import "../Base/ATAMPSCustomInitAdapter.h"
#import "ATAMPSCustomSplashDelegate.h"
#import "../Bidding/ATAMPSCustomBiddingRequest.h"
#import "../Bidding/ATAMPSC2SBiddingRequestManager.h"
#import <AMPSAdSDK/AMPSAdSDK.h>

@interface ATAMPSCustomSplashAdapter ()

@property (nonatomic, strong) ATAMPSCustomSplashDelegate *splashDelegate;
@property (nonatomic, strong) AMPSSplashAd *splashAd;

@end

@implementation ATAMPSCustomSplashAdapter

#pragma mark - lazy
- (ATAMPSCustomSplashDelegate *)splashDelegate {
    if (_splashDelegate == nil) {
        _splashDelegate = [[ATAMPSCustomSplashDelegate alloc] init];
        _splashDelegate.adStatusBridge = self.adStatusBridge;
    }
    return _splashDelegate;
}

#pragma mark - Ad load
// AAAAA: 这是非竞价模式（普通加载）
- (void)loadADWithArgument:(ATAdMediationArgument *)argument {
    NSDictionary *serverInfo = argument.serverContentDic;
    NSDictionary *localInfo = argument.localInfoDic ?: @{};
    
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
    
    self.splashDelegate = [self splashDelegate];
    self.splashDelegate.adStatusBridge = self.adStatusBridge;
    self.splashDelegate.serverInfo = serverInfo;
    self.splashDelegate.localInfo = localInfo;
    self.splashDelegate.spaceId = unitID;
    
    // 设置 networkUnitId，TopOn SDK 需要此信息才能正确统计数据
    if (self.adStatusBridge && unitID) {
        [self.adStatusBridge setNetworkUnitId:unitID];
    }
    
    if (localInfo[kATSplashExtraContainerViewKey]) {
        self.splashDelegate.containerView = localInfo[kATSplashExtraContainerViewKey];
    }
    
    NSTimeInterval timeout = [serverInfo[@"timeout"] doubleValue] > 0 ? [serverInfo[@"timeout"] doubleValue] : 5000;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        AMPSAdConfiguration *adConfig = [[AMPSAdConfiguration alloc] init];
        adConfig.spaceId = unitID;
        adConfig.timeoutInterval = timeout;
        
        self.splashAd = [[AMPSSplashAd alloc] initWithAdConfiguration:adConfig];
        self.splashAd.delegate = self.splashDelegate;
        [self.splashAd loadSplashAd];
    });
}

#pragma mark - Ad show
- (void)showSplashAdInWindow:(UIWindow *)window inViewController:(UIViewController *)inViewController parameter:(NSDictionary *)parameter {
    if (self.splashAd && window) {
        if (self.splashDelegate.containerView) {
            [self.splashAd showSplashViewInWindow:window bottomView:self.splashDelegate.containerView];
        } else {
            [self.splashAd showSplashViewInWindow:window];
        }
    }
}
 
- (BOOL)adReadySplashWithInfo:(NSDictionary *)info {
    return (self.splashAd != nil);
}

#pragma mark - C2S Bidding
// AAAAA: 这是竞价模式（C2S Bidding）
+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel 
                       unitGroupModel:(ATUnitGroupModel*)unitGroupModel 
                                 info:(NSDictionary*)info 
                           completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
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
    request.customEvent = customDelegate;
    
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
- (void)didReceiveBidResult:(ATBidWinLossResult *)result {
    
}

@end

