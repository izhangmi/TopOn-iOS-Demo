//
//  AMPSSplashAdDelegate.h
//  AMPSAdSDK
//
//  Created by Cookie on 2024/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AMPSSplashAd;

@protocol AMPSSplashAdDelegate <NSObject>

@optional
/**
 开屏广告请求成功
 */
- (void)ampsSplashAdLoadSuccess:(AMPSSplashAd *)splashAd;

/**
 开屏请求失败
 */
- (void)ampsSplashAdLoadFail:(AMPSSplashAd *)splashAd
                       error:(NSError *_Nullable)error;

/**
 开屏广告渲染成功
 */
- (void)ampsSplashAdRenderSuccess:(AMPSSplashAd *)splashAd;

/**
 开屏渲染失败
 */
- (void)ampsSplashAdRenderFail:(AMPSSplashAd *)splashAd
                         error:(NSError *_Nullable)error;

/**
 开屏广告显示失败
 */
- (void)ampsSplashAdShowFail:(AMPSSplashAd *)splashAd
                       error:(NSError *_Nullable)error;

/**
 开屏广告显示
 */
- (void)ampsSplashAdDidShow:(AMPSSplashAd *)splashAd;

/**
 开屏广告曝光
 */
- (void)ampsSplashAdExposured:(AMPSSplashAd *)splashAd;

/**
 开屏广告点击
 */
- (void)ampsSplashAdDidClick:(AMPSSplashAd *)splashAd;

/**
 开屏广告关闭
 */
- (void)ampsSplashAdDidClose:(AMPSSplashAd *)splashAd;


@end

NS_ASSUME_NONNULL_END
