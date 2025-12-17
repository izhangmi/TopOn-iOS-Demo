//
//  AdScopeCrashHandle.h
//  AdScopeFoundation
//
//  Created by Cookie on 2022/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AdScopeThreadSafeArray;

@interface AdScopeCrashHandle : NSObject

@property (nonatomic, assign) BOOL installed;
@property (nonatomic, assign) BOOL sent;
@property (nonatomic, assign) BOOL alreadyReport;
@property (nonatomic, assign) BOOL hasCrach;
@property (nonatomic, assign) BOOL closePermission;
@property (nonatomic, copy) NSString *affiliated;
@property (nonatomic, strong) AdScopeThreadSafeArray *crashLogs;

+ (instancetype)sharedInstance;
- (void)install;
- (void)uninstall;
- (void)sendCrashLog;
- (void)saveException:(NSException *)exception;
- (void)saveSignal:(int)sigNum signalInfo:(siginfo_t *)signalInfo;

@end

NS_ASSUME_NONNULL_END
