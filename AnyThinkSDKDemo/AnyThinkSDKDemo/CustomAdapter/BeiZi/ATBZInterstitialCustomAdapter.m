//
//  ATBZInterstitialCustomAdapter.m
//  AnyThinkSDKDemo
//
//  Created by nie adhub on 2024/4/17.
//

#import "ATBZInterstitialCustomAdapter.h"
#import "ATBZInterstitialCustomEvent.h"
#import "ATBZCustomBiddingRequest.h"
#import "ATBZC2SBiddingRequestManager.h"
#import <AnyThinkInterstitial/AnyThinkInterstitial.h>

@interface ATBZInterstitialCustomAdapter () <ATAdAdapter>

@property (nonatomic, strong) ATBZInterstitialCustomEvent *customEvent;

@property (nonatomic, strong) BeiZiInterstitial *interstitialAd;

@end

@implementation ATBZInterstitialCustomAdapter

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
    NSTimeInterval tolerateTimeout = [serverInfo[@"timeout"] integerValue] > 0 ? [serverInfo[@"timeout"] integerValue] : 5000;
    NSDate *curDate = [NSDate date];
    _customEvent = [[ATBZInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    _customEvent.expireDate = [curDate dateByAddingTimeInterval:tolerateTimeout];
    ATBZCustomBiddingRequest *request = [[ATBZC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:serverInfo[@"unitid"]];
    if (request != nil) {
        if (request.customObject) {
            self.interstitialAd = request.customObject;
            self.interstitialAd.delegate = _customEvent;
            [_customEvent trackInterstitialAdLoaded:self.interstitialAd adExtra:@{}];
        }else { // fail
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial.", NSLocalizedFailureReasonErrorKey:@"It took too long to load placement stragety."}];
            [_customEvent trackInterstitialAdLoadFailed:error];
        }
        // remove requestItem
        [[ATBZC2SBiddingRequestManager sharedInstance] removeRequestItmeWithUnitID:serverInfo[@"unitid"]];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.interstitialAd = [[BeiZiInterstitial alloc] initWithSpaceID:serverInfo[@"unitid"] spaceParam:@"" lifeTime:tolerateTimeout];
            self.interstitialAd.delegate = self.customEvent;
            [self.interstitialAd BeiZi_loadInterstitialAd];
        });
    }
}

+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    BeiZiInterstitial *interstitial = customObject;
    return interstitial ? YES : NO;
}

+ (BOOL)isSupportAdType:(nonnull ATUnitGroupModel *)unitGroupModel { 
    return YES;
}

+ (void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    BeiZiInterstitial *interstitialAd = interstitial.customObject;
    interstitial.customEvent.delegate = delegate;
    [interstitialAd BeiZi_showInterstitialAdFromRootViewController:viewController];
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
    ATBZInterstitialCustomEvent *customEvent = [[ATBZInterstitialCustomEvent alloc] initWithInfo:info localInfo:info];
    customEvent.isC2SBiding = YES;
    customEvent.spaceId = info[@"unitid"];
    NSTimeInterval tolerateTimeout = [info[@"timeout"] integerValue] > 0 ? [info[@"timeout"] integerValue] : 5000;
    customEvent.expireDate = [curDate dateByAddingTimeInterval:tolerateTimeout];
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
        BeiZiInterstitial *interstitial = [[BeiZiInterstitial alloc] initWithSpaceID:info[@"unitid"] spaceParam:@"" lifeTime:tolerateTimeout];
        request.customObject = interstitial;
        [biddingManage startWithRequestItem:request];
        [interstitial BeiZi_loadInterstitialAd];
    });
}

+ (void)sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    BeiZiInterstitial *bzInterstitial = (BeiZiInterstitial *)customObject;
    NSMutableDictionary *winInfo =[[NSMutableDictionary alloc] init];
    [winInfo setObject:[NSString stringWithFormat:@"%ld",bzInterstitial.eCPM] forKey:BeiZi_WIN_PRICE];
    [winInfo setObject:@"9999" forKey:BeiZi_ADNID];
    if (price && price.length > 0) {
        [winInfo setObject:price forKey:BeiZi_HIGHRST_LOSS_PRICE];
    } else {
        [winInfo setObject:@"0" forKey:BeiZi_HIGHRST_LOSS_PRICE];
    }
    [bzInterstitial sendWinNotificationWithInfo:winInfo];
}

+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    BeiZiInterstitial *bzInterstitial = (BeiZiInterstitial *)customObject;
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
    [bzInterstitial sendLossNotificationWithInfo:lossInfo];
}

@end
