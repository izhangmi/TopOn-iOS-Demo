//
//  ATAMPSCustomNativeObject.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import "ATAMPSCustomNativeObject.h"

@implementation ATAMPSCustomNativeObject

#pragma mark - Required Methods
- (void)registerClickableViews:(NSArray<UIView *> *)clickableViews 
                  withContainer:(UIView *)container 
             registerArgument:(ATNativeRegisterArgument *)registerArgument {
    
    if (self.nativeAdRenderType == ATNativeAdRenderExpress) {
        if (self.nativeExpressView) {
            if ([self.nativeExpressView respondsToSelector:@selector(setViewController:)]) {
                self.nativeExpressView.viewController = registerArgument.viewController;
            }
        }
        return;
    }
    
    if (self.unifiedNativeView) {
        if ([self.unifiedNativeView respondsToSelector:@selector(setViewController:)]) {
            self.unifiedNativeView.viewController = registerArgument.viewController;
        }
        
        if ([self.unifiedNativeView respondsToSelector:@selector(registerClickableViews:)]) {
            [self.unifiedNativeView registerClickableViews:clickableViews];
        }
    }
}

- (void)setNativeADConfiguration:(ATNativeAdRenderConfig *)configuration {
}

@end

