//
//  ATAMPSSplashCustomEvent.h
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import <AnyThinkSplash/AnyThinkSplash.h>
#import <AMPSAdSDK/AMPSAdSDK.h>

NS_ASSUME_NONNULL_BEGIN

// HJC: AMPSAd Splash 广告自定义事件处理类
@interface ATAMPSSplashCustomEvent : ATSplashCustomEvent <AMPSSplashAdDelegate>

@property (nonatomic, strong) NSDate *expireDate;

@property (nonatomic, weak) UIView *containerView;

@property (nonatomic, strong) NSString *spaceId;

@end

NS_ASSUME_NONNULL_END

