//
//  AdScpoeSafeUtilities.h
//  AdScopeFoundation
//
//  Created by Cookie on 2022/5/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

void AdScopeSafeRunMethod(void(^Block)(void));

@interface AdScpoeSafeUtilities : NSObject

@end

NS_ASSUME_NONNULL_END
