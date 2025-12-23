//
//  ATAMPSCustomInterstitialDelegate.h
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import <AnyThinkSDK/AnyThinkSDK.h>
#import <AMPSAdSDK/AMPSAdSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATAMPSCustomInterstitialDelegate : NSObject <AMPSInterstitialAdDelegate>

@property (nonatomic, strong) ATInterstitialAdStatusBridge *adStatusBridge;
@property (nonatomic, strong) NSDictionary *serverInfo;
@property (nonatomic, strong) NSDictionary *localInfo;
@property (nonatomic, strong) NSString *spaceId;
@property (nonatomic, assign) BOOL isC2SBiding;

- (instancetype)initWithInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo;

@end

NS_ASSUME_NONNULL_END

