//
//  ATAMPSCustomNativeExpressDelegate.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//
// HJC: 按照文档 https://help.takuad.com/docs/HSVTKS6M 实现
// HJC: 原生模板广告代理实现文件

#import "ATAMPSCustomNativeExpressDelegate.h"
#import "ATAMPSCustomNativeObject.h"
#import "../ATAMPSCustomBiddingRequest.h"
#import "../ATAMPSC2SBiddingRequestManager.h"
#import <AnyThinkSDK/NSDictionary+KAKit.h>

// HJC: ATAMPS 原生模板广告代理实现
// HJC: 按照文档 4.4 实现
@implementation ATAMPSCustomNativeExpressDelegate

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

#pragma mark - AMPSNativeExpressManagerDelegate
// HJC: 模板原生广告请求成功
- (void)ampsNativeAdLoadSuccess:(AMPSNativeExpressManager *)nativeAd {
    NSLog(@"HJC测试: ✅ [Express] ampsNativeAdLoadSuccess 被调用，nativeAd = %@", nativeAd);
    
    if (nativeAd.viewsArray.count > 0) {
        AMPSNativeExpressView *expressView = nativeAd.viewsArray.firstObject;
        if (!expressView) {
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load native.", NSLocalizedFailureReasonErrorKey:@"Express view is nil."}];
            NSLog(@"HJC测试: ❌ Express view is nil");
            if (self.adStatusBridge) {
                [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
            }
            return;
        }
        
        expressView.viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        expressView.delegate = self;
        
        // HJC: 渲染广告视图
        [expressView renderAd];
        
        // HJC: 等待渲染完成后再创建 NativeObject
        dispatch_async(dispatch_get_main_queue(), ^{
            // HJC: 通过第三方广告 SDK 获取价格
            NSInteger ecpm = [expressView eCPM];
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
                                                                 customObject:expressView];
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
                customNativeAd.templateView = expressView;
                customNativeAd.nativeExpressAdViewWidth = expressView.frame.size.width;
                customNativeAd.nativeExpressAdViewHeight = expressView.frame.size.height;
                customNativeAd.isExpressAd = YES;
                customNativeAd.nativeAdRenderType = ATNativeAdRenderExpress;
                customNativeAd.nativeExpressView = expressView;
                // HJC: 从 delegate 获取 nativeExpressManager（普通加载时）或从 request 获取（C2S 竞价时）
                if (self.nativeExpressManager) {
                    customNativeAd.nativeExpressManager = self.nativeExpressManager;
                } else {
                    ATAMPSCustomBiddingRequest *request = [[ATAMPSC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
                    if (request && [request.customObject isKindOfClass:[AMPSNativeExpressManager class]]) {
                        customNativeAd.nativeExpressManager = (AMPSNativeExpressManager *)request.customObject;
                    } else {
                        customNativeAd.nativeExpressManager = (AMPSNativeExpressManager *)nativeAd;
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
        });
    }
}

// HJC: 模板原生广告请求失败
- (void)ampsNativeAdLoadFail:(AMPSNativeExpressManager *)nativeAd error:(NSError *)error {
    NSLog(@"HJC测试: ❌ [Express] ampsNativeAdLoadFail 被调用，error = %@, isC2SBiding = %@", error, self.isC2SBiding ? @"YES" : @"NO");
    
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

#pragma mark - AMPSNativeExpressViewDelegate
// HJC: 模板原生广告视图渲染成功
- (void)ampsNativeAdRenderSuccess:(AMPSNativeExpressView *)nativeView {
    NSLog(@"HJC测试: ✅ [Express] ampsNativeAdRenderSuccess 被调用");
}

// HJC: 模板原生广告视图渲染失败
- (void)ampsNativeAdRenderFail:(AMPSNativeExpressView *)nativeView error:(NSError *)error {
    NSLog(@"HJC测试: ❌ [Express] ampsNativeAdRenderFail 被调用，error = %@", error);
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
    }
}

// HJC: 模板原生广告视图曝光
- (void)ampsNativeAdExposured:(AMPSNativeExpressView *)nativeView {
    NSLog(@"HJC测试: ✅ [Express] ampsNativeAdExposured 被调用");
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdShow:nil];
    }
}

// HJC: 模板原生广告视图点击
- (void)ampsNativeAdDidClick:(AMPSNativeExpressView *)nativeView {
    NSLog(@"HJC测试: ✅ [Express] ampsNativeAdDidClick 被调用");
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdClick:nil];
    }
}

// HJC: 模板原生广告视图关闭
- (void)ampsNativeAdDidClose:(AMPSNativeExpressView *)nativeView {
    NSLog(@"HJC测试: ✅ [Express] ampsNativeAdDidClose 被调用");
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdClosed:nil];
    }
}

@end
