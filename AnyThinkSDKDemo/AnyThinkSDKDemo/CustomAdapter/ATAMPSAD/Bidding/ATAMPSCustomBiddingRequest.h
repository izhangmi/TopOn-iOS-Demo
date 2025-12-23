//
//  ATAMPSCustomBiddingRequest.h
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import <AnyThinkSDK/AnyThinkSDK.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ATAMPSAdFormat) {
    ATAMPSAdFormatSplash = 0,
    ATAMPSAdFormatNative = 1,
    ATAMPSAdFormatInterstitial = 2
};

@interface ATAMPSCustomBiddingRequest : NSObject

@property (nonatomic, strong) id customObject;
@property (nonatomic, strong) ATUnitGroupModel *unitGroup;
@property (nonatomic, strong) id customEvent;
@property (nonatomic, assign) NSTimeInterval tolerateTimeout;
@property (nonatomic, copy) NSString *unitID;
@property (nonatomic, copy) NSString *placementID;
@property (nonatomic, copy) NSString *publisherID;
@property (nonatomic, copy) NSDictionary *extraInfo;
@property (nonatomic, assign) ATAMPSAdFormat adType;
@property (nonatomic, copy) void(^bidCompletion)(ATBidInfo * _Nullable bidInfo, NSError * _Nullable error);
@property (nonatomic, copy) NSArray<NSDictionary *> *assets;

@end

NS_ASSUME_NONNULL_END
