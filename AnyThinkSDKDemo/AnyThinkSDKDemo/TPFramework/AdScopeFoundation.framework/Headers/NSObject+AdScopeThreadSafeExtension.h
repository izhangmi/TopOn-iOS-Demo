//
//  NSObject+AdScopeThreadSafeExtension.h
//  AdScopeFoundation
//
//  Created by Cookie on 2022/5/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (AdScopeThreadSafeExtension)

//  sync read data(同步读取数据)
- (id)adScopeSyncReadWithBlock:(id(^)(void))readBlock;

//  sync write data(同步写入数据)
- (void)adScopeSyncWriteWithBlock:(void(^)(void))writeBlock;

//  sync delete data(同步删除数据)
- (void)adScopeSyncDeleteWithBlock:(void(^)(void))deleteBlock;

//  async read data(异步读取数据)
- (id)adScopeAsyncReadWithBlock:(id(^)(void))readBlock;

//  async write data(异步写入数据)
- (void)adScopeAsyncWriteWithBlock:(void(^)(void))writeBlock;

//  async delete data(异步删除数据)
- (void)adScopeAsyncDeleteWithBlock:(void(^)(void))deleteBlock;

@end

NS_ASSUME_NONNULL_END
