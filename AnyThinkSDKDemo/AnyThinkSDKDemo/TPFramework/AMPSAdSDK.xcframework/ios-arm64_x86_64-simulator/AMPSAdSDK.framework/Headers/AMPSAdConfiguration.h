//
//  AMPSAdConfiguration.h
//  AMPSAdSDK
//
//  Created by Cookie on 2024/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AMPSAdConfiguration : NSObject

/**
 测试广告，0:正式广告；1:测试广告。调试完成后设置成0。
 */
@property (nonatomic, assign) NSInteger testAd;

/**
 是否为中国大陆
 */
@property (nonatomic, assign) BOOL county_CN;

/**
 广告位Id
 */
@property (nonatomic, copy) NSString *spaceId;

/**
 广告尺寸
 when adSize.height is zero, The height will auto
 */
@property (nonatomic, assign) CGSize adSize;

/**
 广告数量，仅原生广告支持设置; Default 1; Max 3
 */
@property (nonatomic, assign) NSInteger adCount;

/**
 拉取广告超时时间，默认为5000毫秒，（注意：此处单位是毫秒）
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 自定义信息
 */
@property (nonatomic, strong) NSDictionary *customData;

@end

NS_ASSUME_NONNULL_END
