//
//  ATBZRewardedVideoCustomEvent.h
//  AnyThinkSDKDemo
//
//  Created by nie adhub on 2025/7/20.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import <AnyThinkRewardedVideo//AnyThinkRewardedVideo.h>
#import <BeiZiSDK/BeiZiSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATBZRewardedVideoCustomEvent : ATRewardedVideoCustomEvent <BeiZiRewardedVideoDelegate>

@property (nonatomic, strong) NSDate *expireDate;

@property (nonatomic, strong) NSString *spaceId;

@end

NS_ASSUME_NONNULL_END
