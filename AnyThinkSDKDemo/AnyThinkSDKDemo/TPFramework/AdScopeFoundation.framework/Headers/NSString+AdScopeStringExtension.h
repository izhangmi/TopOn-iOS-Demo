//
//  NSString+AdScopeStringExtension.h
//  AdScopeFoundation
//
//  Created by Cookie on 2022/9/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (AdScopeStringExtension)

- (NSString *)adScopeStringUrlEncode;

- (NSString *)adScopeStringUrlDecode;

- (NSString *)adScopeMD5;

- (NSString *)adScopeStringBase64Encoding;

- (NSString *)adScopeStringBase64Decoding;

+ (NSString *)adScopeFoundationDirectory;

+ (NSString *)adScopeRandomUUID;

@end

@interface NSObject (AdScopeNullStringExtension)

- (BOOL)adScopeSafeIsEqualToString:(NSString *)aString;

@end

NS_ASSUME_NONNULL_END
