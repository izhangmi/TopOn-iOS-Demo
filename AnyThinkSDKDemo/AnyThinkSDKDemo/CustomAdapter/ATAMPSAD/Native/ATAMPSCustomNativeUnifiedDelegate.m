//
//  ATAMPSCustomNativeUnifiedDelegate.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import "ATAMPSCustomNativeUnifiedDelegate.h"
#import "ATAMPSCustomNativeObject.h"
#import "../Bidding/ATAMPSCustomBiddingRequest.h"
#import "../Bidding/ATAMPSC2SBiddingRequestManager.h"
#import <AnyThinkSDK/NSDictionary+KAKit.h>

@implementation ATAMPSCustomNativeUnifiedDelegate

- (instancetype)initWithInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    self = [super init];
    if (self) {
        self.serverInfo = serverInfo;
        self.localInfo = localInfo;
        self.spaceId = serverInfo[@"unitid"];
    }
    return self;
}

#pragma mark - AMPSUnifiedNativeManagerDelegate
- (void)ampsNativeAdLoadSuccess:(AMPSUnifiedNativeManager *)nativeManager {
    if (nativeManager.adArray.count > 0) {
        AMPSUnifiedNativeAd *nativeAd = nativeManager.adArray.firstObject;
        if (!nativeAd) {
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load native.", NSLocalizedFailureReasonErrorKey:@"Unified native ad is nil."}];
            if (self.adStatusBridge) {
                [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
            }
            return;
        }
        
        AMPSUnifiedNativeView *nativeView = [[AMPSUnifiedNativeView alloc] init];
        nativeView.viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        nativeView.delegate = self;
        [nativeView refreshData:nativeAd];
        
        NSInteger ecpm = [nativeView eCPM];
        NSString *priceStr = [NSString stringWithFormat:@"%ld", (long)ecpm];
        if ([priceStr doubleValue] < 0) {
            priceStr = @"0";
        }
        
        // C2S 竞价逻辑
        if (self.isC2SBiding) {
            ATAMPSCustomBiddingRequest *request = [[ATAMPSC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
            if (request) {
                ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID 
                                                          unitGroupUnitID:request.unitGroup.unitID 
                                                     adapterClassString:request.unitGroup.adapterClassString 
                                                                   price:priceStr 
                                                               sortPrice:priceStr 
                                                             currencyType:ATBiddingCurrencyTypeCNYCents 
                                                       expirationInterval:request.unitGroup.bidTokenTime 
                                                             customObject:nativeView];
                bidInfo.networkFirmID = request.unitGroup.networkFirmID;
                if (request.bidCompletion) {
                    request.bidCompletion(bidInfo, nil);
                }
            }
            self.isC2SBiding = NO;
        } else {
            ATAMPSCustomNativeObject *customNativeAd = [[ATAMPSCustomNativeObject alloc] init];
            customNativeAd.title = nativeAd.title;
            customNativeAd.mainText = nativeAd.desc;
            customNativeAd.iconUrl = nativeAd.iconUrl;
            customNativeAd.imageUrl = nativeAd.imageUrl;
            customNativeAd.logoUrl = nativeAd.adLogoUrl;
            customNativeAd.isExpressAd = NO;
            customNativeAd.nativeAdRenderType = ATNativeAdRenderSelfRender;
            customNativeAd.isVideoContents = (nativeAd.nativeMode == AMPSUnifiedNativeModeUnifiedVideo);
            customNativeAd.mediaView = nativeView;
            customNativeAd.unifiedNativeView = nativeView;
            if (self.unifiedNativeManager) {
                customNativeAd.unifiedNativeManager = self.unifiedNativeManager;
            } else {
                ATAMPSCustomBiddingRequest *request = [[ATAMPSC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
                if (request && [request.customObject isKindOfClass:[AMPSUnifiedNativeManager class]]) {
                    customNativeAd.unifiedNativeManager = (AMPSUnifiedNativeManager *)request.customObject;
                } else {
                    customNativeAd.unifiedNativeManager = (AMPSUnifiedNativeManager *)nativeManager;
                }
            }
            
            NSArray<ATCustomNetworkNativeAd *> *nativeAdArray = @[customNativeAd];
            NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
            [infoDic AT_setDictValue:priceStr key:ATAdSendC2SBidPriceKey];
            [infoDic AT_setDictValue:@(ATBiddingCurrencyTypeCNYCents) key:ATAdSendC2SCurrencyTypeKey];
            
            if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnNativeAdLoadedArray:adExtra:)]) {
                [self.adStatusBridge atOnNativeAdLoadedArray:nativeAdArray adExtra:infoDic];
            }
        }
    }
}

- (void)ampsNativeAdLoadFail:(AMPSUnifiedNativeManager *)nativeManager error:(NSError *)error {
    if (self.isC2SBiding) {
        ATAMPSCustomBiddingRequest *request = [[ATAMPSC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
        if (request.bidCompletion) {
            request.bidCompletion(nil, error);
        }
        self.isC2SBiding = NO;
    } else {
        if (self.adStatusBridge) {
            [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
        }
    }
}

#pragma mark - AMPSUnifiedNativeViewDelegate
- (void)ampsNativeAdRenderSuccess:(AMPSUnifiedNativeView *)nativeView {
}

- (void)ampsNativeAdRenderFail:(AMPSUnifiedNativeView *)nativeView error:(NSError *)error {
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
    }
}

- (void)ampsNativeAdExposured:(AMPSUnifiedNativeView *)nativeView {
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdShow:nil];
    }
}

- (void)ampsNativeAdDidClick:(AMPSUnifiedNativeView *)nativeView {
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdClick:nil];
    }
}

- (void)ampsNativeAdDidClose:(AMPSUnifiedNativeView *)nativeView {
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdClosed:nil];
    }
}

@end

