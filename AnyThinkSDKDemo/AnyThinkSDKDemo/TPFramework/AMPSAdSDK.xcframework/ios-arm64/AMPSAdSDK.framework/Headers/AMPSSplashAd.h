//
//  AMPSSplashAd.h
//  AMPSAdSDK
//
//  Created by Cookie on 2024/11/25.
//

#import <UIKit/UIKit.h>
#import <AMPSAdSDK/AMPSInterfaceBaseObject.h>
#import <AMPSAdSDK/AMPSBiddingProtocol.h>
#import <AMPSAdSDK/AMPSSplashAdDelegate.h>

@class AMPSAdConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface AMPSSplashAd : AMPSInterfaceBaseObject <AMPSBiddingProtocol>

/**
 广告配置对象
 */
@property (nonatomic, strong, readonly) AMPSAdConfiguration *adConfiguration;

/**
 ADN delegate
 */
@property (nonatomic, weak, nullable) id<AMPSSplashAdDelegate> delegate;

/**
 初始化广告
 @param adConfiguration 广告配置
 */
- (instancetype)initWithAdConfiguration:(AMPSAdConfiguration *)adConfiguration;

/**
 拉取广告
 */
- (void)loadSplashAd;

/**
 显示广告
 @param window 显示广告使用，window上必须存在viewController用于跳转广告
 */
- (void)showSplashViewInWindow:(UIWindow *)window;

/**
 显示广告
 @param window 显示广告使用，window上必须存在viewController用于跳转广告
 @param bottomView 底部LogoView
 */
- (void)showSplashViewInWindow:(UIWindow *)window bottomView:(UIView *)bottomView;

/**
 移除广告
 */
- (void)removeSplashAd;

@end

NS_ASSUME_NONNULL_END
