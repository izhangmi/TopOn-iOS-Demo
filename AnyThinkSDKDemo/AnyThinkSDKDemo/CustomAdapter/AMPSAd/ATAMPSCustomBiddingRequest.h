//
//  ATAMPSCustomBiddingRequest.h
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import <AnyThinkNative/AnyThinkNative.h>

NS_ASSUME_NONNULL_BEGIN

// HJC: AMPSAd 广告格式枚举
typedef NS_ENUM(NSInteger, AMPSAdFormat) {
    AMPSAdFormatSplash = 0,
    AMPSAdFormatNative = 1,
    AMPSAdFormatInterstitial = 2
};

// HJC: AMPSAd 自定义竞价请求对象
@interface ATAMPSCustomBiddingRequest : NSObject

@property(nonatomic, strong) id customObject;

@property(nonatomic, strong) ATUnitGroupModel *unitGroup;

@property(nonatomic, strong) ATAdCustomEvent *customEvent;

@property (nonatomic, assign) NSTimeInterval tolerateTimeout;

@property(nonatomic, copy) NSString *unitID;

@property(nonatomic, copy) NSString *placementID;

@property(nonatomic, copy) NSString *publisherID;

@property(nonatomic, copy) NSDictionary *extraInfo;

@property(nonatomic, assign) AMPSAdFormat adType;

@property(nonatomic, copy) void(^bidCompletion)(ATBidInfo * _Nullable bidInfo, NSError * _Nullable error);

@property(nonatomic, copy) NSArray<NSDictionary *> *assets;

@end

NS_ASSUME_NONNULL_END

