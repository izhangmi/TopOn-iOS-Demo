//
//  AMPSAdSDKDefines.h
//  AMPSAdSDK
//
//  Created by Cookie on 2024/11/25.
//

#import <Foundation/Foundation.h>

#if defined(__has_attribute)
#if __has_attribute(deprecated)
#define AMPS_DEPRECATED_MSG_ATTRIBUTE(s) __attribute__((deprecated(s)))
#define AMPS_DEPRECATED_ATTRIBUTE __attribute__((deprecated))
#else
#define AMPS_DEPRECATED_MSG_ATTRIBUTE(s)
#define AMPS_DEPRECATED_ATTRIBUTE
#endif
#else
#define AMPS_DEPRECATED_MSG_ATTRIBUTE(s)
#define AMPS_DEPRECATED_ATTRIBUTE
#endif

//  初始化状态
typedef NS_ENUM(NSInteger, AMPSAdSDKInitStatus) {
    kAMPSAdSDKInitStatusNormal          = 0,
    kAMPSAdSDKInitStatusLoading         = 1,
    kAMPSAdSDKInitStatusSuccess         = 2,
    kAMPSAdSDKInitStatusFail            = 3,
    kAMPSAdSDKInitStatusFailRepeat      = 4,
};

//  推荐广告
typedef NS_ENUM(NSInteger, AMPSPersonalizedRecommendState) {
    kAMPSPersonalizedRecommendStateClose = 0,
    kAMPSPersonalizedRecommendStateOpen  = 1
};

//  广告界面风格
typedef NS_ENUM(NSInteger, AMPSAdvertisingInterfaceStyle) {
    AMPSAdvertisingInterfaceStyleLight      = 0,
    AMPSAdvertisingInterfaceStyleDark       = 1,
    AMPSAdvertisingInterfaceStyleAuto       = 2,
};

//  竞价失败原因
typedef NS_ENUM(NSInteger, AMPSBiddingLossReason) {
    AMPSBiddingLossReasonLowPrice          = 1,        // 价格低于其他渠道
    AMPSBiddingLossReasonLoadTimeout       = 2,        // 获取价格超时
    AMPSBiddingLossReasonOther             = 999,      // 其他
};

//  ADN列表
typedef NS_ENUM(NSInteger, AMPSBiddingADNList) {
    AMPSBiddingADNListGDT           = 1012,
    AMPSBiddingADNListCSJ           = 1013,
    AMPSBiddingADNListBaiDu         = 1018,
    AMPSBiddingADNListKS            = 1019,
    AMPSBiddingADNListGM            = 1022,
    AMPSBiddingADNListASNP          = 8888,
    AMPSBiddingADNListOther         = 9999,
};


typedef NS_ENUM(NSInteger, AMPSUnifiedNativeMode) {
    AMPSUnifiedNativeModeNativeExpress      = 1,
    AMPSUnifiedNativeModeUnifiedImage       = 2,
    AMPSUnifiedNativeModeUnifiedVideo       = 3,
};

typedef NS_ENUM(NSInteger, AMPSInteractionType) {
    AMPSInteractionTypeUnknown            = 0,
    AMPSInteractionTypeLandingPage        = 1,
    AMPSInteractionTypeOpenLink           = 2,
    AMPSInteractionTypeOpenStore          = 3,
};
