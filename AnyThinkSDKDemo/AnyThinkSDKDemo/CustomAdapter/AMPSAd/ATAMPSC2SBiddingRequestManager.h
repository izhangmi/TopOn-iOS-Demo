//
//  ATAMPSC2SBiddingRequestManager.h
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATAMPSCustomBiddingRequest.h"

NS_ASSUME_NONNULL_BEGIN

// HJC: AMPSAd C2S 竞价请求管理器
@interface ATAMPSC2SBiddingRequestManager : NSObject

+ (instancetype)sharedInstance;

- (void)startWithRequestItem:(ATAMPSCustomBiddingRequest *)request;

- (ATAMPSCustomBiddingRequest *)getRequestItemWithUnitID:(NSString *)unitID;

- (void)removeRequestItemWithUnitID:(NSString *)unitID;

@end

NS_ASSUME_NONNULL_END

