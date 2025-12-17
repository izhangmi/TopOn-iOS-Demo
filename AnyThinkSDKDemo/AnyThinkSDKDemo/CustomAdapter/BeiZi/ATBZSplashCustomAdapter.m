//
//  ATBZSplashAdapter.m
//  AnyThinkSDKDemo
//
//  Created by nie adhub on 2023/10/23.
//  Copyright © 2023 抽筋的灯. All rights reserved.
//

#import "ATBZSplashCustomAdapter.h"
#import "ATBZSplashCustomEvent.h"
#import "ATBZCustomBiddingRequest.h"
#import "ATBZC2SBiddingRequestManager.h"
#import <AnyThinkSplash/AnyThinkSplash.h>

@interface ATBZSplashCustomAdapter () <ATAdAdapter>

@property (nonatomic, strong) ATBZSplashCustomEvent *customEvent;

@property (nonatomic, strong) BeiZiSplash *splashAd;

@end

@implementation ATBZSplashCustomAdapter

- (instancetype)initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        if (![[ATAPI sharedInstance] initFlagForNetwork:@"BZ"]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:@"BZ"];
            [[ATAPI sharedInstance] setVersion:[BeiZiSDKManager sdkVersion] forNetwork:@"BZ"];
            if ([[ATAPI sharedInstance] getPersonalizedAdState] == 2) {
                [BeiZiSDKManager setPersonalRecommend:NO];
            } else {
                [BeiZiSDKManager setPersonalRecommend:YES];
            }
            [BeiZiSDKManager configureWithApplicationID:serverInfo[@"appid"]];
        }
    }
    return self;
}

- (void)loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    NSTimeInterval tolerateTimeout = localInfo[kATSplashExtraTolerateTimeoutKey] ? [localInfo[kATSplashExtraTolerateTimeoutKey] doubleValue] : 5.0;
    NSDate *curDate = [NSDate date];
    _customEvent = [[ATBZSplashCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    _customEvent.expireDate = [curDate dateByAddingTimeInterval:tolerateTimeout];
    // 1. 检查 serverInfo 有效性
    if (!serverInfo || ![serverInfo isKindOfClass:[NSDictionary class]]) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"Invalid server info."}];
        [_customEvent trackSplashAdLoadFailed:error];
        return;
    }
    
    // 2. 安全获取 unitid
    NSString *unitID = [serverInfo objectForKey:@"unitid"];
    if (!unitID) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"UnitID missing in server info."}];
        [_customEvent trackSplashAdLoadFailed:error];
        return;
    }
    ATBZCustomBiddingRequest *request = [[ATBZC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:serverInfo[@"unitid"]];
    if (request != nil) {
        if (request.customObject) {
            self.splashAd = request.customObject;
            self.splashAd.delegate = _customEvent;
            [_customEvent trackSplashAdLoaded:self.splashAd];
        }else { // fail
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"It took too long to load placement stragety."}];
            [_customEvent trackSplashAdLoadFailed:error];
        }
        // remove requestItem
        [[ATBZC2SBiddingRequestManager sharedInstance] removeRequestItmeWithUnitID:serverInfo[@"unitid"]];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.splashAd = [[BeiZiSplash alloc] initWithSpaceID:serverInfo[@"unitid"] spaceParam:@"" lifeTime:tolerateTimeout * 1000];
            self.splashAd.showLaunchImage = NO;
            self.splashAd.delegate = self.customEvent;
            self.customEvent.containerView = localInfo[kATSplashExtraContainerViewKey];
            [self.splashAd BeiZi_loadSplashAd];
        });
    }
}

+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    BeiZiSplash *splashAd = customObject;
    return splashAd ? YES : NO;
}

+ (BOOL)isSupportAdType:(nonnull ATUnitGroupModel *)unitGroupModel { 
    return YES;
}


+ (void)showSplash:(ATSplash *)splash localInfo:(NSDictionary *)localInfo delegate:(id<ATSplashDelegate>)delegate {
    BeiZiSplash *splashAd = splash.customObject;
    UIWindow *window = localInfo[kATSplashExtraWindowKey];
    [splashAd BeiZi_showSplashAdWithWindow:window];
}

#pragma mark - Header bidding
#pragma mark - c2s
+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    if (![[ATAPI sharedInstance] initFlagForNetwork:@"BZ"]) {
        [[ATAPI sharedInstance] setInitFlagForNetwork:@"BZ"];
        [[ATAPI sharedInstance] setVersion:[BeiZiSDKManager sdkVersion] forNetwork:@"BZ"];
        if ([[ATAPI sharedInstance] getPersonalizedAdState] == 2) {
            [BeiZiSDKManager setPersonalRecommend:NO];
        } else {
            [BeiZiSDKManager setPersonalRecommend:YES];
        }
        [BeiZiSDKManager configureWithApplicationID:info[@"appid"]];
    }
    NSDate *curDate = [NSDate date];
    ATBZSplashCustomEvent *customEvent = [[ATBZSplashCustomEvent alloc] initWithInfo:info localInfo:info];
    customEvent.isC2SBiding = YES;
    customEvent.spaceId = info[@"unitid"];
    NSTimeInterval tolerateTimeout = info[kATSplashExtraTolerateTimeoutKey] ? [info[kATSplashExtraTolerateTimeoutKey] doubleValue] : 5.0;
    customEvent.expireDate = [curDate dateByAddingTimeInterval:tolerateTimeout];
    customEvent.containerView = info[kATSplashExtraContainerViewKey];
    ATBZC2SBiddingRequestManager *biddingManage = [ATBZC2SBiddingRequestManager sharedInstance];
    ATBZCustomBiddingRequest *request = [ATBZCustomBiddingRequest new];
    request.unitGroup = unitGroupModel;
    request.placementID = placementModel.placementID;
    request.bidCompletion = completion;
    request.unitID = info[@"unitid"];
    request.extraInfo = info;
    request.adType = ESCAdFormatSplash;
    request.customEvent = customEvent;
    dispatch_async(dispatch_get_main_queue(), ^{
        BeiZiSplash *splash = [[BeiZiSplash alloc] initWithSpaceID:info[@"unitid"] spaceParam:@"" lifeTime:tolerateTimeout * 1000];
        splash.showLaunchImage = NO;
        request.customObject = splash;
        [biddingManage startWithRequestItem:request];
        [splash BeiZi_loadSplashAd];
    });
}

+ (void)sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    BeiZiSplash *bzSplash = (BeiZiSplash *)customObject;
    NSMutableDictionary *winInfo =[[NSMutableDictionary alloc] init];
    [winInfo setObject:[NSString stringWithFormat:@"%ld",bzSplash.eCPM] forKey:BeiZi_WIN_PRICE];
    [winInfo setObject:@"9999" forKey:BeiZi_ADNID];
    if (price && price.length > 0) {
        [winInfo setObject:price forKey:BeiZi_HIGHRST_LOSS_PRICE];
    } else {
        [winInfo setObject:@"0" forKey:BeiZi_HIGHRST_LOSS_PRICE];
    }
    [bzSplash sendWinNotificationWithInfo:winInfo];
}

+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    BeiZiSplash *bzSplash = (BeiZiSplash *)customObject;
    NSMutableDictionary *lossInfo =[[NSMutableDictionary alloc] init];
    if (price && price.length > 0) {
        [lossInfo setObject:price forKey:BeiZi_WIN_PRICE];
    } else {
        [lossInfo setObject:@"0" forKey:BeiZi_WIN_PRICE];
    }
    [lossInfo setObject:@"9999" forKey:BeiZi_ADNID];
    if (lossType == ATBiddingLossWithLowPriceInNormal || lossType == ATBiddingLossWithLowPriceInHB) {
        [lossInfo setObject:@"1" forKey:BeiZi_LOSS_REASON];
    } else if (lossType == ATBiddingLossWithBiddingTimeOut) {
        [lossInfo setObject:@"2" forKey:BeiZi_LOSS_REASON];
    } else {
        [lossInfo setObject:@"999" forKey:BeiZi_LOSS_REASON];
    }
    [bzSplash sendLossNotificationWithInfo:lossInfo];
}

@end
