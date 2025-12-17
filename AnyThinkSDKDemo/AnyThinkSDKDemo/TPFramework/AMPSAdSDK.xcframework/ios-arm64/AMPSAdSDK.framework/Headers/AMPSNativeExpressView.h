//
//  AMPSNativeExpressView.h
//  AMPSAdSDK
//
//  Created by Cookie on 2024/11/25.
//

#import <AMPSAdSDK/AMPSInterfaceBaseView.h>
#import <AMPSAdSDK/AMPSBiddingProtocol.h>
#import <AMPSAdSDK/AMPSAdConfiguration.h>
#import <AMPSAdSDK/AMPSNativeExpressViewDelegate.h>

NS_ASSUME_NONNULL_BEGIN

@interface AMPSNativeExpressView : AMPSInterfaceBaseView <AMPSBiddingProtocol>

/**
 视图 delegate
 */
@property (nonatomic, weak, nullable) id<AMPSNativeExpressViewDelegate> delegate;

/**
 Nonnull, must
 广告落地页所需，必传，不能为空
 */
@property (nonatomic, weak) UIViewController *viewController;

/**
 required，渲染广告
 */
- (void)renderAd;

/**
 是否可以用于显示
 */
- (BOOL)isReadyAd;

/**
 销毁原生广告视图
 */
- (void)removeNativeAd;

/**
 更新布局(仅ADN请求时支持)
 */
- (void)resetLayoutWithSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
