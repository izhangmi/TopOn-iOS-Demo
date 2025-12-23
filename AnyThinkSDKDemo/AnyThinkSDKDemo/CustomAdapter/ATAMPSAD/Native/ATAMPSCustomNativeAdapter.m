//
//  ATAMPSCustomNativeAdapter.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import "ATAMPSCustomNativeAdapter.h"
#import "../Base/ATAMPSCustomInitAdapter.h"
#import "ATAMPSCustomNativeExpressDelegate.h"
#import "ATAMPSCustomNativeUnifiedDelegate.h"
#import "ATAMPSCustomNativeRenderer.h"
#import "../Bidding/ATAMPSCustomBiddingRequest.h"
#import "../Bidding/ATAMPSC2SBiddingRequestManager.h"
#import <AMPSAdSDK/AMPSAdSDK.h>

@interface ATAMPSCustomNativeAdapter ()

@property (nonatomic, strong) ATAMPSCustomNativeExpressDelegate *expressDelegate;
@property (nonatomic, strong) ATAMPSCustomNativeUnifiedDelegate *unifiedDelegate;
@property (nonatomic, strong) AMPSNativeExpressManager *nativeExpressManager;
@property (nonatomic, strong) AMPSUnifiedNativeManager *unifiedNativeManager;

@end

@implementation ATAMPSCustomNativeAdapter

#pragma mark - Ad load
// AAAAA: 这是非竞价模式（普通加载）
- (void)loadADWithArgument:(ATAdMediationArgument *)argument {
    NSDictionary *serverInfo = argument.serverContentDic;
    NSDictionary *localInfo = argument.localInfoDic ?: @{};
    
    if (!serverInfo || ![serverInfo isKindOfClass:[NSDictionary class]]) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain 
                                             code:ATAdErrorCodeThirdPartySDKNotImportedProperly 
                                         userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load native.", 
                                                   NSLocalizedFailureReasonErrorKey:@"Invalid server info."}];
        if (self.adStatusBridge) {
            [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
        }
        return;
    }
    
    BOOL isCustomRender = [serverInfo[@"renderType"] integerValue] == 1;
    
    NSString *unitID = serverInfo[@"unitid"];
    if (!unitID || unitID.length == 0) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain 
                                             code:ATAdErrorCodeThirdPartySDKNotImportedProperly 
                                         userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load native.", 
                                                   NSLocalizedFailureReasonErrorKey:@"UnitID missing in server info."}];
        if (self.adStatusBridge) {
            [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
        }
        return;
    }
    
    NSTimeInterval tolerateTimeout = [serverInfo[@"timeout"] integerValue] > 0 ? [serverInfo[@"timeout"] integerValue] : 5000;
    
    CGSize size = argument.nativeSize.width > 0 && argument.nativeSize.height > 0 
        ? argument.nativeSize 
        : CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 30.0f, 200.0f);
    if ([localInfo[kATExtraInfoNativeAdSizeKey] respondsToSelector:@selector(CGSizeValue)]) {
        size = [localInfo[kATExtraInfoNativeAdSizeKey] CGSizeValue];
    }
    
    // 设置 networkUnitId，TopOn SDK 需要此信息才能正确统计数据
    if (self.adStatusBridge && unitID) {
        [self.adStatusBridge setNetworkUnitId:unitID];
    }
    
    if (isCustomRender) {
        self.unifiedDelegate = [[ATAMPSCustomNativeUnifiedDelegate alloc] initWithInfo:serverInfo localInfo:localInfo];
        self.unifiedDelegate.adStatusBridge = self.adStatusBridge;
    } else {
        self.expressDelegate = [[ATAMPSCustomNativeExpressDelegate alloc] initWithInfo:serverInfo localInfo:localInfo];
        self.expressDelegate.adStatusBridge = self.adStatusBridge;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isCustomRender) {
            AMPSAdConfiguration *adConfig = [[AMPSAdConfiguration alloc] init];
            adConfig.spaceId = unitID;
            adConfig.timeoutInterval = tolerateTimeout;
            
            self.unifiedNativeManager = [[AMPSUnifiedNativeManager alloc] initWithAdConfiguration:adConfig];
            self.unifiedNativeManager.delegate = self.unifiedDelegate;
            self.unifiedDelegate.unifiedNativeManager = self.unifiedNativeManager;
            [self.unifiedNativeManager loadUnifiedNativeManager];
        } else {
            AMPSAdConfiguration *adConfig = [[AMPSAdConfiguration alloc] init];
            adConfig.spaceId = unitID;
            adConfig.adSize = size;
            adConfig.timeoutInterval = tolerateTimeout;
            
            self.nativeExpressManager = [[AMPSNativeExpressManager alloc] initWithAdConfiguration:adConfig];
            self.nativeExpressManager.delegate = self.expressDelegate;
            self.expressDelegate.nativeExpressManager = self.nativeExpressManager;
            [self.nativeExpressManager loadNativeExpressManager];
        }
    });
}

+ (Class)rendererClass {
    return [ATAMPSCustomNativeRenderer class];
}

#pragma mark - C2S Bidding
// AAAAA: 这是竞价模式（C2S Bidding）
+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel 
                       unitGroupModel:(ATUnitGroupModel*)unitGroupModel 
                                 info:(NSDictionary*)info 
                           completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    BOOL isCustomRenderBid = [info[@"renderType"] integerValue] == 1;
    id customDelegate = nil;
    if (isCustomRenderBid) {
        ATAMPSCustomNativeUnifiedDelegate *unifiedDelegate = [[ATAMPSCustomNativeUnifiedDelegate alloc] initWithInfo:info localInfo:info];
        unifiedDelegate.isC2SBiding = YES;
        unifiedDelegate.spaceId = info[@"unitid"];
        customDelegate = unifiedDelegate;
    } else {
        ATAMPSCustomNativeExpressDelegate *expressDelegate = [[ATAMPSCustomNativeExpressDelegate alloc] initWithInfo:info localInfo:info];
        expressDelegate.isC2SBiding = YES;
        expressDelegate.spaceId = info[@"unitid"];
        customDelegate = expressDelegate;
    }
    NSTimeInterval tolerateTimeout = [info[@"timeout"] doubleValue] > 0 ? [info[@"timeout"] doubleValue] : 5000;
    
    ATAMPSC2SBiddingRequestManager *biddingManage = [ATAMPSC2SBiddingRequestManager sharedInstance];
    ATAMPSCustomBiddingRequest *request = [ATAMPSCustomBiddingRequest new];
    request.unitGroup = unitGroupModel;
    request.placementID = placementModel.placementID;
    request.bidCompletion = completion;
    request.unitID = info[@"unitid"];
    request.extraInfo = info;
    request.adType = ATAMPSAdFormatNative;
    request.customEvent = customDelegate;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isCustomRenderBid) {
            AMPSAdConfiguration *adConfig = [[AMPSAdConfiguration alloc] init];
            adConfig.spaceId = info[@"unitid"];
            adConfig.timeoutInterval = tolerateTimeout;
            
            AMPSUnifiedNativeManager *unifiedManager = [[AMPSUnifiedNativeManager alloc] initWithAdConfiguration:adConfig];
            request.customObject = unifiedManager;
            [biddingManage startWithRequestItem:request];
            unifiedManager.delegate = (ATAMPSCustomNativeUnifiedDelegate *)customDelegate;
            ((ATAMPSCustomNativeUnifiedDelegate *)customDelegate).unifiedNativeManager = unifiedManager;
            [unifiedManager loadUnifiedNativeManager];
        } else {
            CGSize size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 30.0f, 200.0f);
            if ([info[kATExtraInfoNativeAdSizeKey] respondsToSelector:@selector(CGSizeValue)]) {
                size = [info[kATExtraInfoNativeAdSizeKey] CGSizeValue];
            }
            
            AMPSAdConfiguration *adConfig = [[AMPSAdConfiguration alloc] init];
            adConfig.spaceId = info[@"unitid"];
            adConfig.adSize = size;
            adConfig.timeoutInterval = tolerateTimeout;
            
            AMPSNativeExpressManager *expressManager = [[AMPSNativeExpressManager alloc] initWithAdConfiguration:adConfig];
            request.customObject = expressManager;
            [biddingManage startWithRequestItem:request];
            expressManager.delegate = (ATAMPSCustomNativeExpressDelegate *)customDelegate;
            ((ATAMPSCustomNativeExpressDelegate *)customDelegate).nativeExpressManager = expressManager;
            [expressManager loadNativeExpressManager];
        }
    });
}

+ (void)sendWinnerNotifyWithCustomObject:(id)customObject 
                              secondPrice:(NSString*)price 
                                 userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    NSMutableDictionary *winInfo = [[NSMutableDictionary alloc] init];
    
    id<AMPSBiddingProtocol> biddingObject = nil;
    
    if ([customObject isKindOfClass:[AMPSNativeExpressView class]]) {
        biddingObject = (id<AMPSBiddingProtocol>)customObject;
    } else if ([customObject isKindOfClass:[AMPSUnifiedNativeView class]]) {
        biddingObject = (id<AMPSBiddingProtocol>)customObject;
    } else if ([customObject isKindOfClass:[AMPSNativeExpressManager class]]) {
        AMPSNativeExpressManager *manager = (AMPSNativeExpressManager *)customObject;
        if (manager.viewsArray.count > 0) {
            biddingObject = (id<AMPSBiddingProtocol>)manager.viewsArray.firstObject;
        }
    } else if ([customObject isKindOfClass:[AMPSUnifiedNativeManager class]]) {
        return;
    }
    
    if (biddingObject && [biddingObject conformsToProtocol:@protocol(AMPSBiddingProtocol)]) {
        NSInteger eCPM = [biddingObject eCPM];
        [winInfo setObject:[NSString stringWithFormat:@"%ld", (long)eCPM] forKey:@"AMPS_WIN_PRICE"];
        [winInfo setObject:@"9999" forKey:@"AMPS_WIN_ADNID"];
        
        if (price && price.length > 0) {
            [winInfo setObject:price forKey:@"AMPS_HIGHRST_LOSS_PRICE"];
        } else {
            [winInfo setObject:@"0" forKey:@"AMPS_HIGHRST_LOSS_PRICE"];
        }
        
        [biddingObject sendWinNotificationWithInfo:winInfo];
    }
}

+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject 
                               lossType:(ATBiddingLossType)lossType 
                                winPrice:(nonnull NSString *)price 
                                userInfo:(NSDictionary *)userInfo {
    NSMutableDictionary *lossInfo = [[NSMutableDictionary alloc] init];
    
    id<AMPSBiddingProtocol> biddingObject = nil;
    
    if ([customObject isKindOfClass:[AMPSNativeExpressView class]]) {
        biddingObject = (id<AMPSBiddingProtocol>)customObject;
    } else if ([customObject isKindOfClass:[AMPSUnifiedNativeView class]]) {
        biddingObject = (id<AMPSBiddingProtocol>)customObject;
    } else if ([customObject isKindOfClass:[AMPSNativeExpressManager class]]) {
        AMPSNativeExpressManager *manager = (AMPSNativeExpressManager *)customObject;
        if (manager.viewsArray.count > 0) {
            biddingObject = (id<AMPSBiddingProtocol>)manager.viewsArray.firstObject;
        }
    } else if ([customObject isKindOfClass:[AMPSUnifiedNativeManager class]]) {
        return;
    }
    
    if (biddingObject && [biddingObject conformsToProtocol:@protocol(AMPSBiddingProtocol)]) {
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
        
        [biddingObject sendLossNotificationWithInfo:lossInfo];
    }
}

#pragma mark - C2S Bidding Result
- (void)didReceiveBidResult:(ATBidWinLossResult *)result {
}

@end

