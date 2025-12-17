//
//  ATBZSplashCustomEvent.m
//  AnyThinkSDKDemo
//
//  Created by nie adhub on 2023/10/23.
//  Copyright © 2023 抽筋的灯. All rights reserved.
//

#import "ATBZSplashCustomEvent.h"
#import "ATBZCustomBiddingRequest.h"
#import "ATBZC2SBiddingRequestManager.h"

@implementation ATBZSplashCustomEvent

- (NSString *)networkUnitId {
    return self.serverInfo[@"unitid"];
}

- (void)removeCustomViewAndsplashAd:(BeiZiSplash *)splashAd {
    if (self.containerView) {
        [self.containerView removeFromSuperview];
    }
    if (splashAd) {
        [splashAd BeiZi_removeSplashAd];
    }
}

/**
 @return 展示下部logo位置，需要给传入view设置尺寸。
 */
- (UIView *)BeiZi_splashBottomView {
    return self.containerView;
}

/**
 开屏请求成功
 */
- (void)BeiZi_splashDidLoadSuccess:(BeiZiSplash *)beiziSplash {
    if ([[NSDate date] timeIntervalSinceDate:_expireDate] > 0) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"It took too long for BZ to load splash."}];
        [self trackSplashAdLoadFailed:error];
        if (beiziSplash) {
            [beiziSplash BeiZi_removeSplashAd];
        }
        return;
    }
    if (self.isC2SBiding) {
        NSString *priceStr = [NSString stringWithFormat:@"%ld",beiziSplash.eCPM];
        ATBZCustomBiddingRequest *request = [[ATBZC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
        //构造ATBidInfo对象用于返回给SDK
        ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID unitGroupUnitID:request.unitGroup.unitID adapterClassString:request.unitGroup.adapterClassString price:priceStr currencyType:ATBiddingCurrencyTypeCNYCents expirationInterval:request.unitGroup.bidTokenTime customObject:beiziSplash];
        bidInfo.networkFirmID = request.unitGroup.networkFirmID;
        if (request.bidCompletion) {
            request.bidCompletion(bidInfo, nil);
        }
        self.isC2SBiding = NO;
    } else {
        [self trackSplashAdLoaded:beiziSplash];
    }
}
/**
 开屏展现
 */
- (void)BeiZi_splashDidPresentScreen:(BeiZiSplash *)beiziSplash {
    [self trackSplashAdShow];
}

/**
 开屏点击
 */
- (void)BeiZi_splashDidClick:(BeiZiSplash *)beiziSplash {
    [self trackSplashAdClick];
}

/**
 开屏已经消失
 */
- (void)BeiZi_splashDidDismissScreen:(BeiZiSplash *)beiziSplash {
    [self removeCustomViewAndsplashAd:beiziSplash];
    [self trackSplashAdClosed:@{}];
}

/**
 开屏请求失败
 */
- (void)BeiZi_splash:(BeiZiSplash *)beiziSplash didFailToLoadAdWithError:(BeiZiRequestError *)error {
    if (self.isC2SBiding) {
        ATBZCustomBiddingRequest *request = [[ATBZC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
        // 返回获取竞价广告失败
        if (request.bidCompletion) {
            request.bidCompletion(nil, error);
        }
        self.isC2SBiding = NO;
    } else {
        [self trackSplashAdLoadFailed:error];
    }
    if (beiziSplash) {
        [beiziSplash BeiZi_removeSplashAd];
    }
}


@end
