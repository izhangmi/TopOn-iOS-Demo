//
//  ATAMPSCustomNativeExpressDelegate.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import "ATAMPSCustomNativeExpressDelegate.h"
#import "ATAMPSCustomNativeObject.h"
#import "../Bidding/ATAMPSCustomBiddingRequest.h"
#import "../Bidding/ATAMPSC2SBiddingRequestManager.h"
#import <AnyThinkSDK/NSDictionary+KAKit.h>

@implementation ATAMPSCustomNativeExpressDelegate

- (instancetype)initWithInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    self = [super init];
    if (self) {
        self.serverInfo = serverInfo;
        self.localInfo = localInfo;
        self.spaceId = serverInfo[@"unitid"];
    }
    return self;
}

#pragma mark - AMPSNativeExpressManagerDelegate
- (void)ampsNativeAdLoadSuccess:(AMPSNativeExpressManager *)nativeAd {
    if (nativeAd.viewsArray.count > 0) {
        AMPSNativeExpressView *expressView = nativeAd.viewsArray.firstObject;
        if (!expressView) {
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load native.", NSLocalizedFailureReasonErrorKey:@"Express view is nil."}];
            if (self.adStatusBridge) {
                [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
            }
            return;
        }
        
        expressView.viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        expressView.delegate = self;
        [expressView renderAd];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger ecpm = [expressView eCPM];
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
                                                                 customObject:expressView];
                    bidInfo.networkFirmID = request.unitGroup.networkFirmID;
                    if (request.bidCompletion) {
                        request.bidCompletion(bidInfo, nil);
                    }
                }
                self.isC2SBiding = NO;
            } else {
                ATAMPSCustomNativeObject *customNativeAd = [[ATAMPSCustomNativeObject alloc] init];
                customNativeAd.templateView = expressView;
                customNativeAd.nativeExpressAdViewWidth = expressView.frame.size.width;
                customNativeAd.nativeExpressAdViewHeight = expressView.frame.size.height;
                customNativeAd.isExpressAd = YES;
                customNativeAd.nativeAdRenderType = ATNativeAdRenderExpress;
                customNativeAd.nativeExpressView = expressView;
                if (self.nativeExpressManager) {
                    customNativeAd.nativeExpressManager = self.nativeExpressManager;
                } else {
                    ATAMPSCustomBiddingRequest *request = [[ATAMPSC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
                    if (request && [request.customObject isKindOfClass:[AMPSNativeExpressManager class]]) {
                        customNativeAd.nativeExpressManager = (AMPSNativeExpressManager *)request.customObject;
                    } else {
                        customNativeAd.nativeExpressManager = (AMPSNativeExpressManager *)nativeAd;
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
        });
    }
}

- (void)ampsNativeAdLoadFail:(AMPSNativeExpressManager *)nativeAd error:(NSError *)error {
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

#pragma mark - AMPSNativeExpressViewDelegate
- (void)ampsNativeAdRenderSuccess:(AMPSNativeExpressView *)nativeView {
}

- (void)ampsNativeAdRenderFail:(AMPSNativeExpressView *)nativeView error:(NSError *)error {
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
    }
}

- (void)ampsNativeAdExposured:(AMPSNativeExpressView *)nativeView {
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdShow:nil];
    }
}

- (void)ampsNativeAdDidClick:(AMPSNativeExpressView *)nativeView {
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdClick:nil];
    }
}

- (void)ampsNativeAdDidClose:(AMPSNativeExpressView *)nativeView {
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdClosed:nil];
    }
}

@end
