//
//  NSDictionary+AdScopeSafeExtension.h
//  AdScopeFoundation
//
//  Created by Cookie on 2022/8/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (AdScopeSafeExtension)

@end

@interface NSMutableDictionary (AdScopeSafeExtension)

- (id _Nullable )adScopeSafeSetObject:(nullable id)anObject forKey:(nullable id)aKey;

- (void)adScopeSafeRemoveObjectForKey:(nullable id)aKey;

@end

NS_ASSUME_NONNULL_END
