//
//  AMPSNativeExpressManagerDelegate.h
//  AMPSAdSDK
//
//  Created by Cookie on 2024/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AMPSNativeExpressManager;

@protocol AMPSNativeExpressManagerDelegate <NSObject>

@optional
/**
 原生广告请求成功
 */
- (void)ampsNativeAdLoadSuccess:(AMPSNativeExpressManager *)nativeAd;

/**
 原生广告请求失败
 */
- (void)ampsNativeAdLoadFail:(AMPSNativeExpressManager *)nativeAd
                       error:(NSError *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
