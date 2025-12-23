//
//  ATAMPSCustomInterstitialDelegate.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import "ATAMPSCustomInterstitialDelegate.h"
#import "../Bidding/ATAMPSCustomBiddingRequest.h"
#import "../Bidding/ATAMPSC2SBiddingRequestManager.h"
#import <AnyThinkSDK/NSDictionary+KAKit.h>

@implementation ATAMPSCustomInterstitialDelegate

- (instancetype)initWithInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    self = [super init];
    if (self) {
        self.serverInfo = serverInfo;
        self.localInfo = localInfo;
        self.spaceId = serverInfo[@"unitid"];
    }
    return self;
}

#pragma mark - AMPSInterstitialAdDelegate
- (void)ampsInterstitialAdLoadSuccess:(AMPSInterstitialAd *)interstitialAd {
    NSInteger ecpm = [interstitialAd eCPM];
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
                                                         customObject:interstitialAd];
            bidInfo.networkFirmID = request.unitGroup.networkFirmID;
            if (request.bidCompletion) {
                request.bidCompletion(bidInfo, nil);
            }
        }
        self.isC2SBiding = NO;
    } else {
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
        [infoDic AT_setDictValue:priceStr key:ATAdSendC2SBidPriceKey];
        [infoDic AT_setDictValue:@(ATBiddingCurrencyTypeCNYCents) key:ATAdSendC2SCurrencyTypeKey];
        
        if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnInterstitialAdLoadedExtra:)]) {
            [self.adStatusBridge atOnInterstitialAdLoadedExtra:infoDic];
        }
    }
}

- (void)ampsInterstitialAdLoadFail:(AMPSInterstitialAd *)interstitialAd error:(NSError *)error {
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

- (void)ampsInterstitialAdRenderSuccess:(AMPSInterstitialAd *)interstitialAd {
}

- (void)ampsInterstitialAdRenderFail:(AMPSInterstitialAd *)interstitialAd error:(NSError *)error {
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
    }
}

- (void)ampsInterstitialAdShowFail:(AMPSInterstitialAd *)interstitialAd error:(NSError *)error {
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdShowFailed:error extra:nil];
    }
}

- (void)ampsInterstitialAdDidShow:(AMPSInterstitialAd *)interstitialAd {
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdShow:nil];
    }
}

- (void)ampsInterstitialAdDidClick:(AMPSInterstitialAd *)interstitialAd {
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdClick:nil];
    }
}

- (void)ampsInterstitialAdDidClose:(AMPSInterstitialAd *)interstitialAd {
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdClosed:nil];
    }
}

@end

