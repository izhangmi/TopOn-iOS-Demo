//
//  ATBZInterstitialCustomEvent.m
//  AnyThinkSDKDemo
//
//  Created by nie adhub on 2024/4/17.
//  Copyright © 2024 抽筋的灯. All rights reserved.
//

#import "ATBZInterstitialCustomEvent.h"
#import "ATBZCustomBiddingRequest.h"
#import "ATBZC2SBiddingRequestManager.h"

@implementation ATBZInterstitialCustomEvent

- (NSString *)networkUnitId {
    return self.serverInfo[@"unitid"];
}

/**
 插屏加载成功
 */
- (void)BeiZi_interstitialDidReceiveAd:(BeiZiInterstitial *)beiziInterstitial {
    if (self.isC2SBiding) {
        NSString *priceStr = [NSString stringWithFormat:@"%ld",beiziInterstitial.eCPM];
        ATBZCustomBiddingRequest *request = [[ATBZC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
        //构造ATBidInfo对象用于返回给SDK
        ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID unitGroupUnitID:request.unitGroup.unitID adapterClassString:request.unitGroup.adapterClassString price:priceStr currencyType:ATBiddingCurrencyTypeCNYCents expirationInterval:request.unitGroup.bidTokenTime customObject:beiziInterstitial];
        bidInfo.networkFirmID = request.unitGroup.networkFirmID;
        if (request.bidCompletion) {
            request.bidCompletion(bidInfo, nil);
        }
        self.isC2SBiding = NO;
    } else {
        [self trackInterstitialAdLoaded:beiziInterstitial adExtra:@{}];
    }
}

/**
 插屏展现
 */
- (void)BeiZi_interstitialDidPresentScreen:(BeiZiInterstitial *)beiziInterstitial {
    [self trackInterstitialAdShow];
}

/**
 插屏点击
 */
- (void)BeiZi_interstitialDidClick:(BeiZiInterstitial *)beiziInterstitial {
    [self trackInterstitialAdClick];
}

/**
 插屏消失&&关闭
 */
- (void)BeiZi_interstitialDidDismissScreen:(BeiZiInterstitial *)beiziInterstitial {
    [self trackInterstitialAdClose:@{}];
}

/**
 插屏请求失败
 */
- (void)BeiZi_interstitial:(BeiZiInterstitial *)beiziInterstitial didFailToLoadAdWithError:(BeiZiRequestError *)error {
    if (self.isC2SBiding) {
        ATBZCustomBiddingRequest *request = [[ATBZC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
        // 返回获取竞价广告失败
        if (request.bidCompletion) {
            request.bidCompletion(nil, error);
        }
        self.isC2SBiding = NO;
    } else {
        [self trackInterstitialAdLoadFailed:error];
    }
}

@end
