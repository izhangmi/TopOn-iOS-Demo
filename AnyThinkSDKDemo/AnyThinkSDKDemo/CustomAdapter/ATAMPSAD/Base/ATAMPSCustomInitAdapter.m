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
    NSDictionary *serverInfo = adInitArgument.serverContentDic;
    NSString *appId = serverInfo[@"appid"];
    
    if (!appId || appId.length == 0) {
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
    
    [[AMPSAdSDKManager sharedInstance] startAsyncWithAppId:appId 
                                              configuration:config 
                                                    results:^(AMPSAdSDKInitStatus statusResult) {
        if (statusResult == kAMPSAdSDKInitStatusSuccess) {
            [self notificationNetworkInitSuccess];
        } else {
            NSError *error = [NSError errorWithDomain:@"ATAMPSCustomInitAdapter" 
                                                 code:statusResult 
                                             userInfo:@{NSLocalizedDescriptionKey: @"AMPSAd SDK initialization failed"}];
            [self notificationNetworkInitFail:error];
        }
    }];
}

+ (nullable NSString *)sdkVersion {
    return [AMPSAdSDKManager sdkVersion];
}

+ (nullable NSString *)adapterVersion {
    return @"1.0.0";
}

@end

