//
//  ATBZNativeAdapter.m
//  AnyThinkSDKDemo
//
//  Created by nie adhub on 2023/10/24.
//  Copyright © 2023 抽筋的灯. All rights reserved.
//

#import "ATBZNativeCustomAdapter.h"
#import "ATBZNativeADCustomEvent.h"
#import "ATBZNativeCustomRenderer.h"
#import "ATBZCustomBiddingRequest.h"
#import "ATBZC2SBiddingRequestManager.h"

static BOOL _isCustomRender = NO;


@interface ATBZNativeCustomAdapter () <ATAdAdapter>

@property (nonatomic, readonly) ATBZNativeADCustomEvent *customEvent;

@property (nonatomic, strong) BeiZiNativeExpress *nativeExpressAd;

@property (nonatomic, strong) BeiZiUnifiedNative *unifiedNative;

@property (nonatomic, assign, class) BOOL isCustomRender;

@end

@implementation ATBZNativeCustomAdapter

+ (BOOL)isCustomRender {
    return _isCustomRender;
}

+ (void)setIsCustomRender:(BOOL)isCustomRender {
    _isCustomRender = isCustomRender;
}

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
    _customEvent = [[ATBZNativeADCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    _customEvent.requestCompletionBlock = completion;
    // 1. 检查 serverInfo 有效性
    if (!serverInfo || ![serverInfo isKindOfClass:[NSDictionary class]]) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"Invalid server info."}];
        [_customEvent trackNativeAdLoadFailed:error];
        return;
    }
    
    // 2. 安全获取 unitid
    NSString *unitID = [serverInfo objectForKey:@"unitid"];
    if (!unitID) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"UnitID missing in server info."}];
        [_customEvent trackNativeAdLoadFailed:error];
        return;
    }
    NSTimeInterval tolerateTimeout = [serverInfo[@"timeout"] integerValue] > 0 ? [serverInfo[@"timeout"] integerValue] : 5000;
    CGSize size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 30.0f, 200.0f);
    if ([localInfo[kATExtraInfoNativeAdSizeKey] respondsToSelector:@selector(CGSizeValue)]) {
        size = [localInfo[kATExtraInfoNativeAdSizeKey] CGSizeValue];
    }
    ATBZCustomBiddingRequest *request = [[ATBZC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:serverInfo[@"unitid"]];
    if ([serverInfo[@"renderType"] integerValue] == 1) {
        ATBZNativeCustomAdapter.isCustomRender = YES;
    }
    if (request) {
        if (request.customObject != nil) {
            completion(request.assets,nil);
            if (ATBZNativeCustomAdapter.isCustomRender) {
                self.unifiedNative = request.customObject;
                self.unifiedNative.delegate = _customEvent;
            } else {
                self.nativeExpressAd = request.customObject;
                self.nativeExpressAd.delegate = _customEvent;
            }
        } else { // fail
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load native.", NSLocalizedFailureReasonErrorKey:@"It took too long to load placement stragety."}];
            [_customEvent trackNativeAdLoadFailed:error];
        }
        [[ATBZC2SBiddingRequestManager sharedInstance] removeRequestItmeWithUnitID:serverInfo[@"unitid"]];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (ATBZNativeCustomAdapter.isCustomRender) {
                self.unifiedNative = [[BeiZiUnifiedNative alloc] initWithSpaceID:serverInfo[@"unitid"] spaceParam:@"" lifeTime:tolerateTimeout];
                self.unifiedNative.delegate = self.customEvent;
                [self.unifiedNative BeiZi_hiddenAnyObject:@[@"adIcon"]];
                [self.unifiedNative BeiZi_loadUnifiedNative];
            } else {
                self.nativeExpressAd = [[BeiZiNativeExpress alloc] initWithSpaceID:serverInfo[@"unitid"] spaceParam:@"" lifeTime:tolerateTimeout];
                self.nativeExpressAd.adStyle = [serverInfo[@"templateType"] integerValue];
                self.nativeExpressAd.delegate = self.customEvent;
                [self.nativeExpressAd BeiZi_loadNativeExpressAdWithViewSize:size];
            }
        });
    }
}

+ (BOOL)adReadyWithCustomObject:(nonnull id)customObject info:(nonnull NSDictionary *)info {
    BeiZiNativeExpress *nativeExpress = customObject;
    return nativeExpress ? YES : NO;
}

+ (BOOL)isSupportAdType:(nonnull ATUnitGroupModel *)unitGroupModel { 
    return YES;
}

+ (Class)rendererClass {
    return [ATBZNativeCustomRenderer class];
}

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
    ATBZNativeADCustomEvent *customEvent = [[ATBZNativeADCustomEvent alloc] initWithInfo:info localInfo:info];
    customEvent.isC2SBiding = YES;
    customEvent.spaceId = info[@"unitid"];
    NSTimeInterval tolerateTimeout = [info[@"timeout"] integerValue] > 0 ? [info[@"timeout"] integerValue] : 5000;
    ATBZC2SBiddingRequestManager *biddingManage = [ATBZC2SBiddingRequestManager sharedInstance];
    ATBZCustomBiddingRequest *request = [ATBZCustomBiddingRequest new];
    request.unitGroup = unitGroupModel;
    request.placementID = placementModel.placementID;
    request.bidCompletion = completion;
    request.unitID = info[@"unitid"];
    request.extraInfo = info;
    request.adType = ESCAdFormatNative;
    request.customEvent = customEvent;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([info[@"renderType"] integerValue] == 1) {
            BeiZiUnifiedNative *unifiedNative = [[BeiZiUnifiedNative alloc] initWithSpaceID:info[@"unitid"] spaceParam:@"" lifeTime:tolerateTimeout];
            request.customObject = unifiedNative;
            [biddingManage startWithRequestItem:request];
            [unifiedNative BeiZi_hiddenAnyObject:@[@"adIcon"]];
            [unifiedNative BeiZi_loadUnifiedNative];
        } else {
            BeiZiNativeExpress *native = [[BeiZiNativeExpress alloc] initWithSpaceID:info[@"unitid"] spaceParam:@"" lifeTime:tolerateTimeout];
            native.adStyle = [info[@"templateType"] integerValue];
            request.customObject = native;
            [biddingManage startWithRequestItem:request];
            CGSize size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 30.0f, 200.0f);
            if ([info[kATExtraInfoNativeAdSizeKey] respondsToSelector:@selector(CGSizeValue)]) {
                size = [info[kATExtraInfoNativeAdSizeKey] CGSizeValue];
            }
            [native BeiZi_loadNativeExpressAdWithViewSize:size];
        }
    });
}

+ (void)sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    if (ATBZNativeCustomAdapter.isCustomRender) {
        BeiZiUnifiedNative *bzUnifiedNative = (BeiZiUnifiedNative *)customObject;
        NSMutableDictionary *winInfo =[[NSMutableDictionary alloc] init];
        [winInfo setObject:[NSString stringWithFormat:@"%ld",bzUnifiedNative.eCPM] forKey:BeiZi_WIN_PRICE];
        [winInfo setObject:@"9999" forKey:BeiZi_ADNID];
        if (price && price.length > 0) {
            [winInfo setObject:price forKey:BeiZi_HIGHRST_LOSS_PRICE];
        } else {
            [winInfo setObject:@"0" forKey:BeiZi_HIGHRST_LOSS_PRICE];
        }
        [bzUnifiedNative sendWinNotificationWithInfo:winInfo];
    } else {
        BeiZiNativeExpress *bzNativeExpress = (BeiZiNativeExpress *)customObject;
        NSMutableDictionary *winInfo =[[NSMutableDictionary alloc] init];
        [winInfo setObject:[NSString stringWithFormat:@"%ld",bzNativeExpress.eCPM] forKey:BeiZi_WIN_PRICE];
        [winInfo setObject:@"9999" forKey:BeiZi_ADNID];
        if (price && price.length > 0) {
            [winInfo setObject:price forKey:BeiZi_HIGHRST_LOSS_PRICE];
        } else {
            [winInfo setObject:@"0" forKey:BeiZi_HIGHRST_LOSS_PRICE];
        }
        [bzNativeExpress sendWinNotificationWithInfo:winInfo];
    }
}

+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    if (ATBZNativeCustomAdapter.isCustomRender) {
        BeiZiUnifiedNative *bzUnifiedNative = (BeiZiUnifiedNative *)customObject;
        NSMutableDictionary *winInfo =[[NSMutableDictionary alloc] init];
        [winInfo setObject:[NSString stringWithFormat:@"%ld",bzUnifiedNative.eCPM] forKey:BeiZi_WIN_PRICE];
        [winInfo setObject:@"9999" forKey:BeiZi_ADNID];
        if (price && price.length > 0) {
            [winInfo setObject:price forKey:BeiZi_HIGHRST_LOSS_PRICE];
        } else {
            [winInfo setObject:@"0" forKey:BeiZi_HIGHRST_LOSS_PRICE];
        }
        [bzUnifiedNative sendWinNotificationWithInfo:winInfo];
    } else {
        BeiZiNativeExpress *bzNativeExpress = (BeiZiNativeExpress *)customObject;
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
        [bzNativeExpress sendLossNotificationWithInfo:lossInfo];
    }
}

@end
