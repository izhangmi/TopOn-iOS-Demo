//
//  ATAMPSCustomNativeObject.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//
// HJC: 按照文档 https://help.takuad.com/docs/HSVTKS6M 实现
// HJC: 原生广告对象实现文件

#import "ATAMPSCustomNativeObject.h"

// HJC: ATAMPS 原生广告对象实现
// HJC: 按照文档 4.2 实现
@implementation ATAMPSCustomNativeObject

#pragma mark - Required Methods
// HJC: 按照文档 2，实现广告注册容器方法
// HJC: 开发者调用广告注册 API 时，会调用到自定义原生广告对象的 registerClickableViews:withContainer:registerArgument: 方法
- (void)registerClickableViews:(NSArray<UIView *> *)clickableViews 
                  withContainer:(UIView *)container 
             registerArgument:(ATNativeRegisterArgument *)registerArgument {
    
    // HJC: 按照文档 4.2，处理自渲染和模板渲染两种模式
    if (self.nativeAdRenderType == ATNativeAdRenderExpress) {
        // HJC: 模板广告处理
        // HJC: 模板广告通常不需要单独注册点击事件，因为模板广告视图已经包含了所有点击逻辑
        if (self.nativeExpressView) {
            // HJC: 设置 viewController 用于跳转
            if ([self.nativeExpressView respondsToSelector:@selector(setViewController:)]) {
                self.nativeExpressView.viewController = registerArgument.viewController;
            }
            // HJC: 设置 delegate（如果需要）
            if ([self.nativeExpressView respondsToSelector:@selector(setDelegate:)]) {
                // HJC: delegate 应该在创建时已经设置，这里不需要重复设置
            }
        }
        return;
    }
    
    // HJC: 自渲染广告处理
    // HJC: 在这里处理第三方 SDK 所需要的自渲染广告参数，通常是注册事件
    if (self.unifiedNativeView) {
        // HJC: 设置 viewController 用于跳转
        if ([self.unifiedNativeView respondsToSelector:@selector(setViewController:)]) {
            self.unifiedNativeView.viewController = registerArgument.viewController;
        }
        
        // HJC: 注册点击事件
        // HJC: AMPSUnifiedNativeView 使用 registerClickableViews: 方法注册可点击视图
        if ([self.unifiedNativeView respondsToSelector:@selector(registerClickableViews:)]) {
            [self.unifiedNativeView registerClickableViews:clickableViews];
            NSLog(@"HJC测试: ✅ 已为自渲染广告注册点击事件，clickableViews count = %lu", (unsigned long)clickableViews.count);
        }
    }
}

// HJC: 按照文档 2，实现配置设置方法
// HJC: 开发者调用广告配置 API 时，会调用到自定义原生广告对象的 setNativeADConfiguration: 方法
- (void)setNativeADConfiguration:(ATNativeAdRenderConfig *)configuration {
    // HJC: configuration 对象是外界传入的配置对象，这里拿到后可以用于设置第三方 SDK 的相关配置
    // HJC: 对于 AMPSAd SDK，配置主要在创建广告对象时通过 AMPSAdConfiguration 设置
    // HJC: 这里如果需要额外的配置，可以在这里处理
    
    NSLog(@"HJC测试: setNativeADConfiguration 被调用，configuration = %@", configuration);
}

@end

