//
//  ATAMPSCustomInterstitialAdapter.h
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//
// HJC: 按照文档实现插屏广告适配器头文件

#import <Foundation/Foundation.h>
#import "../Base/ATAMPSCustomAdapterCommonHeader.h"
#import "../Base/ATAMPSCustomBaseAdapter.h"

NS_ASSUME_NONNULL_BEGIN

// HJC: ATAMPS 插屏广告适配器
// HJC: 继承 ATAMPSCustomBaseAdapter 并遵循 ATBaseInterstitialAdapterProtocol 协议
@interface ATAMPSCustomInterstitialAdapter : ATAMPSCustomBaseAdapter <ATBaseInterstitialAdapterProtocol>

@end

NS_ASSUME_NONNULL_END

