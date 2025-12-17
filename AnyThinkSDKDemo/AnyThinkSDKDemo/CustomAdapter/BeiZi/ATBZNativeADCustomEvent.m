//
//  ATBZNativeADCustomEvent.m
//  AnyThinkSDKDemo
//
//  Created by nie adhub on 2023/10/24.
//  Copyright © 2023 抽筋的灯. All rights reserved.
//

#import "ATBZNativeADCustomEvent.h"
#import "ATBZCustomBiddingRequest.h"
#import "ATBZC2SBiddingRequestManager.h"

@interface ATBZNativeADCustomEvent ()

@end

@implementation ATBZNativeADCustomEvent

- (NSString *)networkUnitId {
    return self.serverInfo[@"unitid"];
}

/**
 原生模板广告请求成功
 */
- (void)BeiZi_nativeExpressDidLoad:(BeiZiNativeExpress *)beiziNativeExpress {
    if (beiziNativeExpress.channeNativeAdView.count > 0) {
        NSMutableArray<NSDictionary*>* assets = [NSMutableArray<NSDictionary*> array];
        NSMutableDictionary *asset = [NSMutableDictionary dictionary];
        beiziNativeExpress.beiziNativeViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        asset[@"tt_nativeexpress_manager"] = beiziNativeExpress;
        UIView *expressView = beiziNativeExpress.channeNativeAdView.firstObject;
        [asset setValue:self forKey:kATAdAssetsCustomEventKey];
        [asset setValue:expressView forKey:kATAdAssetsCustomObjectKey];
        // 原生模板广告
        [asset setValue:@YES forKey:kATNativeADAssetsIsExpressAdKey];
        [asset setValue:@(expressView.frame.size.width) forKey:kATNativeADAssetsNativeExpressAdViewWidthKey];
        [asset setValue:@(expressView.frame.size.height) forKey:kATNativeADAssetsNativeExpressAdViewHeightKey];
        [assets addObject:asset];
        if (self.requestCompletionBlock) {
            self.requestCompletionBlock(assets, nil);
        }
        if (self.isC2SBiding) {
            NSString *priceStr = [NSString stringWithFormat:@"%ld",beiziNativeExpress.eCPM];
            ATBZCustomBiddingRequest *request = [[ATBZC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
            //构造ATBidInfo对象用于返回给SDK
            ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID unitGroupUnitID:request.unitGroup.unitID adapterClassString:request.unitGroup.adapterClassString price:priceStr currencyType:ATBiddingCurrencyTypeCNYCents expirationInterval:request.unitGroup.bidTokenTime customObject:beiziNativeExpress];
            bidInfo.networkFirmID = request.unitGroup.networkFirmID;
            if (request.bidCompletion) {
                request.bidCompletion(bidInfo, nil);
            }
            request.assets = assets;
            self.isC2SBiding = NO;
        }
    }
}

/**
 原生模板广告显示
 */
- (void)BeiZi_nativeExpressDidShow:(BeiZiNativeExpress *)beiziNativeExpress {
    [self trackNativeAdImpression];
}

/**
 原生模板广告点击
 */
- (void)BeiZi_nativeExpressDidClick:(BeiZiNativeExpress *)beiziNativeExpress {
    [self trackNativeAdClick];
}

/**
 原生模板广告点击关闭
 */
- (void)BeiZi_nativeExpressDislikeDidClick:(BeiZiNativeExpress *)beiziNativeExpress {
    [self trackNativeAdClosed];
}

/**
 原生模板广告请求失败
 */
- (void)BeiZi_nativeExpress:(BeiZiNativeExpress *)beiziNativeExpress didFailToLoadAdWithError:(BeiZiRequestError *)error {
    if (self.isC2SBiding) {
        ATBZCustomBiddingRequest *request = [[ATBZC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
        // 返回获取竞价广告失败
        if (request.bidCompletion) {
            request.bidCompletion(nil, error);
        }
        self.isC2SBiding = NO;
    } else {
        [self trackNativeAdLoadFailed:error];
    }
}

/**
 自定义广告请求成功
 */
- (void)BeiZi_unifiedNativeDidLoadSuccess:(BeiZiUnifiedNative *)unifiedNative {
    if (unifiedNative.dataObject != nil) {
        NSMutableArray<NSDictionary*>* assets = [NSMutableArray<NSDictionary*> array];
        NSMutableDictionary *asset = [NSMutableDictionary dictionary];
        unifiedNative.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        [asset setValue:self forKey:kATAdAssetsCustomEventKey];
        [asset setValue:unifiedNative forKey:kATAdAssetsCustomObjectKey];
        [asset setValue:@NO forKey:kATNativeADAssetsIsExpressAdKey];
        [asset setValue:unifiedNative.dataObject.title forKey:kATNativeADAssetsMainTitleKey];
        [asset setValue:unifiedNative.dataObject.desc forKey:kATNativeADAssetsMainTextKey];
        [asset setValue:unifiedNative.dataObject.iconUrl forKey:kATNativeADAssetsIconURLKey];
        [asset setValue:unifiedNative.dataObject.imageUrl forKey:kATNativeADAssetsImageURLKey];
        [asset setValue:unifiedNative.dataObject.adLogoUrl forKey:kATNativeADAssetsLogoURLKey];
        [asset setValue:@(unifiedNative.dataObject.isVideoAd) forKey:kATNativeADAssetsContainsVideoFlag];
        [assets addObject:asset];
        if (self.requestCompletionBlock) {
            self.requestCompletionBlock(assets, nil);
        }
        if (self.isC2SBiding) {
            NSString *priceStr = [NSString stringWithFormat:@"%ld",unifiedNative.eCPM];
            ATBZCustomBiddingRequest *request = [[ATBZC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
            //构造ATBidInfo对象用于返回给SDK
            ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID unitGroupUnitID:request.unitGroup.unitID adapterClassString:request.unitGroup.adapterClassString price:priceStr currencyType:ATBiddingCurrencyTypeCNYCents expirationInterval:request.unitGroup.bidTokenTime customObject:unifiedNative];
            bidInfo.networkFirmID = request.unitGroup.networkFirmID;
            if (request.bidCompletion) {
                request.bidCompletion(bidInfo, nil);
            }
            request.assets = assets;
            self.isC2SBiding = NO;
        }
    }
}

/**
 自定义展现
 */
- (void)BeiZi_unifiedNativePresentScreen:(BeiZiUnifiedNative *)unifiedNative {
    [self trackNativeAdImpression];
}

/**
 自定义点击
 */
- (void)BeiZi_unifiedNativeDidClick:(BeiZiUnifiedNative *)unifiedNative {
    [self trackNativeAdClick];
}

/**
 自定义请求失败
 */
- (void)BeiZi_unifiedNative:(BeiZiUnifiedNative *)unifiedNative didFailToLoadAdWithError:(BeiZiRequestError *)error {
    if (self.isC2SBiding) {
        ATBZCustomBiddingRequest *request = [[ATBZC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
        // 返回获取竞价广告失败
        if (request.bidCompletion) {
            request.bidCompletion(nil, error);
        }
        self.isC2SBiding = NO;
    } else {
        [self trackNativeAdLoadFailed:error];
    }
}

@end
