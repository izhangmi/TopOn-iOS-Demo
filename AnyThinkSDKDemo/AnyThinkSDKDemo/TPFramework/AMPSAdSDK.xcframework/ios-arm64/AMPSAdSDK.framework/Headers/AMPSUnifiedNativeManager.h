//
//  AMPSUnifiedNativeManager.h
//  AMPSAdSDK
//
//  Created by Cookie on 2025/1/14.
//

#import <AMPSAdSDK/AMPSInterfaceBaseObject.h>
#import <AMPSAdSDK/AMPSAdConfiguration.h>
#import <AMPSAdSDK/AMPSUnifiedNativeManagerDelegate.h>
#import <AMPSAdSDK/AMPSUnifiedNativeAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface AMPSUnifiedNativeManager : AMPSInterfaceBaseObject

/**
 广告配置对象
 */
@property (nonatomic, strong, readonly) AMPSAdConfiguration *adConfiguration;

/**
 Ad delegate
 */
@property (nonatomic, weak, nullable) id<AMPSUnifiedNativeManagerDelegate> delegate;

/**
 广告视图数组
 */
@property (nonatomic, strong) NSArray<AMPSUnifiedNativeAd *> *adArray;

/**
 初始化实例对象
 @param adConfiguration ad configuration
 */
- (instancetype)initWithAdConfiguration:(AMPSAdConfiguration *)adConfiguration;

/**
 请求原生广告
 */
- (void)loadUnifiedNativeManager;

/**
 销毁原生广告管理类
 */
- (void)removeUnifiedNativeManager;

@end

NS_ASSUME_NONNULL_END
