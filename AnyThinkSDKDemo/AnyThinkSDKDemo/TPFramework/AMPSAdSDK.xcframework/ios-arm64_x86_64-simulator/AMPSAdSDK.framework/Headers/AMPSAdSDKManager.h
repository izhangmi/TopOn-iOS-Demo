//
//  AMPSAdSDKManager.h
//  AMPSAdSDK
//
//  Created by Cookie on 2024/11/25.
//

#import <Foundation/Foundation.h>
#import <AMPSAdSDK/AMPSAdSDKDefines.h>

@class AMPSAdSDKConfiguration;

NS_ASSUME_NONNULL_BEGIN

typedef void (^AMPSAdSDKInitStatusResults)(AMPSAdSDKInitStatus statusResult);

@interface AMPSAdSDKManager : NSObject

/**
 实例初始化
 */
+ (instancetype)sharedInstance;

/**
 异步初始化广告
 @param configuration 自定义设置
 @param appId media unique ID
 */
- (void)startAsyncWithAppId:(NSString *)appId
              configuration:(AMPSAdSDKConfiguration *_Nullable)configuration
                    results:(AMPSAdSDKInitStatusResults)statusResult;

/**
 SDK初始化状态
 */
- (AMPSAdSDKInitStatus)sdkInitializationStatus;

/**
 修改个性化广告开关，初始化后修改使用此方法，如果初始化前可修改 AMPSAdSDKConfiguration 对象的 recommend 属性
 @param state 开启/关闭个性化推荐
 */
- (void)setPersonalizedRecommendState:(AMPSPersonalizedRecommendState)state;

/**
 @param customData 特殊配置信息
 */
- (void)setAnyExtCustomData:(NSDictionary <NSString *, NSString *> *)customData;

/**
 @return SDK version
 */
+ (NSString *)sdkVersion;

@end

NS_ASSUME_NONNULL_END
