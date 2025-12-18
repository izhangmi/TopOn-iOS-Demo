//
//  ATAMPSC2SBiddingRequestManager.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import "ATAMPSC2SBiddingRequestManager.h"

@interface ATAMPSC2SBiddingRequestManager ()

@property (nonatomic, strong) NSMutableDictionary *biddingAdStorageAccessor;

@end

@implementation ATAMPSC2SBiddingRequestManager

+ (instancetype)sharedInstance {
    static ATAMPSC2SBiddingRequestManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ATAMPSC2SBiddingRequestManager alloc] init];
        sharedInstance.biddingAdStorageAccessor = [NSMutableDictionary dictionary];
    });
    return sharedInstance;
}

- (ATAMPSCustomBiddingRequest *)getRequestItemWithUnitID:(NSString *)unitID {
    @synchronized (self) {
        return [self.biddingAdStorageAccessor objectForKey:unitID];
    }
}

- (void)removeRequestItemWithUnitID:(NSString *)unitID {
    @synchronized (self) {
        [self.biddingAdStorageAccessor removeObjectForKey:unitID];
    }
}

- (void)startWithRequestItem:(ATAMPSCustomBiddingRequest *)request {
    if (request.unitID) {
        [self.biddingAdStorageAccessor setObject:request forKey:request.unitID];
        if (request.customObject && [request.customObject respondsToSelector:@selector(setDelegate:)]) {
            [request.customObject setValue:request.customEvent forKey:@"delegate"];
        }
    }
}

@end

