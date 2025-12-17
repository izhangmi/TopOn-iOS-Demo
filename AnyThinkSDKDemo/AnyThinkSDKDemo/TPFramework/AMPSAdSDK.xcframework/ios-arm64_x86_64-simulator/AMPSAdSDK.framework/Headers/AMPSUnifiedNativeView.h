//
//  AMPSUnifiedNativeView.h
//  AMPSAdSDK
//
//  Created by Cookie on 2025/1/14.
//

#import <AMPSAdSDK/AMPSInterfaceBaseView.h>
#import <AMPSAdSDK/AMPSBiddingProtocol.h>
#import <AMPSAdSDK/AMPSUnifiedNativeViewDelegate.h>

@class AMPSAdConfiguration;
@class AMPSUnifiedNativeAd;
@class AMPSMediaView;

NS_ASSUME_NONNULL_BEGIN

@interface AMPSUnifiedNativeView : AMPSInterfaceBaseView <AMPSBiddingProtocol>

/**
 视频广告的媒体View，绑定数据对象后自动生成，可自定义布局
 */
@property (nonatomic, strong) AMPSMediaView *mediaView;

/**
 广告数据模型
 */
@property (nonatomic, strong, readonly) AMPSUnifiedNativeAd *nativeAd;
 
/**
 广告委托对象
 */
@property (nonatomic, weak, nullable) id<AMPSUnifiedNativeViewDelegate> delegate;

/**
 Nonnull, 广告点击时依赖的ViewController
 */
@property (nonatomic, weak) UIViewController *viewController;

/**
 刷新广告数据
 */
- (void)refreshData:(AMPSUnifiedNativeAd *)nativeAd;

#pragma mark custom native
/**
 注册点击事件
 */
- (void)registerClickableViews:(NSArray<UIView *> *)clickableViews;

/**
 解绑广告数据源
 */
- (void)unregisterNativeAdDataObject;

@end

NS_ASSUME_NONNULL_END
