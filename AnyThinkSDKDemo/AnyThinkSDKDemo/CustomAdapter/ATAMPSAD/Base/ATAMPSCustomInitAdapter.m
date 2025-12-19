//
//  ATAMPSCustomInitAdapter.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import "ATAMPSCustomInitAdapter.h"

@implementation ATAMPSCustomInitAdapter

- (void)initWithInitArgument:(ATAdInitArgument *)adInitArgument {
    NSLog(@"═══════════════════════════════════════════════════════════");
    NSLog(@"HJC测试: ATAMPSCustomInitAdapter initWithInitArgument 被调用！");
    NSLog(@"═══════════════════════════════════════════════════════════");
    
    NSDictionary *serverInfo = adInitArgument.serverContentDic;
    NSLog(@"HJC测试: 服务器配置信息 serverInfo = %@", serverInfo);
    
    NSString *appId = serverInfo[@"appid"];
    NSLog(@"HJC测试: 从服务器配置获取的 appId = %@", appId);
    
    if (!appId || appId.length == 0) {
        NSLog(@"HJC测试: ⚠️ appId 为空，初始化失败");
        NSError *error = [NSError errorWithDomain:@"ATAMPSCustomInitAdapter" 
                                             code:-1 
                                         userInfo:@{NSLocalizedDescriptionKey: @"AMPSAd appid is missing or invalid"}];
        [self notificationNetworkInitFail:error];
        return;
    }
    
    AMPSAdSDKConfiguration *config = [[AMPSAdSDKConfiguration alloc] init];
    
    //获取个性化广告状态，2 表示非个性化，其他表示个性化
    if (adInitArgument.personalizedAdState == ATNonpersonalizedAdStateType) {
        config.recommend = kAMPSPersonalizedRecommendStateClose;
    } else {
        config.recommend = kAMPSPersonalizedRecommendStateOpen;
    }
    
    NSLog(@"HJC测试: 开始异步初始化 AMPSAd SDK，appId = %@", appId);
    
    //异步初始化 AMPSAd SDK
    [[AMPSAdSDKManager sharedInstance] startAsyncWithAppId:appId 
                                              configuration:config 
                                                    results:^(AMPSAdSDKInitStatus statusResult) {
        NSLog(@"HJC测试: AMPSAd SDK 初始化回调，statusResult = %ld", (long)statusResult);
        
        //处理初始化结果
        if (statusResult == kAMPSAdSDKInitStatusSuccess) {
            NSLog(@"HJC测试: ✅ AMPSAd SDK 初始化成功！");
            //初始化成功，通知 SDK
            [self notificationNetworkInitSuccess];
        } else {
            NSLog(@"HJC测试: ❌ AMPSAd SDK 初始化失败，statusResult = %ld", (long)statusResult);
            //初始化失败，通知 SDK
            NSError *error = [NSError errorWithDomain:@"ATAMPSCustomInitAdapter" 
                                                 code:statusResult 
                                             userInfo:@{NSLocalizedDescriptionKey: @"AMPSAd SDK initialization failed"}];
            [self notificationNetworkInitFail:error];
        }
    }];
}

//返回广告平台 SDK 的版本号
+ (nullable NSString *)sdkVersion {
    return [AMPSAdSDKManager sdkVersion];
}

//返回适配器版本号
+ (nullable NSString *)adapterVersion {
    return @"1.0.0"; // HJC: 适配器版本号
}

@end

