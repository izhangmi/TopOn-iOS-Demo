//
//  ATAMPSInterstitialCustomEvent.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import "ATAMPSInterstitialCustomEvent.h"
#import "ATAMPSCustomBiddingRequest.h"
#import "ATAMPSC2SBiddingRequestManager.h"

// HJC: AMPSAd Interstitial 广告自定义事件实现
@implementation ATAMPSInterstitialCustomEvent

// HJC: 返回广告位 ID
- (NSString *)networkUnitId {
    return self.serverInfo[@"unitid"];
}

#pragma mark - AMPSInterstitialAdDelegate
// HJC: 插屏广告请求成功
- (void)ampsInterstitialAdLoadSuccess:(AMPSInterstitialAd *)interstitialAd {
    // HJC: 检查是否过期
    if (self.expireDate && [[NSDate date] timeIntervalSinceDate:self.expireDate] > 0) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load interstitial.", NSLocalizedFailureReasonErrorKey:@"It took too long for AMPS to load interstitial."}];
        if (self.isC2SBiding) {
            ATAMPSCustomBiddingRequest *request = [[ATAMPSC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
            if (request.bidCompletion) {
                request.bidCompletion(nil, error);
            }
            self.isC2SBiding = NO;
        } else {
            [self trackInterstitialAdLoadFailed:error];
        }
        return;
    }
    
    if (self.isC2SBiding) {
        NSString *priceStr = [NSString stringWithFormat:@"%ld", (long)[interstitialAd eCPM]];
        ATAMPSCustomBiddingRequest *request = [[ATAMPSC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
        // HJC: 构造 ATBidInfo 对象用于返回给 SDK
        // HJC: 使用 SDK 6.4.93 最新 API，添加 sortPrice 参数（用于 waterfall 排序，通常与 price 相同）
        ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID unitGroupUnitID:request.unitGroup.unitID adapterClassString:request.unitGroup.adapterClassString price:priceStr sortPrice:priceStr currencyType:ATBiddingCurrencyTypeCNYCents expirationInterval:request.unitGroup.bidTokenTime customObject:interstitialAd];
        bidInfo.networkFirmID = request.unitGroup.networkFirmID;
        if (request.bidCompletion) {
            request.bidCompletion(bidInfo, nil);
        }
        self.isC2SBiding = NO;
    } else {
        [self trackInterstitialAdLoaded:interstitialAd adExtra:@{}];
    }
}

// HJC: 插屏广告请求失败
- (void)ampsInterstitialAdLoadFail:(AMPSInterstitialAd *)interstitialAd error:(NSError *)error {
    if (self.isC2SBiding) {
        ATAMPSCustomBiddingRequest *request = [[ATAMPSC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
        // HJC: 返回获取竞价广告失败
        if (request.bidCompletion) {
            request.bidCompletion(nil, error);
        }
        self.isC2SBiding = NO;
    } else {
        [self trackInterstitialAdLoadFailed:error];
    }
}

// HJC: 插屏广告渲染成功
- (void)ampsInterstitialAdRenderSuccess:(AMPSInterstitialAd *)interstitialAd {
    // HJC: 渲染成功，可以展示
}

// HJC: 插屏广告渲染失败
- (void)ampsInterstitialAdRenderFail:(AMPSInterstitialAd *)interstitialAd error:(NSError *)error {
    [self trackInterstitialAdLoadFailed:error];
}

// HJC: 插屏广告显示失败
- (void)ampsInterstitialAdShowFail:(AMPSInterstitialAd *)interstitialAd error:(NSError *)error {
    [self trackInterstitialAdLoadFailed:error];
}

// HJC: 插屏广告曝光
- (void)ampsInterstitialAdDidShow:(AMPSInterstitialAd *)interstitialAd {
    [self trackInterstitialAdShow];
}

// HJC: 插屏广告点击
- (void)ampsInterstitialAdDidClick:(AMPSInterstitialAd *)interstitialAd {
    [self trackInterstitialAdClick];
}

// HJC: 插屏广告关闭
- (void)ampsInterstitialAdDidClose:(AMPSInterstitialAd *)interstitialAd {
    [self trackInterstitialAdClose:@{}];
}

@end

