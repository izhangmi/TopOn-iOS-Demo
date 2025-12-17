//
//  AMPSNativeExpressManager.h
//  AMPSAdSDK
//
//  Created by Cookie on 2024/11/25.
//

#import <AMPSAdSDK/AMPSInterfaceBaseObject.h>
#import <AMPSAdSDK/AMPSAdConfiguration.h>
#import <AMPSAdSDK/AMPSNativeExpressManagerDelegate.h>
#import <AMPSAdSDK/AMPSNativeExpressView.h>

NS_ASSUME_NONNULL_BEGIN

@interface AMPSNativeExpressManager : AMPSInterfaceBaseObject

/**
 广告配置对象
 */
@property (nonatomic, strong, readonly) AMPSAdConfiguration *adConfiguration;

/**
 Ad delegate
 */
@property (nonatomic, weak, nullable) id<AMPSNativeExpressManagerDelegate> delegate;

/**
 广告视图数组
 */
@property (nonatomic, strong) NSArray<AMPSNativeExpressView *> *viewsArray;

/**
 初始化实例对象
 @param adConfiguration ad configuration
 */
- (instancetype)initWithAdConfiguration:(AMPSAdConfiguration *)adConfiguration;

/**
 请求原生广告
 */
- (void)loadNativeExpressManager;

/**
 重置广告配置尺寸
 @param size 广告尺寸
 */
- (void)resetConfigurationAdSize:(CGSize)size;

/**
 销毁原生广告管理类
 */
- (void)removeNativeExpressManager;

@end

NS_ASSUME_NONNULL_END
