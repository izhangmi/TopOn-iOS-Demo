//
//  AMPSInterstitialAd.h
//  AMPSAdSDK
//
//  Created by Cookie on 2024/11/25.
//

#import <UIKit/UIKit.h>
#import <AMPSAdSDK/AMPSInterfaceBaseObject.h>
#import <AMPSAdSDK/AMPSBiddingProtocol.h>
#import <AMPSAdSDK/AMPSAdConfiguration.h>
#import <AMPSAdSDK/AMPSInterstitialAdDelegate.h>

NS_ASSUME_NONNULL_BEGIN

@interface AMPSInterstitialAd : AMPSInterfaceBaseObject <AMPSBiddingProtocol>

/**
 广告配置对象
 */
@property (nonatomic, strong, readonly) AMPSAdConfiguration *adConfiguration;

/**
 Ad delegate
 */
@property (nonatomic, weak, nullable) id<AMPSInterstitialAdDelegate> delegate;

/**
 初始化广告
 @param adConfiguration 广告配置
 */
- (instancetype)initWithAdConfiguration:(AMPSAdConfiguration *)adConfiguration;

/**
 拉取广告
 */
- (void)loadInterstitialAd;

/**
 显示渲染成功的广告
 @param viewController 控制器用于弹出广告
 */
- (void)showInterstitialAdWithRootViewController:(UIViewController *)viewController;

/**
 销毁插屏
 */
- (void)removeInterstitialAd;

@end

NS_ASSUME_NONNULL_END
