//
//  AdScopeAFURLResponseSerialization.h
//  AdScopeFoundation
//
//  Created by Cookie on 2022/9/5.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT id AdScopeAFJSONObjectByRemovingKeysWithNullValues(id JSONObject, NSJSONReadingOptions readingOptions);

@protocol AdScopeAFURLResponseSerialization <NSObject, NSSecureCoding, NSCopying>

- (nullable id)responseObjectForResponse:(nullable NSURLResponse *)response
                           data:(nullable NSData *)data
                          error:(NSError * _Nullable __autoreleasing *)error NS_SWIFT_NOTHROW;

@end

#pragma mark -

@interface AdScopeAFHTTPResponseSerializer : NSObject <AdScopeAFURLResponseSerialization>

- (instancetype)init;

+ (instancetype)serializer;

@property (nonatomic, copy, nullable) NSIndexSet *acceptableStatusCodes;

@property (nonatomic, copy, nullable) NSSet <NSString *> *acceptableContentTypes;

- (BOOL)validateResponse:(nullable NSHTTPURLResponse *)response
                    data:(nullable NSData *)data
                   error:(NSError * _Nullable __autoreleasing *)error;

@end

#pragma mark -

@interface AdScopeAFJSONResponseSerializer : AdScopeAFHTTPResponseSerializer

- (instancetype)init;

@property (nonatomic, assign) NSJSONReadingOptions readingOptions;

@property (nonatomic, assign) BOOL removesKeysWithNullValues;

+ (instancetype)serializerWithReadingOptions:(NSJSONReadingOptions)readingOptions;

@end

#pragma mark -

@interface AdScopeAFXMLParserResponseSerializer : AdScopeAFHTTPResponseSerializer

@end

#pragma mark -

#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED

@interface AdScopeAFXMLDocumentResponseSerializer : AdScopeAFHTTPResponseSerializer

- (instancetype)init;

@property (nonatomic, assign) NSUInteger options;

+ (instancetype)serializerWithXMLDocumentOptions:(NSUInteger)mask;

@end

#endif

#pragma mark -

@interface AdScopeAFPropertyListResponseSerializer : AdScopeAFHTTPResponseSerializer

- (instancetype)init;

@property (nonatomic, assign) NSPropertyListFormat format;

@property (nonatomic, assign) NSPropertyListReadOptions readOptions;

+ (instancetype)serializerWithFormat:(NSPropertyListFormat)format
                         readOptions:(NSPropertyListReadOptions)readOptions;

@end

#pragma mark -

@interface AdScopeAFImageResponseSerializer : AdScopeAFHTTPResponseSerializer

#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH

@property (nonatomic, assign) CGFloat imageScale;

@property (nonatomic, assign) BOOL automaticallyInflatesResponseImage;
#endif

@end

#pragma mark -

@interface AdScopeAFCompoundResponseSerializer : AdScopeAFHTTPResponseSerializer

@property (readonly, nonatomic, copy) NSArray <id<AdScopeAFURLResponseSerialization>> *responseSerializers;

+ (instancetype)compoundSerializerWithResponseSerializers:(NSArray <id<AdScopeAFURLResponseSerialization>> *)responseSerializers;

@end

FOUNDATION_EXPORT NSString * const AdScopeAFURLResponseSerializationErrorDomain;

FOUNDATION_EXPORT NSString * const AdScopeAFNetworkingOperationFailingURLResponseErrorKey;

FOUNDATION_EXPORT NSString * const AdScopeAFNetworkingOperationFailingURLResponseDataErrorKey;

NS_ASSUME_NONNULL_END
