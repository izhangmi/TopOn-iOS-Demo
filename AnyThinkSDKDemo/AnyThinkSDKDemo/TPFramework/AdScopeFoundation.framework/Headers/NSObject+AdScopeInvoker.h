//
//  NSObject+AdScopeInvoker.h
//  AdScopeFoundation
//
//  Created by Cookie on 2022/9/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (AdScopeInvoker)

- (id)adScope_invoke:(NSString *)selector;
- (id)adScope_invoke:(NSString *)selector args:(id)arg, ... ;
- (id)adScope_invoke:(NSString *)selector arguments:(NSArray *_Nullable)arguments;

+ (id)adScope_invoke:(NSString *)selector;
+ (id)adScope_invoke:(NSString *)selector args:(id)arg, ... ;
+ (id)adScope_invoke:(NSString *)selector arguments:(NSArray *_Nullable)arguments;

- (id)adScope_invokeSetParameter:(NSString *)parameter args:(id _Nullable)arg;

- (BOOL)adScope_respondsToSelector:(SEL)aSelector;

@end


@interface NSString (AdScopeInvoker)

- (id)adScope_invokeClassMethod:(NSString *)selector;
- (id)adScope_invokeClassMethod:(NSString *)selector args:(id)arg, ... ;
- (id)adScope_invokeClassMethod:(NSString *)selector arguments:(NSArray *_Nullable)arguments;

@end

NS_ASSUME_NONNULL_END
