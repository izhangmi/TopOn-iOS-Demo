//
//  AMPSUnifiedNativeViewDelegate.h
//  AMPSAdSDK
//
//  Created by Cookie on 2025/1/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AMPSUnifiedNativeView;

@protocol AMPSUnifiedNativeViewDelegate <NSObject>

@optional

/**
 原生广告视图渲染成功
 */
- (void)ampsNativeAdRenderSuccess:(AMPSUnifiedNativeView *)nativeView;

/**
 原生广告视图渲染失败
 */
- (void)ampsNativeAdRenderFail:(AMPSUnifiedNativeView *)nativeView
                         error:(NSError *_Nullable)error;

/**
 原生广告视图曝光
 */
- (void)ampsNativeAdExposured:(AMPSUnifiedNativeView *)nativeView;

/**
 原生广告视图点击
 */
- (void)ampsNativeAdDidClick:(AMPSUnifiedNativeView *)nativeView;

/**
 原生广告视图关闭
 */
- (void)ampsNativeAdDidClose:(AMPSUnifiedNativeView *)nativeView;

@end

NS_ASSUME_NONNULL_END
