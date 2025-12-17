//
//  ATAMPSUnifiedNativeCustomEvent.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import "ATAMPSUnifiedNativeCustomEvent.h"
#import "ATAMPSCustomBiddingRequest.h"
#import "ATAMPSC2SBiddingRequestManager.h"

// HJC: AMPSAd Native 自渲染广告自定义事件实现
@implementation ATAMPSUnifiedNativeCustomEvent

// HJC: 返回广告位 ID
- (NSString *)networkUnitId {
    return self.serverInfo[@"unitid"];
}

#pragma mark - AMPSUnifiedNativeManagerDelegate
// HJC: 自渲染原生广告请求成功
- (void)ampsNativeAdLoadSuccess:(AMPSUnifiedNativeManager *)nativeManager {
    if (nativeManager.adArray.count > 0) {
        NSMutableArray<NSDictionary*>* assets = [NSMutableArray<NSDictionary*> array];
        NSMutableDictionary *asset = [NSMutableDictionary dictionary];
        
        AMPSUnifiedNativeAd *nativeAd = nativeManager.adArray.firstObject;
        if (!nativeAd) {
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load native.", NSLocalizedFailureReasonErrorKey:@"Unified native ad is nil."}];
            if (self.isC2SBiding) {
                ATAMPSCustomBiddingRequest *request = [[ATAMPSC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
                if (request.bidCompletion) {
                    request.bidCompletion(nil, error);
                }
                self.isC2SBiding = NO;
            } else {
                [self trackNativeAdLoadFailed:error];
            }
            return;
        }
        
        AMPSUnifiedNativeView *nativeView = [[AMPSUnifiedNativeView alloc] init];
        nativeView.viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        nativeView.delegate = self;
        [nativeView refreshData:nativeAd];
        
        [asset setValue:self forKey:kATAdAssetsCustomEventKey];
        [asset setValue:nativeView forKey:kATAdAssetsCustomObjectKey];
        // HJC: 标记为自渲染广告
        [asset setValue:@NO forKey:kATNativeADAssetsIsExpressAdKey];
        [asset setValue:nativeAd.title forKey:kATNativeADAssetsMainTitleKey];
        [asset setValue:nativeAd.desc forKey:kATNativeADAssetsMainTextKey];
        [asset setValue:nativeAd.iconUrl forKey:kATNativeADAssetsIconURLKey];
        [asset setValue:nativeAd.imageUrl forKey:kATNativeADAssetsImageURLKey];
        [asset setValue:nativeAd.adLogoUrl forKey:kATNativeADAssetsLogoURLKey];
        [asset setValue:@(nativeAd.nativeMode == AMPSUnifiedNativeModeUnifiedVideo) forKey:kATNativeADAssetsContainsVideoFlag];
        [assets addObject:asset];
        
        if (self.requestCompletionBlock) {
            self.requestCompletionBlock(assets, nil);
        }
        
        if (self.isC2SBiding) {
            NSString *priceStr = [NSString stringWithFormat:@"%ld", (long)[nativeView eCPM]];
            ATAMPSCustomBiddingRequest *request = [[ATAMPSC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
            // HJC: 构造 ATBidInfo 对象用于返回给 SDK，customObject 使用 nativeView
            ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID unitGroupUnitID:request.unitGroup.unitID adapterClassString:request.unitGroup.adapterClassString price:priceStr currencyType:ATBiddingCurrencyTypeCNYCents expirationInterval:request.unitGroup.bidTokenTime customObject:nativeView];
            bidInfo.networkFirmID = request.unitGroup.networkFirmID;
            if (request.bidCompletion) {
                request.bidCompletion(bidInfo, nil);
            }
            request.assets = assets;
            self.isC2SBiding = NO;
        }
    }
}

// HJC: 自渲染原生广告请求失败
- (void)ampsNativeAdLoadFail:(AMPSUnifiedNativeManager *)nativeManager error:(NSError *)error {
    if (self.isC2SBiding) {
        ATAMPSCustomBiddingRequest *request = [[ATAMPSC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
        // HJC: 返回获取竞价广告失败
        if (request.bidCompletion) {
            request.bidCompletion(nil, error);
        }
        self.isC2SBiding = NO;
    } else {
        [self trackNativeAdLoadFailed:error];
    }
}

#pragma mark - AMPSUnifiedNativeViewDelegate
// HJC: 自渲染原生广告视图渲染成功
- (void)ampsNativeAdRenderSuccess:(AMPSUnifiedNativeView *)nativeView {
    // HJC: 渲染成功，可以进行展示
}

// HJC: 自渲染原生广告视图渲染失败
- (void)ampsNativeAdRenderFail:(AMPSUnifiedNativeView *)nativeView error:(NSError *)error {
    // HJC: 渲染失败处理
    [self trackNativeAdLoadFailed:error];
}

// HJC: 自渲染原生广告视图曝光
- (void)ampsNativeAdExposured:(AMPSUnifiedNativeView *)nativeView {
    [self trackNativeAdImpression];
}

// HJC: 自渲染原生广告视图点击
- (void)ampsNativeAdDidClick:(AMPSUnifiedNativeView *)nativeView {
    [self trackNativeAdClick];
}

// HJC: 自渲染原生广告视图关闭
- (void)ampsNativeAdDidClose:(AMPSUnifiedNativeView *)nativeView {
    [self trackNativeAdClosed];
}

@end

