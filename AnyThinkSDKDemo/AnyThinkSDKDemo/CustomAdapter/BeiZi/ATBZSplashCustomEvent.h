//
//  ATBZSplashCustomEvent.h
//  AnyThinkSDKDemo
//
//  Created by nie adhub on 2023/10/23.
//  Copyright © 2023 抽筋的灯. All rights reserved.
//

#import <AnyThinkSplash/AnyThinkSplash.h>
#import <BeiZiSDK/BeiZiSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATBZSplashCustomEvent : ATSplashCustomEvent <BeiZiSplashDelegate>

@property (nonatomic, strong) NSDate *expireDate;

@property (nonatomic, weak) UIView *containerView;

@property (nonatomic, strong) NSString *spaceId;

@end

NS_ASSUME_NONNULL_END
