//
//  AdScopeIOAOPs.h
//  AdScopeFoundation
//
//  Created by Cookie on 2024/3/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, AdScopeIOAOPOptions) {
    AdScopeIOAOPPositionAfter   = 0,            /// Called after the original implementation (default)
    AdScopeIOAOPPositionInstead = 1,            /// Will replace the original implementation.
    AdScopeIOAOPPositionBefore  = 2,            /// Called before the original implementation.
    
    AdScopeIOAOPOptionAutomaticRemoval = 1 << 3 /// Will remove the hook after the first execution.
};

/// Opaque AdScopeIOAOP Token that allows to deregister the hook.
@protocol AdScopeIOAOPToken <NSObject>

/// Deregisters an adScopeIOAOP.
/// @return YES if deregistration is successful, otherwise NO.
- (BOOL)remove;

@end

/// The AdScopeIOAOPInfo protocol is the first parameter of our block syntax.
@protocol AdScopeIOAOPInfo <NSObject>

/// The instance that is currently hooked.
- (id)instance;

/// The original invocation of the hooked method.
- (NSInvocation *)originalInvocation;

/// All method arguments, boxed. This is lazily evaluated.
- (NSArray *)arguments;

@end

/**
 AdScopeIOAOPs uses Objective-C message forwarding to hook into messages. This will create some overhead. Don't add adScopeIOAOPs to methods that are called a lot. AdScopeIOAOPs is meant for view/controller code that is not called a 1000 times per second.
 Adding adScopeIOAOPs returns an opaque token which can be used to deregister again. All calls are thread safe.
 */
@interface NSObject (AdScopeIOAOPs)

+ (id<AdScopeIOAOPToken>)adScopeIOAOP_hookSelector:(SEL)selector
                           withOptions:(AdScopeIOAOPOptions)options
                            usingBlock:(id)block
                                 error:(NSError **)error;

/// Adds a block of code before/instead/after the current `selector` for a specific instance.
- (id<AdScopeIOAOPToken>)adScopeIOAOP_hookSelector:(SEL)selector
                           withOptions:(AdScopeIOAOPOptions)options
                            usingBlock:(id)block
                                 error:(NSError **)error;

@end


typedef NS_ENUM(NSUInteger, AdScopeIOAOPErrorCode) {
    AdScopeIOAOPErrorSelectorBlacklisted,                   /// Selectors like release, retain, autorelease are blacklisted.
    AdScopeIOAOPErrorDoesNotRespondToSelector,              /// Selector could not be found.
    AdScopeIOAOPErrorSelectorDeallocPosition,               /// When hooking dealloc, only AdScopeIOAOPPositionBefore is allowed.
    AdScopeIOAOPErrorSelectorAlreadyHookedInClassHierarchy, /// Statically hooking the same method in subclasses is not allowed.
    AdScopeIOAOPErrorFailedToAllocateClassPair,             /// The runtime failed creating a class pair.
    AdScopeIOAOPErrorMissingBlockSignature,                 /// The block misses compile time signature info and can't be called.
    AdScopeIOAOPErrorIncompatibleBlockSignature,            /// The block signature does not match the method or is too large.

    AdScopeIOAOPErrorRemoveObjectAlreadyDeallocated = 100   /// (for removing) The object hooked is already deallocated.
};

extern NSString *const AdScopeIOAOPErrorDomain;

NS_ASSUME_NONNULL_END
