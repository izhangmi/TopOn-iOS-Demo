//
//  ATBZNativeADCustomEvent.h
//  AnyThinkSDKDemo
//
//  Created by nie adhub on 2023/10/24.
//  Copyright © 2023 抽筋的灯. All rights reserved.
//

#import <AnyThinkNative/AnyThinkNative.h>
#import <BeiZiSDK/BeiZiSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATBZNativeADCustomEvent : ATNativeADCustomEvent <BeiZiNativeExpressDelegate,BeiZiUnifiedNativeDelegate>

@property (nonatomic, strong) NSString *spaceId;

@end

NS_ASSUME_NONNULL_END
