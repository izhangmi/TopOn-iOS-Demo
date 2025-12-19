//
//  ATAMPSCustomSplashDelegate.h
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//
// HJC: 按照文档 https://help.takuad.com/docs/UpnVkNF1 实现
// HJC: 开屏广告代理头文件

#import <AnyThinkSDK/AnyThinkSDK.h>
#import <AMPSAdSDK/AMPSAdSDK.h>

NS_ASSUME_NONNULL_BEGIN

// HJC: ATAMPS 开屏广告代理，遵循 AMPSSplashAdDelegate 协议
// HJC: 按照文档 4.1 实现
@interface ATAMPSCustomSplashDelegate : NSObject <AMPSSplashAdDelegate>

// HJC: 必须属性：用于向 SDK 上报广告事件（文档 4.1）
@property (nonatomic, strong) ATSplashAdStatusBridge *adStatusBridge;

// HJC: 服务器配置信息
@property (nonatomic, strong) NSDictionary *serverInfo;
// HJC: 本地配置信息
@property (nonatomic, strong) NSDictionary *localInfo;
// HJC: 过期时间
@property (nonatomic, strong) NSDate *expireDate;
// HJC: 底部容器视图
@property (nonatomic, weak) UIView *containerView;
// HJC: 广告位ID（用于竞价）
@property (nonatomic, strong) NSString *spaceId;
// HJC: 是否为 C2S 竞价（用于区分普通加载和竞价加载）
@property (nonatomic, assign) BOOL isC2SBiding;

// HJC: 初始化方法
- (instancetype)initWithInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo;

@end

NS_ASSUME_NONNULL_END

