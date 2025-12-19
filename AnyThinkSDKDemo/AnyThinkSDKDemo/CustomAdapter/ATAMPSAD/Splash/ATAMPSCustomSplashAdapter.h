//
//  ATAMPSCustomSplashAdapter.h
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//
// HJC: 按照文档 https://help.takuad.com/docs/UpnVkNF1 实现
// HJC: 开屏广告适配器头文件

#import <Foundation/Foundation.h>
#import "../Base/ATAMPSCustomAdapterCommonHeader.h"
#import "../Base/ATAMPSCustomBaseAdapter.h"
NS_ASSUME_NONNULL_BEGIN

// HJC: ATAMPS 开屏广告适配器
// HJC: 按照文档 4.3，继承 ATAMPSCustomBaseAdapter 并遵循 ATBaseSplashAdapterProtocol 协议
@interface ATAMPSCustomSplashAdapter : ATAMPSCustomBaseAdapter <ATBaseSplashAdapterProtocol>

@end

NS_ASSUME_NONNULL_END

