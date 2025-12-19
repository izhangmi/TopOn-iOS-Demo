//
//  ATAMPSCustomNativeUnifiedDelegate.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//
// HJC: 按照文档 https://help.takuad.com/docs/HSVTKS6M 实现
// HJC: 原生自渲染广告代理实现文件

#import "ATAMPSCustomNativeUnifiedDelegate.h"
#import "ATAMPSCustomNativeObject.h"
#import "../ATAMPSCustomBiddingRequest.h"
#import "../ATAMPSC2SBiddingRequestManager.h"
#import <AnyThinkSDK/NSDictionary+KAKit.h>

// HJC: ATAMPS 原生自渲染广告代理实现
// HJC: 按照文档 4.4 实现
@implementation ATAMPSCustomNativeUnifiedDelegate

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

#pragma mark - AMPSUnifiedNativeManagerDelegate
// HJC: 自渲染原生广告请求成功
- (void)ampsNativeAdLoadSuccess:(AMPSUnifiedNativeManager *)nativeManager {
    NSLog(@"HJC测试: ✅ [Unified] ampsNativeAdLoadSuccess 被调用，nativeManager = %@", nativeManager);
    
    if (nativeManager.adArray.count > 0) {
        AMPSUnifiedNativeAd *nativeAd = nativeManager.adArray.firstObject;
        if (!nativeAd) {
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load native.", NSLocalizedFailureReasonErrorKey:@"Unified native ad is nil."}];
            if (self.adStatusBridge) {
                [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
            }
            return;
        }
        
        AMPSUnifiedNativeView *nativeView = [[AMPSUnifiedNativeView alloc] init];
        nativeView.viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        nativeView.delegate = self;
        [nativeView refreshData:nativeAd];
        
        NSInteger ecpm = [nativeView eCPM];
        NSLog(@"HJC测试: 获取到广告价格 eCPM = %ld, isC2SBiding = %@", (long)ecpm, self.isC2SBiding ? @"YES" : @"NO");
        
        NSString *priceStr = [NSString stringWithFormat:@"%ld", (long)ecpm];
        if ([priceStr doubleValue] < 0) {
            priceStr = @"0";
        }
        
        // HJC: 处理 C2S 竞价逻辑
        if (self.isC2SBiding) {
            ATAMPSCustomBiddingRequest *request = [[ATAMPSC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
            if (request) {
                ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID 
                                                          unitGroupUnitID:request.unitGroup.unitID 
                                                     adapterClassString:request.unitGroup.adapterClassString 
                                                                   price:priceStr 
                                                               sortPrice:priceStr 
                                                             currencyType:ATBiddingCurrencyTypeCNYCents 
                                                       expirationInterval:request.unitGroup.bidTokenTime 
                                                             customObject:nativeView];
                bidInfo.networkFirmID = request.unitGroup.networkFirmID;
                if (request.bidCompletion) {
                    request.bidCompletion(bidInfo, nil);
                    NSLog(@"HJC测试: ✅ C2S 竞价成功，已返回 ATBidInfo");
                }
            }
            self.isC2SBiding = NO;
        } else {
            // HJC: 普通加载，创建 ATAMPSCustomNativeObject 对象
            ATAMPSCustomNativeObject *customNativeAd = [[ATAMPSCustomNativeObject alloc] init];
            customNativeAd.title = nativeAd.title;
            customNativeAd.mainText = nativeAd.desc;
            customNativeAd.iconUrl = nativeAd.iconUrl;
            customNativeAd.imageUrl = nativeAd.imageUrl;
            customNativeAd.logoUrl = nativeAd.adLogoUrl;
            customNativeAd.isExpressAd = NO;
            customNativeAd.nativeAdRenderType = ATNativeAdRenderSelfRender;
            customNativeAd.isVideoContents = (nativeAd.nativeMode == AMPSUnifiedNativeModeUnifiedVideo);
            customNativeAd.mediaView = nativeView;
            customNativeAd.unifiedNativeView = nativeView;
            // HJC: 从 delegate 获取 unifiedNativeManager（普通加载时）或从 request 获取（C2S 竞价时）
            if (self.unifiedNativeManager) {
                customNativeAd.unifiedNativeManager = self.unifiedNativeManager;
            } else {
                ATAMPSCustomBiddingRequest *request = [[ATAMPSC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
                if (request && [request.customObject isKindOfClass:[AMPSUnifiedNativeManager class]]) {
                    customNativeAd.unifiedNativeManager = (AMPSUnifiedNativeManager *)request.customObject;
                } else {
                    customNativeAd.unifiedNativeManager = (AMPSUnifiedNativeManager *)nativeManager;
                }
            }
            
            NSArray<ATCustomNetworkNativeAd *> *nativeAdArray = @[customNativeAd];
            NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
            [infoDic AT_setDictValue:priceStr key:ATAdSendC2SBidPriceKey];
            [infoDic AT_setDictValue:@(ATBiddingCurrencyTypeCNYCents) key:ATAdSendC2SCurrencyTypeKey];
            
            if (self.adStatusBridge && [self.adStatusBridge respondsToSelector:@selector(atOnNativeAdLoadedArray:adExtra:)]) {
                [self.adStatusBridge atOnNativeAdLoadedArray:nativeAdArray adExtra:infoDic];
                NSLog(@"HJC测试: ✅ 已调用 adStatusBridge.atOnNativeAdLoadedArray:adExtra: 传递价格信息");
            }
        }
    }
}

// HJC: 自渲染原生广告请求失败
- (void)ampsNativeAdLoadFail:(AMPSUnifiedNativeManager *)nativeManager error:(NSError *)error {
    NSLog(@"HJC测试: ❌ [Unified] ampsNativeAdLoadFail 被调用，error = %@, isC2SBiding = %@", error, self.isC2SBiding ? @"YES" : @"NO");
    
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
}

#pragma mark - AMPSUnifiedNativeViewDelegate
// HJC: 自渲染原生广告视图渲染成功
- (void)ampsNativeAdRenderSuccess:(AMPSUnifiedNativeView *)nativeView {
    NSLog(@"HJC测试: ✅ [Unified] ampsNativeAdRenderSuccess 被调用");
}

// HJC: 自渲染原生广告视图渲染失败
- (void)ampsNativeAdRenderFail:(AMPSUnifiedNativeView *)nativeView error:(NSError *)error {
    NSLog(@"HJC测试: ❌ [Unified] ampsNativeAdRenderFail 被调用，error = %@", error);
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
    }
}

// HJC: 自渲染原生广告视图曝光
- (void)ampsNativeAdExposured:(AMPSUnifiedNativeView *)nativeView {
    NSLog(@"HJC测试: ✅ [Unified] ampsNativeAdExposured 被调用");
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdShow:nil];
    }
}

// HJC: 自渲染原生广告视图点击
- (void)ampsNativeAdDidClick:(AMPSUnifiedNativeView *)nativeView {
    NSLog(@"HJC测试: ✅ [Unified] ampsNativeAdDidClick 被调用");
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdClick:nil];
    }
}

// HJC: 自渲染原生广告视图关闭
- (void)ampsNativeAdDidClose:(AMPSUnifiedNativeView *)nativeView {
    NSLog(@"HJC测试: ✅ [Unified] ampsNativeAdDidClose 被调用");
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdClosed:nil];
    }
}

@end

