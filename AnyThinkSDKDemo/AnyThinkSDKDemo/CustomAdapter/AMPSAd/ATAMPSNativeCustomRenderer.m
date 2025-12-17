//
//  ATAMPSNativeCustomRenderer.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import "ATAMPSNativeCustomRenderer.h"
#import <AMPSAdSDK/AMPSAdSDK.h>

// HJC: AMPSAd Native 广告自定义渲染器实现
@interface ATAMPSNativeCustomRenderer ()

@property (nonatomic, strong) AMPSUnifiedNativeView *unifiedNativeView;

@end

@implementation ATAMPSNativeCustomRenderer

// HJC: 渲染广告 Offer
- (void)renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    
    // HJC: 获取 customEvent，可能是 ATAMPSNativeExpressCustomEvent 或 ATAMPSUnifiedNativeCustomEvent
    id customEvent = offer.assets[kATAdAssetsCustomEventKey];
    if (customEvent) {
        // HJC: 设置 adView 和 customEvent
        if ([customEvent respondsToSelector:@selector(setAdView:)]) {
            [customEvent setValue:self.ADView forKey:@"adView"];
        }
        self.ADView.customEvent = customEvent;
    }
    
    BOOL isExpress = [offer.assets[kATNativeADAssetsIsExpressAdKey] boolValue];
    
    if (isExpress) {
        // HJC: 模板广告处理
        AMPSNativeExpressManager *nativeExpressManager = (AMPSNativeExpressManager *)offer.assets[@"amps_nativeexpress_manager"];
        if (nativeExpressManager && nativeExpressManager.viewsArray.count > 0) {
            AMPSNativeExpressView *expressView = nativeExpressManager.viewsArray.firstObject;
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
        self.unifiedNativeView = offer.assets[kATAdAssetsCustomObjectKey];
        if (self.unifiedNativeView) {
            if ([self.unifiedNativeView respondsToSelector:@selector(setDelegate:)]) {
                self.unifiedNativeView.delegate = customEvent;
            }
            if ([self.unifiedNativeView respondsToSelector:@selector(setViewController:)]) {
                self.unifiedNativeView.viewController = self.configuration.rootViewController;
            }
            self.unifiedNativeView.frame = self.ADView.bounds;
            [self.ADView addSubview:self.unifiedNativeView];
            [self.ADView sendSubviewToBack:self.unifiedNativeView];
            // HJC: 注册点击事件
            if ([self.unifiedNativeView respondsToSelector:@selector(registerClickableViews:)]) {
                [self.unifiedNativeView registerClickableViews:self.ADView.clickableViews];
            }
        }
    }
}

@end

