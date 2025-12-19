//
//  ATAMPSCustomInterstitialDelegate.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//
// HJC: 按照文档实现插屏广告代理实现文件

#import "ATAMPSCustomInterstitialDelegate.h"
#import "../ATAMPSCustomBiddingRequest.h"
#import "../ATAMPSC2SBiddingRequestManager.h"
#import <AnyThinkSDK/NSDictionary+KAKit.h>

// HJC: ATAMPS 插屏广告代理实现
@implementation ATAMPSCustomInterstitialDelegate

// HJC: 初始化方法
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
// HJC: 插屏广告请求成功
// HJC: 按照 C2S 竞价文档，使用 atOnInterstitialAdLoadedExtra: 传递价格信息
- (void)ampsInterstitialAdLoadSuccess:(AMPSInterstitialAd *)interstitialAd {
    NSLog(@"HJC测试: ✅ ampsInterstitialAdLoadSuccess 被调用，interstitialAd = %@, isC2SBiding = %@", interstitialAd, self.isC2SBiding ? @"YES" : @"NO");
    
    // HJC: 通过第三方广告 SDK 获取价格
    NSInteger ecpm = [interstitialAd eCPM];
    NSLog(@"HJC测试: 获取到广告价格 eCPM = %ld", (long)ecpm);
    
    // HJC: 转为字符串
    NSString *priceStr = [NSString stringWithFormat:@"%ld", (long)ecpm];
    NSLog(@"HJC测试: C2S Original priceStr :%@", priceStr);
    
    // HJC: 参数检查
    if ([priceStr doubleValue] < 0) {
        priceStr = @"0";
    }
    
    // HJC: 处理 C2S 竞价逻辑
    if (self.isC2SBiding) {
        // HJC: C2S 竞价，构造 ATBidInfo 并返回
        ATAMPSCustomBiddingRequest *request = [[ATAMPSC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
        if (request) {
            // HJC: 使用 SDK 6.5.40 最新 API，添加 sortPrice 参数
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
                NSLog(@"HJC测试: ✅ C2S 竞价成功，已返回 ATBidInfo");
            }
        }
        self.isC2SBiding = NO;
    } else {
        // HJC: 普通加载，传递价格信息
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
        
        // HJC: 传入价格字符串（按照文档使用 AT_setDictValue）
        [infoDic AT_setDictValue:priceStr key:ATAdSendC2SBidPriceKey];
        
        // HJC: 根据第三方广告 SDK 的价格单位，传入币种（AMPSAd SDK 使用人民币分）
        [infoDic AT_setDictValue:@(ATBiddingCurrencyTypeCNYCents) key:ATAdSendC2SCurrencyTypeKey];
        
        NSLog(@"HJC测试: 获取到C2S信息:[Network:C2S]::%@", infoDic);
        
        // HJC: 按照 C2S 竞价文档，使用 atOnInterstitialAdLoadedExtra: 传递价格信息给 SDK
        if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnInterstitialAdLoadedExtra:)]) {
            [self.adStatusBridge atOnInterstitialAdLoadedExtra:infoDic];
            NSLog(@"HJC测试: ✅ 已调用 adStatusBridge.atOnInterstitialAdLoadedExtra: 传递价格信息");
        }
    }
}

// HJC: 插屏广告请求失败
- (void)ampsInterstitialAdLoadFail:(AMPSInterstitialAd *)interstitialAd error:(NSError *)error {
    NSLog(@"HJC测试: ❌ ampsInterstitialAdLoadFail 被调用，error = %@, isC2SBiding = %@", error, self.isC2SBiding ? @"YES" : @"NO");
    
    if (self.isC2SBiding) {
        // HJC: C2S 竞价失败，通过 bidCompletion 返回错误
        ATAMPSCustomBiddingRequest *request = [[ATAMPSC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
        if (request.bidCompletion) {
            request.bidCompletion(nil, error);
            NSLog(@"HJC测试: ❌ C2S 竞价失败，已返回错误");
        }
        self.isC2SBiding = NO;
    } else {
        // HJC: 普通加载失败
        if (self.adStatusBridge) {
            [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
        }
    }
}

// HJC: 插屏广告渲染成功
- (void)ampsInterstitialAdRenderSuccess:(AMPSInterstitialAd *)interstitialAd {
    NSLog(@"HJC测试: ✅ ampsInterstitialAdRenderSuccess 被调用");
}

// HJC: 插屏广告渲染失败
- (void)ampsInterstitialAdRenderFail:(AMPSInterstitialAd *)interstitialAd error:(NSError *)error {
    NSLog(@"HJC测试: ❌ ampsInterstitialAdRenderFail 被调用，error = %@", error);
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
    }
}

// HJC: 插屏广告显示失败
- (void)ampsInterstitialAdShowFail:(AMPSInterstitialAd *)interstitialAd error:(NSError *)error {
    NSLog(@"HJC测试: ❌ ampsInterstitialAdShowFail 被调用，error = %@", error);
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdShowFailed:error extra:nil];
    }
}

// HJC: 插屏广告曝光
- (void)ampsInterstitialAdDidShow:(AMPSInterstitialAd *)interstitialAd {
    NSLog(@"HJC测试: ✅ ampsInterstitialAdDidShow 被调用");
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdShow:nil];
    }
}

// HJC: 插屏广告点击
- (void)ampsInterstitialAdDidClick:(AMPSInterstitialAd *)interstitialAd {
    NSLog(@"HJC测试: ✅ ampsInterstitialAdDidClick 被调用");
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdClick:nil];
    }
}

// HJC: 插屏广告关闭
- (void)ampsInterstitialAdDidClose:(AMPSInterstitialAd *)interstitialAd {
    NSLog(@"HJC测试: ✅ ampsInterstitialAdDidClose 被调用");
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdClosed:nil];
    }
}

@end

