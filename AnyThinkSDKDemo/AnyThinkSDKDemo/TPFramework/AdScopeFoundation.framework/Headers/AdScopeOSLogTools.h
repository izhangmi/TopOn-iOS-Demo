//
//  AdScopeOSLogTools.h
//  AdScopeFoundation
//
//  Created by Cookie on 2025/4/27.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN BOOL kAdScopeOSLogDebug;

@interface AdScopeOSLogTools : NSObject

+ (void)adScopeAnyLog:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END
