//
//  NSArray+AdScopeSafeExtension.h
//  AdScopeFoundation
//
//  Created by Cookie on 2022/4/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (AdScopeSafeExtension)

//  safely get the object at the array index
- (id)adScopeSafeObjectAtIndex:(NSUInteger)index;
//  is the empty array
+ (BOOL)adScopeIsEmptyArray:(NSMutableArray *)array;

@end

@interface NSMutableArray (AdScopeSafeExtension)

- (void)adScopeSafeAddObject:(id)anObject;
- (void)adScopeSafeInsertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)adScopeSafeRemoveObjectAtIndex:(NSUInteger)index;
//  safely get the object at the array index
- (id)adScopeSafeObjectAtIndex:(NSUInteger)index;
//  is the empty array
+ (BOOL)adScopeIsEmptyArray:(NSMutableArray *)array;

@end

NS_ASSUME_NONNULL_END
