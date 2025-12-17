//
//  AMPSUnifiedNativeManagerDelegate.h
//  AMPSAdSDK
//
//  Created by Cookie on 2025/1/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AMPSUnifiedNativeManager;
@class AMPSUnifiedNativeView;

@protocol AMPSUnifiedNativeManagerDelegate <NSObject>

@optional
/**
 自渲染原生广告请求成功
 */
- (void)ampsNativeAdLoadSuccess:(AMPSUnifiedNativeManager *)nativeManager;

/**
 自渲染原生广告请求失败
 */
- (void)ampsNativeAdLoadFail:(AMPSUnifiedNativeManager *)nativeManager
                       error:(NSError *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
