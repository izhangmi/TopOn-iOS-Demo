//
//  AMPSNativeExpressViewDelegate.h
//  AMPSAdSDK
//
//  Created by Cookie on 2024/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AMPSNativeExpressView;

@protocol AMPSNativeExpressViewDelegate <NSObject>

@optional
/**
 原生广告视图渲染成功
 */
- (void)ampsNativeAdRenderSuccess:(AMPSNativeExpressView *)nativeView;

/**
 原生广告视图渲染失败
 */
- (void)ampsNativeAdRenderFail:(AMPSNativeExpressView *)nativeView
                         error:(NSError *_Nullable)error;

/**
 原生广告视图曝光
 */
- (void)ampsNativeAdExposured:(AMPSNativeExpressView *)nativeView;

/**
 原生广告视图点击
 */
- (void)ampsNativeAdDidClick:(AMPSNativeExpressView *)nativeView;

/**
 原生广告视图关闭
 */
- (void)ampsNativeAdDidClose:(AMPSNativeExpressView *)nativeView;

@end

NS_ASSUME_NONNULL_END
