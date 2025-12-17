//
//  ATBZInterstitialCustomEvent.h
//  AnyThinkSDKDemo
//
//  Created by nie adhub on 2024/4/17.
//  Copyright © 2024 抽筋的灯. All rights reserved.
//

#import <AnyThinkInterstitial/AnyThinkInterstitial.h>
#import <BeiZiSDK/BeiZiSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATBZInterstitialCustomEvent : ATInterstitialCustomEvent <BeiZiInterstitialDelegate>

@property (nonatomic, strong) NSDate *expireDate;

@property (nonatomic, strong) NSString *spaceId;

@end

NS_ASSUME_NONNULL_END
