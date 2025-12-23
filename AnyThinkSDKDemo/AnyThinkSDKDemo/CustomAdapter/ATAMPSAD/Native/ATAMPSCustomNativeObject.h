//
//  ATAMPSCustomNativeObject.h
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import <AnyThinkSDK/AnyThinkSDK.h>
#import <Foundation/Foundation.h>
#import <AMPSAdSDK/AMPSAdSDK.h>
#import "../Base/ATAMPSCustomAdapterCommonHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATAMPSCustomNativeObject : ATCustomNetworkNativeAd

@property (nonatomic, strong, nullable) AMPSNativeExpressView *nativeExpressView;
@property (nonatomic, strong, nullable) AMPSUnifiedNativeView *unifiedNativeView;
@property (nonatomic, strong, nullable) AMPSNativeExpressManager *nativeExpressManager;
@property (nonatomic, strong, nullable) AMPSUnifiedNativeManager *unifiedNativeManager;

@end

NS_ASSUME_NONNULL_END

