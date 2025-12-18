//
//  ATAMPSInterstitialCustomEvent.h
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import <AnyThinkInterstitial/AnyThinkInterstitial.h>
#import <AMPSAdSDK/AMPSAdSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATAMPSInterstitialCustomEvent : ATInterstitialCustomEvent <AMPSInterstitialAdDelegate>

@property (nonatomic, strong) NSDate *expireDate;

@property (nonatomic, strong) NSString *spaceId;

@end

NS_ASSUME_NONNULL_END

