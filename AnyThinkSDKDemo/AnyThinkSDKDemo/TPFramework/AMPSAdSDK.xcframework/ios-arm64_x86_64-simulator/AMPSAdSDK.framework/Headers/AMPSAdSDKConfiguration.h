//
//  AMPSAdSDKConfiguration.h
//  AMPSAdSDK
//
//  Created by Cookie on 2024/11/25.
//

#import <Foundation/Foundation.h>
#import <AMPSAdSDK/AMPSAdSDKDefines.h>

NS_ASSUME_NONNULL_BEGIN

@class AMPSAdSDKLocationProvider;

@interface AMPSAdSDKConfiguration : NSObject

/**
 个性化推荐开关，初始化前设置，（默认YES）
 */
@property (nonatomic, assign) AMPSPersonalizedRecommendState recommend;

/**
 是否为中国大陆
 */
@property (nonatomic, assign) BOOL county_CN;

/**
 商户密钥
 */
@property (nonatomic, copy) NSString *appKey;

/**
 广告界面风格
 */
@property (nonatomic, assign) AMPSAdvertisingInterfaceStyle interfaceStyle;

/**
 位置权限配置
 */
@property (nonatomic, strong, nullable) AMPSAdSDKLocationProvider *location;

/**
 调试模式开关，（默认NO）
 */
@property (nonatomic, assign) BOOL debug;

/**
 配置选填收集字段
 */
@property (nonatomic, strong) NSDictionary *optionalFields;

/**
 自定义userId
 */
@property (nonatomic, copy) NSString *userId;

/**
 自定义idfa
 */
@property (nonatomic, copy) NSString *customIDFA;

/**
 儿童隐私保护法案
 */
@property (nonatomic, strong) NSNumber *COPPA;

/**
 欧盟通用数据保护条例
 */
@property (nonatomic, strong) NSNumber *GDPR;

/**
 加州消费者隐私法案
 */
@property (nonatomic, strong) NSNumber *CCPA;

/**
 是否使用https
 */
@property (nonatomic, assign) BOOL isUseHttps;

@end

@interface AMPSAdSDKLocationProvider : NSObject

/**
 是否允许获取位置信息，（默认YES）
 */
@property (nonatomic, assign) BOOL canUseLocation;

/**
 纬度
 */
@property (nonatomic, assign) float latitude;

/**
 经度
 */
@property (nonatomic, assign) float longitude;

/**
 获取位置的时间戳
 */
@property (nonatomic, assign) uint64_t timestamp;

/**
 坐标系类型，比如 @"WGS84"
 */
@property (nonatomic, copy)   NSString *coordinate;

@end

NS_ASSUME_NONNULL_END
