//
//  ATAMPSC2SBiddingRequestManager.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import "ATAMPSC2SBiddingRequestManager.h"

// HJC: AMPSAd C2S 竞价请求管理器实现
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

// HJC: 根据 unitID 获取竞价请求对象
- (ATAMPSCustomBiddingRequest *)getRequestItemWithUnitID:(NSString *)unitID {
    @synchronized (self) {
        return [self.biddingAdStorageAccessor objectForKey:unitID];
    }
}

// HJC: 移除指定 unitID 的竞价请求对象
- (void)removeRequestItemWithUnitID:(NSString *)unitID {
    @synchronized (self) {
        [self.biddingAdStorageAccessor removeObjectForKey:unitID];
    }
}

// HJC: 开始竞价请求，存储请求对象
- (void)startWithRequestItem:(ATAMPSCustomBiddingRequest *)request {
    if (request.unitID) {
        [self.biddingAdStorageAccessor setObject:request forKey:request.unitID];
        // HJC: 设置代理对象
        if ([request.customObject respondsToSelector:@selector(setDelegate:)]) {
            [request.customObject setValue:request.customEvent forKey:@"delegate"];
        }
    }
}

@end

