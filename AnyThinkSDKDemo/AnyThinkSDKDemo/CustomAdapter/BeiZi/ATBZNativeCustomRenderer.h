//
//  ATBZNativeRenderer.h
//  AnyThinkSDKDemo
//
//  Created by nie adhub on 2023/10/24.
//  Copyright © 2023 抽筋的灯. All rights reserved.
//

#import <AnyThinkNative/AnyThinkNative.h>
#import "ATBZNativeADCustomEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATBZNativeCustomRenderer : ATNativeRenderer

@property(nonatomic, readonly) ATBZNativeADCustomEvent *customEvent;

@end

NS_ASSUME_NONNULL_END
