//
//  NSData+AdScopeDataExtension.h
//  AdScopeFoundation
//
//  Created by Cookie on 2022/5/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (AdScopeDataExtension)

//  Gzipt压缩
- (NSData *)adScopeGzipData;
//  Gzipt解压
- (NSData *)adScopeUngzipData;
//  是否为压缩
- (BOOL)adScopeIsGzippedData;

@end

@interface NSData (AdScopeAESData)

//  128
- (NSData *)adScopeAes128EncryptWithKey:(NSString *)key iv:(NSString *)iv;
- (NSData *)adScopeAes128DecryptWithKey:(NSString *)key iv:(NSString *)iv;

//  256
- (NSData *)adScopeAes256EncryptWithKey:(NSString *)key iv:(NSString *)iv;
- (NSData *)adScopeAes256DecryptWithKey:(NSString *)key iv:(NSString *)iv;

@end

NS_ASSUME_NONNULL_END
