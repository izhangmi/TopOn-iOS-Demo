//
//  ATAMPSCustomNativeAdapter.h
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//
// HJC: Native 广告适配器头文件

#import <Foundation/Foundation.h>
#import "../Base/ATAMPSCustomAdapterCommonHeader.h"
#import "../Base/ATAMPSCustomBaseAdapter.h"

NS_ASSUME_NONNULL_BEGIN

// HJC: ATAMPS Native 广告适配器
// HJC: 继承 ATAMPSCustomBaseAdapter 并遵循 ATBaseNativeAdapterProtocol 协议
@interface ATAMPSCustomNativeAdapter : ATAMPSCustomBaseAdapter <ATBaseNativeAdapterProtocol>

@end

NS_ASSUME_NONNULL_END

