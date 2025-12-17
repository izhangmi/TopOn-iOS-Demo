//
//  NSTimer+AdScopeTimerExtension.h
//  AdScopeFoundation
//
//  Created by Cookie on 2022/9/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (AdScopeTimerExtension)

+ (NSTimer *)adScopeScheduledWeakTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;

@end

NS_ASSUME_NONNULL_END
