//
//  AdScopeAFNetworkReachabilityManager.h
//  AdScopeFoundation
//
//  Created by Cookie on 2022/9/5.
//

#import <Foundation/Foundation.h>

#if !TARGET_OS_WATCH
#import <SystemConfiguration/SystemConfiguration.h>

typedef NS_ENUM(NSInteger, AdScopeAFNetworkReachabilityStatus) {
    AdScopeAFNetworkReachabilityStatusUnknown          = -1,
    AdScopeAFNetworkReachabilityStatusNotReachable     = 0,
    AdScopeAFNetworkReachabilityStatusReachableViaWWAN = 1,
    AdScopeAFNetworkReachabilityStatusReachableViaWiFi = 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface AdScopeAFNetworkReachabilityManager : NSObject

@property (readonly, nonatomic, assign) AdScopeAFNetworkReachabilityStatus networkReachabilityStatus;

@property (readonly, nonatomic, assign, getter = isReachable) BOOL reachable;

@property (readonly, nonatomic, assign, getter = isReachableViaWWAN) BOOL reachableViaWWAN;

@property (readonly, nonatomic, assign, getter = isReachableViaWiFi) BOOL reachableViaWiFi;

+ (instancetype)sharedManager;

+ (instancetype)manager;

+ (instancetype)managerForDomain:(NSString *)domain;

+ (instancetype)managerForAddress:(const void *)address;

- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

- (void)startMonitoring;

- (void)stopMonitoring;

- (NSString *)localizedNetworkReachabilityStatusString;

- (void)setReachabilityStatusChangeBlock:(nullable void (^)(AdScopeAFNetworkReachabilityStatus status))block;

@end

FOUNDATION_EXPORT NSString * const AdScopeAFNetworkingReachabilityDidChangeNotification;
FOUNDATION_EXPORT NSString * const AdScopeAFNetworkingReachabilityNotificationStatusItem;

FOUNDATION_EXPORT NSString * AdScopeAFStringFromNetworkReachabilityStatus(AdScopeAFNetworkReachabilityStatus status);

NS_ASSUME_NONNULL_END
#endif

