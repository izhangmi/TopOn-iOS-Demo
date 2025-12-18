//
//  ATAMPSNativeExpressCustomEvent.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import "ATAMPSNativeExpressCustomEvent.h"
#import "ATAMPSCustomBiddingRequest.h"
#import "ATAMPSC2SBiddingRequestManager.h"

// HJC: AMPSAd Native 模板广告自定义事件实现
@implementation ATAMPSNativeExpressCustomEvent

// HJC: 返回广告位 ID
- (NSString *)networkUnitId {
    return self.serverInfo[@"unitid"];
}

#pragma mark - AMPSNativeExpressManagerDelegate
// HJC: 原生模板广告请求成功
- (void)ampsNativeAdLoadSuccess:(AMPSNativeExpressManager *)nativeAd {
    if (nativeAd.viewsArray.count > 0) {
        NSMutableArray<NSDictionary*>* assets = [NSMutableArray<NSDictionary*> array];
        NSMutableDictionary *asset = [NSMutableDictionary dictionary];
        
        AMPSNativeExpressView *expressView = nativeAd.viewsArray.firstObject;
        if (!expressView) {
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load native.", NSLocalizedFailureReasonErrorKey:@"Express view is nil."}];
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
        
        expressView.viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        expressView.delegate = self;
        
        asset[@"amps_nativeexpress_manager"] = nativeAd;
        [asset setValue:self forKey:kATAdAssetsCustomEventKey];
        [asset setValue:expressView forKey:kATAdAssetsCustomObjectKey];
        // HJC: 标记为模板广告
        [asset setValue:@YES forKey:kATNativeADAssetsIsExpressAdKey];
        
        // HJC: 渲染广告视图
        [expressView renderAd];
        
        // HJC: 等待渲染完成后再设置尺寸
        dispatch_async(dispatch_get_main_queue(), ^{
            [asset setValue:@(expressView.frame.size.width) forKey:kATNativeADAssetsNativeExpressAdViewWidthKey];
            [asset setValue:@(expressView.frame.size.height) forKey:kATNativeADAssetsNativeExpressAdViewHeightKey];
            [assets addObject:asset];
            
            if (self.requestCompletionBlock) {
                self.requestCompletionBlock(assets, nil);
            }
            
            if (self.isC2SBiding) {
                NSString *priceStr = [NSString stringWithFormat:@"%ld", (long)[expressView eCPM]];
                ATAMPSCustomBiddingRequest *request = [[ATAMPSC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
                // HJC: 构造 ATBidInfo 对象用于返回给 SDK，customObject 使用 expressView
                // HJC: 使用 SDK 6.4.93 最新 API，添加 sortPrice 参数（用于 waterfall 排序，通常与 price 相同）
                ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID unitGroupUnitID:request.unitGroup.unitID adapterClassString:request.unitGroup.adapterClassString price:priceStr sortPrice:priceStr currencyType:ATBiddingCurrencyTypeCNYCents expirationInterval:request.unitGroup.bidTokenTime customObject:expressView];
                bidInfo.networkFirmID = request.unitGroup.networkFirmID;
                if (request.bidCompletion) {
                    request.bidCompletion(bidInfo, nil);
                }
                request.assets = assets;
                self.isC2SBiding = NO;
            }
        });
    }
}

// HJC: 原生模板广告请求失败
- (void)ampsNativeAdLoadFail:(AMPSNativeExpressManager *)nativeAd error:(NSError *)error {
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

#pragma mark - AMPSNativeExpressViewDelegate
// HJC: 原生模板广告视图渲染成功
- (void)ampsNativeAdRenderSuccess:(AMPSNativeExpressView *)nativeView {
    // HJC: 渲染成功，可以进行展示
}

// HJC: 原生模板广告视图渲染失败
- (void)ampsNativeAdRenderFail:(AMPSNativeExpressView *)nativeView error:(NSError *)error {
    // HJC: 渲染失败处理
    [self trackNativeAdLoadFailed:error];
}

// HJC: 原生模板广告视图曝光
- (void)ampsNativeAdExposured:(AMPSNativeExpressView *)nativeView {
    [self trackNativeAdImpression];
}

// HJC: 原生模板广告视图点击
- (void)ampsNativeAdDidClick:(AMPSNativeExpressView *)nativeView {
    [self trackNativeAdClick];
}

// HJC: 原生模板广告视图关闭
- (void)ampsNativeAdDidClose:(AMPSNativeExpressView *)nativeView {
    [self trackNativeAdClosed];
}

@end

