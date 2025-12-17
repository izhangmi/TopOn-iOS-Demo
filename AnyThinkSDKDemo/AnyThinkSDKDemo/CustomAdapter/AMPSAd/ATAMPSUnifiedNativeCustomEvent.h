//
//  ATAMPSUnifiedNativeCustomEvent.h
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import <AnyThinkNative/AnyThinkNative.h>
#import <AMPSAdSDK/AMPSAdSDK.h>

NS_ASSUME_NONNULL_BEGIN

// HJC: AMPSAd Native 自渲染广告自定义事件处理类
@interface ATAMPSUnifiedNativeCustomEvent : ATNativeADCustomEvent <AMPSUnifiedNativeManagerDelegate, AMPSUnifiedNativeViewDelegate>

@property (nonatomic, strong) NSString *spaceId;

@end

NS_ASSUME_NONNULL_END

