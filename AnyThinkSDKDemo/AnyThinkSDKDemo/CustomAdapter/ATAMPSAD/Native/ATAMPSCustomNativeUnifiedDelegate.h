//
//  ATAMPSCustomNativeUnifiedDelegate.h
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//
// HJC: 按照文档 https://help.takuad.com/docs/HSVTKS6M 实现
// HJC: 原生自渲染广告代理头文件

#import <AnyThinkSDK/AnyThinkSDK.h>
#import <AMPSAdSDK/AMPSAdSDK.h>

NS_ASSUME_NONNULL_BEGIN

// HJC: ATAMPS 原生自渲染广告代理
// HJC: 遵循 AMPSUnifiedNativeManagerDelegate 和 AMPSUnifiedNativeViewDelegate 协议
@interface ATAMPSCustomNativeUnifiedDelegate : NSObject <AMPSUnifiedNativeManagerDelegate, AMPSUnifiedNativeViewDelegate>

// HJC: 必须属性：用于向 SDK 上报广告事件（文档 4.3）
@property (nonatomic, strong) ATNativeAdStatusBridge *adStatusBridge;

// HJC: 服务器配置信息
@property (nonatomic, strong) NSDictionary *serverInfo;
// HJC: 本地配置信息
@property (nonatomic, strong) NSDictionary *localInfo;
// HJC: 广告位ID（用于竞价）
@property (nonatomic, strong) NSString *spaceId;
// HJC: 是否为 C2S 竞价（用于区分普通加载和竞价加载）
@property (nonatomic, assign) BOOL isC2SBiding;
// HJC: 保存 unifiedNativeManager 引用（用于在创建 NativeObject 时传递）
@property (nonatomic, weak, nullable) AMPSUnifiedNativeManager *unifiedNativeManager;

// HJC: 初始化方法
- (instancetype)initWithInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo;

@end

NS_ASSUME_NONNULL_END
