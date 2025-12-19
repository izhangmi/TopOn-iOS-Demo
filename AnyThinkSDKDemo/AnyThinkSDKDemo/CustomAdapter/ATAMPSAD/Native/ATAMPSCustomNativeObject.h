//
//  ATAMPSCustomNativeObject.h
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//
// HJC: 按照文档 https://help.takuad.com/docs/HSVTKS6M 实现
// HJC: 原生广告对象头文件

#import <AnyThinkSDK/AnyThinkSDK.h>
#import <Foundation/Foundation.h>
#import <AMPSAdSDK/AMPSAdSDK.h>
#import "../Base/ATAMPSCustomAdapterCommonHeader.h"

NS_ASSUME_NONNULL_BEGIN

// HJC: ATAMPS 原生广告对象
// HJC: 按照文档 4.1，继承 ATCustomNetworkNativeAd 基类
@interface ATAMPSCustomNativeObject : ATCustomNetworkNativeAd

// HJC: 第三方 SDK 的原生模板广告视图（用于模板渲染）
@property (nonatomic, strong, nullable) AMPSNativeExpressView *nativeExpressView;

// HJC: 第三方 SDK 的原生自渲染广告视图（用于自渲染）
@property (nonatomic, strong, nullable) AMPSUnifiedNativeView *unifiedNativeView;

// HJC: 第三方 SDK 的原生模板广告管理器（用于模板渲染）
@property (nonatomic, strong, nullable) AMPSNativeExpressManager *nativeExpressManager;

// HJC: 第三方 SDK 的原生自渲染广告管理器（用于自渲染）
@property (nonatomic, strong, nullable) AMPSUnifiedNativeManager *unifiedNativeManager;

@end

NS_ASSUME_NONNULL_END

