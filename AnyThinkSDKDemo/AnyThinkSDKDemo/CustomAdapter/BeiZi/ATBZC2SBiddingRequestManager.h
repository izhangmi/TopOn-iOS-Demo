//
//  ATBZC2SBiddingRequestManager.h
//  AnyThinkSDKDemo
//
//  Created by nie adhub on 2023/10/24.
//  Copyright © 2023 抽筋的灯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATBZCustomBiddingRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATBZC2SBiddingRequestManager : NSObject

+ (instancetype)sharedInstance;

- (void)startWithRequestItem:(ATBZCustomBiddingRequest *)request;

- (ATBZCustomBiddingRequest *)getRequestItemWithUnitID:(NSString *)unitID;

- (void)removeRequestItmeWithUnitID:(NSString *)unitID;

@end

NS_ASSUME_NONNULL_END
