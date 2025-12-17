//
//  AMPSAdSDKError.h
//  AMPSAdSDK
//
//  Created by Cookie on 2024/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const AMPSAdErrorDomain;

typedef NS_ENUM(NSInteger, AMPSAdErrorCode) {
    // 广告渲染异常
    kAMPSAdErrorRenderException                                = -2,
    // 未知错误
    kAMPSAdErrorUnknow                                         = -1,
    // 初始化失败
    kAMPSAdErrorInitSDKFail                                    = 10001,
    // 广告位错误
    kAMPSAdErrorSpaceIdError                                   = 20001,
    // 广告位与调用接口不匹配
    kAMPSAdErrorAdTypeNotMatch                                 = 20002,
    // 广告请求时间过短
    kAMPSAdErrorTimeoutLess                                    = 20003,
    // 广告请求失败，请检查网络
    kAMPSAdErrorRequestFail                                    = 20004,
    // 广告请求超时
    kAMPSAdErrorRequestTimeout                                 = 20005,
    // 广告请求频繁
    kAMPSAdErrorRequestFrequent                                = 20006,
    // 没有匹配到合适的广告资源
    kAMPSAdErrorNoAdShow                                       = 20007,
    //广告渲染失败
    kAMPSAdErrorAdRenderFail                                   = 20008,
    // 包名校验错误，当前 App 的包名和官网注册媒体时填写的包名不一致
    kAMPSAdErrorBundleIdNotMatch                               = 20009,
    // SDK版本过低
    kAMPSAdErrorSDKVersionLess                                 = 20010,
    // 广告已经曝光过，不允许二次展示，请重新拉取
    kAMPSAdErrorAdDidExposured                                 = 20011,
    // 广告已经发起请求，等待结果后在发起请求
    kAMPSAdErrorAdDidLoading                                   = 20012,
    // 广告已经显示，广告关闭后在发起请求
    kAMPSAdErrorAdDidShow                                      = 20013,
    // 广告显示失败，调用show方法时window上不存在控制器
    kAMPSAdErrorAdShowFailNotRootViewController                = 20014,
};

@interface AMPSAdSDKError : NSObject

+ (NSError *)errorWithCode:(AMPSAdErrorCode)errorCode;

@end

NS_ASSUME_NONNULL_END
