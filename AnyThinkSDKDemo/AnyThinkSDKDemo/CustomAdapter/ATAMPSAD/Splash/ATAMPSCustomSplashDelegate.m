//
//  ATAMPSCustomSplashDelegate.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//
// HJC: 按照文档 https://help.takuad.com/docs/UpnVkNF1 实现
// HJC: 开屏广告代理实现文件

#import "ATAMPSCustomSplashDelegate.h"
#import "../ATAMPSCustomBiddingRequest.h"
#import "../ATAMPSC2SBiddingRequestManager.h"
#import <AnyThinkSDK/NSDictionary+KAKit.h>

// HJC: ATAMPS 开屏广告代理实现
// HJC: 按照文档 4.2 实现
@implementation ATAMPSCustomSplashDelegate

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
// HJC: 按照文档 4.2，广告加载成功时调用 atOnAdMetaLoadFinish:
// HJC: 按照 C2S 竞价文档 https://help.takuad.com/docs/9IQVOUk5，需要传递价格信息
- (void)ampsSplashAdLoadSuccess:(AMPSSplashAd *)splashAd {
    NSLog(@"HJC测试: ✅ ampsSplashAdLoadSuccess 被调用，splashAd = %@, isC2SBiding = %@", splashAd, self.isC2SBiding ? @"YES" : @"NO");
    
    // HJC: 检查是否过期
    if (self.expireDate && [[NSDate date] timeIntervalSinceDate:self.expireDate] > 0) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"It took too long for AMPS to load splash."}];
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
        if (splashAd) {
            [splashAd removeSplashAd];
        }
        return;
    }
    
    // HJC: 通过第三方广告 SDK 获取价格
    NSInteger ecpm = [splashAd eCPM];
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
            // HJC: 使用 SDK 6.5.40 最新 API，添加 sortPrice 参数（用于 waterfall 排序，通常与 price 相同）
            ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID 
                                                      unitGroupUnitID:request.unitGroup.unitID 
                                                 adapterClassString:request.unitGroup.adapterClassString 
                                                               price:priceStr 
                                                           sortPrice:priceStr 
                                                         currencyType:ATBiddingCurrencyTypeCNYCents 
                                                   expirationInterval:request.unitGroup.bidTokenTime 
                                                         customObject:splashAd];
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
        
        // HJC: 按照文档 4.2，使用 atOnSplashAdLoadedExtra: 传递价格信息
        if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnSplashAdLoadedExtra:)]) {
            [self.adStatusBridge atOnSplashAdLoadedExtra:infoDic];
            NSLog(@"HJC测试: ✅ 已调用 adStatusBridge.atOnSplashAdLoadedExtra: 传递价格信息");
        } else {
            // HJC: 如果 atOnSplashAdLoadedExtra: 不存在，使用 atOnAdMetaLoadFinish:
            if (self.adStatusBridge) {
                [self.adStatusBridge atOnAdMetaLoadFinish:infoDic];
            }
        }
    }
}

// HJC: 开屏请求失败
// HJC: 按照文档 4.2，广告加载失败时调用 atOnAdLoadFailed:adExtra:
- (void)ampsSplashAdLoadFail:(AMPSSplashAd *)splashAd error:(NSError *)error {
    NSLog(@"HJC测试: ❌ ampsSplashAdLoadFail 被调用，error = %@, isC2SBiding = %@", error, self.isC2SBiding ? @"YES" : @"NO");
    
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
            NSLog(@"HJC测试: ✅ 已调用 adStatusBridge.atOnAdLoadFailed:adExtra:");
        }
    }
    
    if (splashAd) {
        [splashAd removeSplashAd];
    }
}

// HJC: 开屏广告渲染成功
- (void)ampsSplashAdRenderSuccess:(AMPSSplashAd *)splashAd {
    NSLog(@"HJC测试: ✅ ampsSplashAdRenderSuccess 被调用");
}

// HJC: 开屏渲染失败
// HJC: 按照文档，使用 adStatusBridge.atOnAdLoadFailed:adExtra: 来通知广告加载失败
- (void)ampsSplashAdRenderFail:(AMPSSplashAd *)splashAd error:(NSError *)error {
    NSLog(@"HJC测试: ❌ ampsSplashAdRenderFail 被调用，error = %@", error);
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
    }
}

// HJC: 开屏广告显示失败
// HJC: 按照文档，使用 adStatusBridge.atOnAdShowFailed:extra: 来通知广告展示失败
- (void)ampsSplashAdShowFail:(AMPSSplashAd *)splashAd error:(NSError *)error {
    NSLog(@"HJC测试: ❌ ampsSplashAdShowFail 被调用，error = %@", error);
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdShowFailed:error extra:nil];
    }
}

// HJC: 开屏广告显示
- (void)ampsSplashAdDidShow:(AMPSSplashAd *)splashAd {
    NSLog(@"HJC测试: ✅ ampsSplashAdDidShow 被调用");
    // HJC: 注意：显示回调通常不需要上报，真正的曝光统计应该在 ampsSplashAdExposured 中上报
}

// HJC: 开屏广告曝光
// HJC: 按照文档 4.2，广告曝光时调用 atOnAdShow:（这是用于统计的关键回调）
// HJC: 参考 BeiZi 和 TM 的实现，曝光回调才是真正需要上报展示统计的地方
- (void)ampsSplashAdExposured:(AMPSSplashAd *)splashAd {
    NSLog(@"HJC测试: ✅ ampsSplashAdExposured 被调用（曝光回调，用于统计上报）");
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdShow:nil];
        NSLog(@"HJC测试: ✅ 已调用 adStatusBridge.atOnAdShow: 上报曝光统计");
    }
}

// HJC: 开屏广告点击
// HJC: 按照文档 4.2，广告被用户点击时调用 atOnAdClick:
- (void)ampsSplashAdDidClick:(AMPSSplashAd *)splashAd {
    NSLog(@"HJC测试: ✅ ampsSplashAdDidClick 被调用");
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdClick:nil];
    }
}

// HJC: 开屏广告关闭
// HJC: 按照文档 4.2，广告已关闭时调用 atOnAdClosed:
- (void)ampsSplashAdDidClose:(AMPSSplashAd *)splashAd {
    NSLog(@"HJC测试: ✅ ampsSplashAdDidClose 被调用");
    [self removeCustomViewAndsplashAd:splashAd];
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdClosed:nil];
    }
}

@end

