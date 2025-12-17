//
//  ATBZNativeRenderer.m
//  AnyThinkSDKDemo
//
//  Created by nie adhub on 2023/10/24.
//  Copyright © 2023 抽筋的灯. All rights reserved.
//

#import "ATBZNativeCustomRenderer.h"

@interface ATBZNativeCustomRenderer ()

@property (nonatomic, strong) BeiZiUnifiedNative *unifiedNative;
@end

@implementation ATBZNativeCustomRenderer

- (void)renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    _customEvent = offer.assets[kATAdAssetsCustomEventKey];
    _customEvent.adView = self.ADView;
    self.ADView.customEvent = _customEvent;
    BOOL isExpress = [offer.assets[kATNativeADAssetsIsExpressAdKey] boolValue];
    if (isExpress) {
        BeiZiNativeExpress *nativeExpressAd = (BeiZiNativeExpress *)offer.assets[@"tt_nativeexpress_manager"];
        nativeExpressAd.delegate = _customEvent;
        UIView *nativeFeed = offer.assets[kATAdAssetsCustomObjectKey];
        nativeExpressAd.beiziNativeViewController = self.configuration.rootViewController;
        [self.ADView addSubview:(UIView*)nativeFeed];
        nativeFeed.center = CGPointMake(CGRectGetMidX(self.ADView.bounds), CGRectGetMidY(self.ADView.bounds));
    } else {
        self.unifiedNative = offer.assets[kATAdAssetsCustomObjectKey];
        self.unifiedNative.delegate = _customEvent;
        self.unifiedNative.materialViewSize = self.ADView.frame.size;
        self.unifiedNative.materialView.frame = CGRectMake(0, 0, self.ADView.frame.size.width, self.ADView.frame.size.height);
        [self.ADView addSubview:self.unifiedNative.materialView];
        [self.ADView sendSubviewToBack:self.unifiedNative.materialView];
        [self.unifiedNative registerContainer:self.ADView clickableViews:self.ADView.clickableViews];
    }
}

@end
