//
//  ATAMPSSplashCustomEvent.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import "ATAMPSSplashCustomEvent.h"
#import "ATAMPSCustomBiddingRequest.h"
#import "ATAMPSC2SBiddingRequestManager.h"

// HJC: AMPSAd Splash 广告自定义事件实现
@implementation ATAMPSSplashCustomEvent

// HJC: 返回广告位 ID
- (NSString *)networkUnitId {
    return self.serverInfo[@"unitid"];
}

// HJC: 移除自定义视图和开屏广告
- (void)removeCustomViewAndsplashAd:(AMPSSplashAd *)splashAd {
    if (self.containerView) {
        [self.containerView removeFromSuperview];
    }
    if (splashAd) {
        [splashAd removeSplashAd];
    }
}

#pragma mark - AMPSSplashAdDelegate
// HJC: 开屏广告请求成功
- (void)ampsSplashAdLoadSuccess:(AMPSSplashAd *)splashAd {
    // HJC: 检查是否过期
    if (self.expireDate && [[NSDate date] timeIntervalSinceDate:self.expireDate] > 0) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"It took too long for AMPS to load splash."}];
        [self trackSplashAdLoadFailed:error];
        if (splashAd) {
            [splashAd removeSplashAd];
        }
        return;
    }
    
    if (self.isC2SBiding) {
        NSString *priceStr = [NSString stringWithFormat:@"%ld", (long)[splashAd eCPM]];
        ATAMPSCustomBiddingRequest *request = [[ATAMPSC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
        // HJC: 构造 ATBidInfo 对象用于返回给 SDK
        // HJC: 使用 SDK 6.4.93 最新 API，添加 sortPrice 参数（用于 waterfall 排序，通常与 price 相同）
        ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID unitGroupUnitID:request.unitGroup.unitID adapterClassString:request.unitGroup.adapterClassString price:priceStr sortPrice:priceStr currencyType:ATBiddingCurrencyTypeCNYCents expirationInterval:request.unitGroup.bidTokenTime customObject:splashAd];
        bidInfo.networkFirmID = request.unitGroup.networkFirmID;
        if (request.bidCompletion) {
            request.bidCompletion(bidInfo, nil);
        }
        self.isC2SBiding = NO;
    } else {
        [self trackSplashAdLoaded:splashAd];
    }
}

// HJC: 开屏请求失败
- (void)ampsSplashAdLoadFail:(AMPSSplashAd *)splashAd error:(NSError *)error {
    if (self.isC2SBiding) {
        ATAMPSCustomBiddingRequest *request = [[ATAMPSC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
        // HJC: 返回获取竞价广告失败
        if (request.bidCompletion) {
            request.bidCompletion(nil, error);
        }
        self.isC2SBiding = NO;
    } else {
        [self trackSplashAdLoadFailed:error];
    }
    if (splashAd) {
        [splashAd removeSplashAd];
    }
}

// HJC: 开屏广告渲染成功
- (void)ampsSplashAdRenderSuccess:(AMPSSplashAd *)splashAd {
    // HJC: 渲染成功，可以展示
}

// HJC: 开屏渲染失败
- (void)ampsSplashAdRenderFail:(AMPSSplashAd *)splashAd error:(NSError *)error {
    [self trackSplashAdLoadFailed:error];
}

// HJC: 开屏广告显示失败
- (void)ampsSplashAdShowFail:(AMPSSplashAd *)splashAd error:(NSError *)error {
    [self trackSplashAdLoadFailed:error];
}

// HJC: 开屏广告显示
- (void)ampsSplashAdDidShow:(AMPSSplashAd *)splashAd {
    [self trackSplashAdShow];
}

// HJC: 开屏广告曝光
- (void)ampsSplashAdExposured:(AMPSSplashAd *)splashAd {
    // HJC: 曝光事件已在 didShow 中处理
}

// HJC: 开屏广告点击
- (void)ampsSplashAdDidClick:(AMPSSplashAd *)splashAd {
    [self trackSplashAdClick];
}

// HJC: 开屏广告关闭
- (void)ampsSplashAdDidClose:(AMPSSplashAd *)splashAd {
    [self removeCustomViewAndsplashAd:splashAd];
    [self trackSplashAdClosed:@{}];
}

@end

