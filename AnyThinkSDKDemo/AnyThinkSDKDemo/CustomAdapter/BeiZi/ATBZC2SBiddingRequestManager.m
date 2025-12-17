//
//  ATBZC2SBiddingRequestManager.m
//  AnyThinkSDKDemo
//
//  Created by nie adhub on 2023/10/24.
//  Copyright © 2023 抽筋的灯. All rights reserved.
//

#import "ATBZC2SBiddingRequestManager.h"
#import <BeiZiSDK/BeiZiSDK.h>
#import "ATBZNativeADCustomEvent.h"

@interface ATBZC2SBiddingRequestManager ()

@property (nonatomic, strong) NSMutableDictionary *bidingAdStorageAccessor;

@property (nonatomic, strong) BeiZiNativeExpress *nativeExpressAd;

@end

@implementation ATBZC2SBiddingRequestManager

+ (instancetype)sharedInstance {
    static ATBZC2SBiddingRequestManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ATBZC2SBiddingRequestManager alloc] init];
        sharedInstance.bidingAdStorageAccessor = [NSMutableDictionary dictionary];
    });
    return sharedInstance;
}

- (ATBZCustomBiddingRequest *)getRequestItemWithUnitID:(NSString *)unitID {
    @synchronized (self) {
        return [self.bidingAdStorageAccessor objectForKey:unitID];
    }
    
}

- (void)removeRequestItmeWithUnitID:(NSString *)unitID {
    @synchronized (self) {
        [self.bidingAdStorageAccessor removeObjectForKey:unitID];
    }
}

- (void)startWithRequestItem:(ATBZCustomBiddingRequest *)request {
    if (request.unitID) {
        [self.bidingAdStorageAccessor setObject:request forKey:request.unitID];
        [request.customObject setValue:request.customEvent forKey:@"delegate"];
    }
}

@end
