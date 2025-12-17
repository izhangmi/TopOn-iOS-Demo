//
//  ATBZRewardedVideoCustomEvent.m
//  AnyThinkSDKDemo
//
//  Created by nie adhub on 2025/7/20.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import "ATBZRewardedVideoCustomEvent.h"
#import "ATBZCustomBiddingRequest.h"
#import "ATBZC2SBiddingRequestManager.h"

@implementation ATBZRewardedVideoCustomEvent

- (NSString *)networkUnitId {
    return self.serverInfo[@"unitid"];
}

/**
 激励视频物料请求成功
 */
- (void)BeiZi_rewardedVideoDidReceiveAd:(BeiZiRewardedVideo *)beiziRewardedVideo {
    if (self.isC2SBiding) {
        NSString *priceStr = [NSString stringWithFormat:@"%ld",beiziRewardedVideo.eCPM];
        ATBZCustomBiddingRequest *request = [[ATBZC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
        //构造ATBidInfo对象用于返回给SDK
        ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID unitGroupUnitID:request.unitGroup.unitID adapterClassString:request.unitGroup.adapterClassString price:priceStr currencyType:ATBiddingCurrencyTypeCNYCents expirationInterval:request.unitGroup.bidTokenTime customObject:beiziRewardedVideo];
        bidInfo.networkFirmID = request.unitGroup.networkFirmID;
        if (request.bidCompletion) {
            request.bidCompletion(bidInfo, nil);
        }
        self.isC2SBiding = NO;
    } else {
        [self trackRewardedVideoAdLoaded:beiziRewardedVideo adExtra:@{}];
    }
}

/**
 激励展现并开始播放视频
 */
- (void)BeiZi_rewardedVideoDidStartPlay:(BeiZiRewardedVideo *)beiziRewardedVideo {
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

/**
 激励视频点击
 */
- (void)BeiZi_rewardedVideoDidClick:(BeiZiRewardedVideo *)beiziRewardedVideo {
    [self trackRewardedVideoAdClick];
}

/**
 激励视频消失
 */
- (void)BeiZi_rewardedVideoDidDismissScreen:(BeiZiRewardedVideo *)beiziRewardedVideo {
    [self trackRewardedVideoAdCloseRewarded:NO extra:@{}];
}

/**
 激励视频请求失败
 */
- (void)BeiZi_rewardedVideo:(BeiZiRewardedVideo *)beiziRewardedVideo
   didFailToLoadAdWithError:(BeiZiRequestError *)error {
    if (self.isC2SBiding) {
        ATBZCustomBiddingRequest *request = [[ATBZC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
        // 返回获取竞价广告失败
        if (request.bidCompletion) {
            request.bidCompletion(nil, error);
        }
        self.isC2SBiding = NO;
    } else {
        [self trackRewardedVideoAdLoadFailed:error];
    }
}

/**
 激励视频奖励
 如果有渠道时，此方法仅限用于给用户发放奖励回调，奖励内容不可用。
 @param reward 奖励内容 JSON字符串，自行解析
 */
- (void)BeiZi_rewardedVideo:(BeiZiRewardedVideo *)beiziRewardedVideo
    didRewardUserWithReward:(NSObject *)reward {
    [self trackRewardedVideoAdRewarded];
}

@end
