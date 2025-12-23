//
//  ATAMPSCustomNativeRenderer.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import "ATAMPSCustomNativeRenderer.h"
#import "ATAMPSCustomNativeObject.h"
#import <AMPSAdSDK/AMPSAdSDK.h>

@interface ATAMPSCustomNativeRenderer ()

@property (nonatomic, strong) AMPSUnifiedNativeView *unifiedNativeView;

@end

@implementation ATAMPSCustomNativeRenderer

- (void)renderOffer:(ATAdOfferCacheModel *)offer {
    [super renderOffer:offer];
    
    id customEvent = offer.nativeCustomEvent;
    if (!customEvent) {
        customEvent = offer.assets[kATAdAssetsCustomEventKey];
    }
    if (customEvent) {
        if ([customEvent respondsToSelector:@selector(setAdView:)]) {
            [customEvent setValue:self.ADView forKey:@"adView"];
        }
        self.ADView.customEvent = customEvent;
    }
    
    BOOL isExpress = NO;
    if (offer.assets[kATNativeADAssetsIsExpressAdKey]) {
        isExpress = [offer.assets[kATNativeADAssetsIsExpressAdKey] boolValue];
    } else if (offer.customNetworkNativeAd) {
        isExpress = offer.customNetworkNativeAd.isExpressAd;
    }
    
    if (isExpress) {
        AMPSNativeExpressView *expressView = nil;
        if (offer.assets[@"amps_nativeexpress_manager"]) {
            AMPSNativeExpressManager *nativeExpressManager = (AMPSNativeExpressManager *)offer.assets[@"amps_nativeexpress_manager"];
            if (nativeExpressManager && nativeExpressManager.viewsArray.count > 0) {
                expressView = nativeExpressManager.viewsArray.firstObject;
            }
        } else if (offer.customNetworkNativeAd && [offer.customNetworkNativeAd isKindOfClass:[ATAMPSCustomNativeObject class]]) {
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
        AMPSUnifiedNativeView *nativeView = nil;
        if (offer.assets[kATAdAssetsCustomObjectKey]) {
            nativeView = offer.assets[kATAdAssetsCustomObjectKey];
        } else if (offer.customNetworkNativeAd && [offer.customNetworkNativeAd isKindOfClass:[ATAMPSCustomNativeObject class]]) {
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
        }
    }
}

@end

