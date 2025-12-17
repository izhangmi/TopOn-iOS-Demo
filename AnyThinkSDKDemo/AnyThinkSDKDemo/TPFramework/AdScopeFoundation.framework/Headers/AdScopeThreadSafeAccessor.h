//
//  AdScopeThreadSafeAccessor.h
//  AdScopeFoundation
//
//  Created by Cookie on 2023/4/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdScopeThreadSafeAccessor : NSObject

@end

@interface AdScopeSerialThreadSafeAccessor : NSObject

- (id)adScopeReadWithBlock:(id(^)(void))readBlock;
- (void)adScopeWriteWithBlock:(void(^)(void))writeBlock;
- (id)adScopeSerialAyncReadWithBlock:(id(^)(void))readBlock;
- (void)adScopeSerialAyncWriteWithBlock:(void(^)(void))writeBlock;

@end

@interface AdScopeConcurrentThreadSafeAccessor : NSObject

- (id)adScopeConcurrentSyncReadWithBlock:(id(^)(void))readBlock;
- (void)adScopeConcurrentSyncWriteWithBlock:(void(^)(void))writeBlock;
- (id)adScopeReadWithBlock:(id(^)(void))readBlock;
- (void)adScopeWriteWithBlock:(void(^)(void))writeBlock;

@end

NS_ASSUME_NONNULL_END
