//
//  AMPSInterstitialAdDelegate.h
//  AMPSAdSDK
//
//  Created by Cookie on 2024/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AMPSInterstitialAd;

@protocol AMPSInterstitialAdDelegate <NSObject>

@optional
/**
 插屏广告请求成功
 */
- (void)ampsInterstitialAdLoadSuccess:(AMPSInterstitialAd *)interstitialAd;

/**
 插屏广告请求失败
 */
- (void)ampsInterstitialAdLoadFail:(AMPSInterstitialAd *)interstitialAd
                             error:(NSError *_Nullable)error;

/**
 插屏广告渲染成功
 */
- (void)ampsInterstitialAdRenderSuccess:(AMPSInterstitialAd *)interstitialAd;

/**
 插屏广告渲染失败
 */
- (void)ampsInterstitialAdRenderFail:(AMPSInterstitialAd *)interstitialAd
                               error:(NSError *_Nullable)error;

/**
 插屏广告显示失败
 */
- (void)ampsInterstitialAdShowFail:(AMPSInterstitialAd *)interstitialAd
                             error:(NSError *_Nullable)error;

/**
 插屏广告曝光
 */
- (void)ampsInterstitialAdDidShow:(AMPSInterstitialAd *)interstitialAd;

/**
 插屏广告点击
 */
- (void)ampsInterstitialAdDidClick:(AMPSInterstitialAd *)interstitialAd;

/**
 插屏广告关闭
 */
- (void)ampsInterstitialAdDidClose:(AMPSInterstitialAd *)interstitialAd;

@end

NS_ASSUME_NONNULL_END
