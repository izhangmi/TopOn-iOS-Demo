//
//  ATBZRewardedVideoCustomAdapter.m
//  AnyThinkSDKDemo
//
//  Created by nie adhub on 2025/7/20.
//

#import "ATBZRewardedVideoCustomAdapter.h"
#import "ATBZRewardedVideoCustomEvent.h"
#import <AnyThinkRewardedVideo/AnyThinkRewardedVideo.h>
#import "ATBZCustomBiddingRequest.h"
#import "ATBZC2SBiddingRequestManager.h"

@interface ATBZRewardedVideoCustomAdapter ()

@property (nonatomic, strong) ATBZRewardedVideoCustomEvent *customEvent;

@property (nonatomic, strong) BeiZiRewardedVideo *rewardedVideoAd;

@end

@implementation ATBZRewardedVideoCustomAdapter

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
    _customEvent = [[ATBZRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    _customEvent.expireDate = [curDate dateByAddingTimeInterval:tolerateTimeout];
    ATBZCustomBiddingRequest *request = [[ATBZC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:serverInfo[@"unitid"]];
    if (request != nil) {
        if (request.customObject) {
            self.rewardedVideoAd = request.customObject;
            self.rewardedVideoAd.delegate = _customEvent;
            [_customEvent trackRewardedVideoAdLoaded:self.rewardedVideoAd adExtra:@{}];
        }else { // fail
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load rewardedVideoAd.", NSLocalizedFailureReasonErrorKey:@"It took too long to load placement stragety."}];
            [_customEvent trackRewardedVideoAdLoadFailed:error];
        }
        // remove requestItem
        [[ATBZC2SBiddingRequestManager sharedInstance] removeRequestItmeWithUnitID:serverInfo[@"unitid"]];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.rewardedVideoAd = [[BeiZiRewardedVideo alloc] initWithSpaceID:serverInfo[@"unitid"] spaceParam:@"" lifeTime:tolerateTimeout];
            self.rewardedVideoAd.delegate = self.customEvent;
            [self.rewardedVideoAd BeiZi_loadRewardedVideoAd];
        });
    }
}

+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    BeiZiRewardedVideo *rewardedVideoAd = customObject;
    return rewardedVideoAd ? YES : NO;
}

+ (BOOL)isSupportAdType:(nonnull ATUnitGroupModel *)unitGroupModel {
    return YES;
}

+ (void)showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    BeiZiRewardedVideo *rewardedVideoAd = rewardedVideo.customObject;
    rewardedVideo.customEvent.delegate = delegate;
    [rewardedVideoAd BeiZi_showRewardedVideoAdFromRootViewController:viewController];
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
    ATBZRewardedVideoCustomEvent *customEvent = [[ATBZRewardedVideoCustomEvent alloc] initWithInfo:info localInfo:info];
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
        BeiZiRewardedVideo *rewardedVideoAd = [[BeiZiRewardedVideo alloc] initWithSpaceID:info[@"unitid"] spaceParam:@"" lifeTime:tolerateTimeout];
        request.customObject = rewardedVideoAd;
        [biddingManage startWithRequestItem:request];
        [rewardedVideoAd BeiZi_loadRewardedVideoAd];
    });
}

+ (void)sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    BeiZiRewardedVideo *bzRewardedVideoAd = (BeiZiRewardedVideo *)customObject;
    NSMutableDictionary *winInfo =[[NSMutableDictionary alloc] init];
    [winInfo setObject:[NSString stringWithFormat:@"%ld",bzRewardedVideoAd.eCPM] forKey:BeiZi_WIN_PRICE];
    [winInfo setObject:@"9999" forKey:BeiZi_ADNID];
    if (price && price.length > 0) {
        [winInfo setObject:price forKey:BeiZi_HIGHRST_LOSS_PRICE];
    } else {
        [winInfo setObject:@"0" forKey:BeiZi_HIGHRST_LOSS_PRICE];
    }
    [bzRewardedVideoAd sendWinNotificationWithInfo:winInfo];
}

+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    BeiZiRewardedVideo *bzRewardedVideoAd = (BeiZiRewardedVideo *)customObject;
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
    [bzRewardedVideoAd sendLossNotificationWithInfo:lossInfo];
}

@end
