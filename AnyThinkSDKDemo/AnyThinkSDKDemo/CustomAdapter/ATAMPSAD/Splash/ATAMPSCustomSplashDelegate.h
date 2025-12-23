//
//  ATAMPSCustomSplashDelegate.h
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import <AnyThinkSDK/AnyThinkSDK.h>
#import <AMPSAdSDK/AMPSAdSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATAMPSCustomSplashDelegate : NSObject <AMPSSplashAdDelegate>

@property (nonatomic, strong) ATSplashAdStatusBridge *adStatusBridge;
@property (nonatomic, strong) NSDictionary *serverInfo;
@property (nonatomic, strong) NSDictionary *localInfo;
@property (nonatomic, strong) NSDate *expireDate;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, strong) NSString *spaceId;
@property (nonatomic, assign) BOOL isC2SBiding;

- (instancetype)initWithInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo;

@end

NS_ASSUME_NONNULL_END

