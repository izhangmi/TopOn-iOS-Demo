//
//  ATAMPSCustomNativeRenderer.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//
// HJC: Native 广告自定义渲染器实现文件

#import "ATAMPSCustomNativeRenderer.h"
#import "ATAMPSCustomNativeObject.h"
#import <AMPSAdSDK/AMPSAdSDK.h>

// HJC: ATAMPS Native 广告自定义渲染器实现
@interface ATAMPSCustomNativeRenderer ()

@property (nonatomic, strong) AMPSUnifiedNativeView *unifiedNativeView;

@end

@implementation ATAMPSCustomNativeRenderer

// HJC: 渲染广告 Offer
// HJC: 按照 SDK 6.5.40，参数类型应该是 ATAdOfferCacheModel *
- (void)renderOffer:(ATAdOfferCacheModel *)offer {
    [super renderOffer:offer];
    
    // HJC: 获取 customEvent（从 offer.nativeCustomEvent 或 offer.assets）
    id customEvent = offer.nativeCustomEvent;
    if (!customEvent) {
        customEvent = offer.assets[kATAdAssetsCustomEventKey];
    }
    if (customEvent) {
        // HJC: 设置 adView 和 customEvent
        if ([customEvent respondsToSelector:@selector(setAdView:)]) {
            [customEvent setValue:self.ADView forKey:@"adView"];
        }
        self.ADView.customEvent = customEvent;
    }
    
    // HJC: 检查是否为模板广告（优先从 offer.assets 获取，如果没有则从 offer.customNetworkNativeAd 判断）
    BOOL isExpress = NO;
    if (offer.assets[kATNativeADAssetsIsExpressAdKey]) {
        isExpress = [offer.assets[kATNativeADAssetsIsExpressAdKey] boolValue];
    } else if (offer.customNetworkNativeAd) {
        isExpress = offer.customNetworkNativeAd.isExpressAd;
    }
    
    if (isExpress) {
        // HJC: 模板广告处理
        // HJC: 优先从 offer.assets 获取，如果没有则从 offer.customNetworkNativeAd.templateView 获取
        AMPSNativeExpressView *expressView = nil;
        if (offer.assets[@"amps_nativeexpress_manager"]) {
            AMPSNativeExpressManager *nativeExpressManager = (AMPSNativeExpressManager *)offer.assets[@"amps_nativeexpress_manager"];
            if (nativeExpressManager && nativeExpressManager.viewsArray.count > 0) {
                expressView = nativeExpressManager.viewsArray.firstObject;
            }
        } else if (offer.customNetworkNativeAd && [offer.customNetworkNativeAd isKindOfClass:[ATAMPSCustomNativeObject class]]) {
            // HJC: 优先使用 ATAMPSCustomNativeObject
            ATAMPSCustomNativeObject *customNativeObject = (ATAMPSCustomNativeObject *)offer.customNetworkNativeAd;
            if (customNativeObject.nativeExpressView) {
                expressView = customNativeObject.nativeExpressView;
            } else if (customNativeObject.templateView && [customNativeObject.templateView isKindOfClass:[AMPSNativeExpressView class]]) {
                expressView = (AMPSNativeExpressView *)customNativeObject.templateView;
            }
        } else if (offer.customNetworkNativeAd && [offer.customNetworkNativeAd isKindOfClass:[ATCustomNetworkNativeAd class]]) {
            ATCustomNetworkNativeAd *customNativeAd = (ATCustomNetworkNativeAd *)offer.customNetworkNativeAd;
            if (customNativeAd.templateView && [customNativeAd.templateView isKindOfClass:[AMPSNativeExpressView class]]) {
                expressView = (AMPSNativeExpressView *)customNativeAd.templateView;
            }
        }
        
        if (expressView) {
            if ([expressView respondsToSelector:@selector(setDelegate:)]) {
                expressView.delegate = customEvent;
            }
            if ([expressView respondsToSelector:@selector(setViewController:)]) {
                expressView.viewController = self.configuration.rootViewController;
            }
            UIView *nativeFeed = (UIView *)expressView;
            [self.ADView addSubview:nativeFeed];
            nativeFeed.center = CGPointMake(CGRectGetMidX(self.ADView.bounds), CGRectGetMidY(self.ADView.bounds));
        }
    } else {
        // HJC: 自渲染广告处理
        // HJC: 优先从 offer.assets 获取，如果没有则从 offer.customNetworkNativeAd.mediaView 获取
        AMPSUnifiedNativeView *nativeView = nil;
        if (offer.assets[kATAdAssetsCustomObjectKey]) {
            nativeView = offer.assets[kATAdAssetsCustomObjectKey];
        } else if (offer.customNetworkNativeAd && [offer.customNetworkNativeAd isKindOfClass:[ATAMPSCustomNativeObject class]]) {
            // HJC: 优先使用 ATAMPSCustomNativeObject
            ATAMPSCustomNativeObject *customNativeObject = (ATAMPSCustomNativeObject *)offer.customNetworkNativeAd;
            if (customNativeObject.unifiedNativeView) {
                nativeView = customNativeObject.unifiedNativeView;
            } else if (customNativeObject.mediaView && [customNativeObject.mediaView isKindOfClass:[AMPSUnifiedNativeView class]]) {
                nativeView = (AMPSUnifiedNativeView *)customNativeObject.mediaView;
            }
        } else if (offer.customNetworkNativeAd && [offer.customNetworkNativeAd isKindOfClass:[ATCustomNetworkNativeAd class]]) {
            ATCustomNetworkNativeAd *customNativeAd = (ATCustomNetworkNativeAd *)offer.customNetworkNativeAd;
            if (customNativeAd.mediaView && [customNativeAd.mediaView isKindOfClass:[AMPSUnifiedNativeView class]]) {
                nativeView = (AMPSUnifiedNativeView *)customNativeAd.mediaView;
            }
        }
        
        if (nativeView) {
            self.unifiedNativeView = nativeView;
            if ([nativeView respondsToSelector:@selector(setDelegate:)]) {
                nativeView.delegate = customEvent;
            }
            if ([nativeView respondsToSelector:@selector(setViewController:)]) {
                nativeView.viewController = self.configuration.rootViewController;
            }
            nativeView.frame = self.ADView.bounds;
            [self.ADView addSubview:nativeView];
            [self.ADView sendSubviewToBack:nativeView];
            // HJC: 注意：点击事件的注册应该由 SDK 在适当的时机调用 NativeObject 的 registerClickableViews:withContainer:registerArgument: 方法
            // HJC: 这里不再直接调用第三方 SDK 的 registerClickableViews 方法，避免重复注册
        }
    }
}

@end

