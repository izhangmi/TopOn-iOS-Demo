//
//  AdScopeAppInfo.h
//  AdScopeFoundation
//
//  Created by Cookie on 2022/8/4.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_subclassing_restricted))
@interface AdScopeAppInfo : NSObject

+ (AdScopeAppInfo *)sharedInstance;

+ (void)appInstallOrUpdate;

@property (nonatomic, readonly) NSString *adScopeVersion;
@property (nonatomic, readonly) NSString *adScopeName;
@property (nonatomic, readonly) NSString *adScopePackage;
@property (nonatomic, readonly) uint64_t adScopeInstallTime;
@property (nonatomic, readonly) uint64_t adScopeUpdateTime;

@end

NS_ASSUME_NONNULL_END
