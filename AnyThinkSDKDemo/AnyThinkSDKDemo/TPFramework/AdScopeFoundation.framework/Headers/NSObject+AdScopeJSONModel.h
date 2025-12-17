//
//  NSObject+AdScopeJSONModel.h
//  AdScopeFoundation
//
//  Created by Cookie on 2022/7/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (AdScopeJSONModel)

+ (nullable instancetype)adScope_modelWithJSON:(id)json;

+ (nullable instancetype)adScope_modelWithDictionary:(NSDictionary *)dictionary;

- (BOOL)adScope_modelSetWithJSON:(id)json;

- (BOOL)adScope_modelSetWithDictionary:(NSDictionary *)dic;

- (nullable id)adScope_modelToJSONObject;

- (nullable NSData *)adScope_modelToJSONData;

- (nullable NSString *)adScope_modelToJSONString;

- (nullable id)adScope_modelCopy;

- (void)adScope_modelEncodeWithCoder:(NSCoder *)aCoder;

- (id)adScope_modelInitWithCoder:(NSCoder *)aDecoder;

- (NSUInteger)adScope_modelHash;

- (BOOL)adScope_modelIsEqual:(id)model;

- (NSString *)adScope_modelDescription;

@end

@interface NSArray (AdScopeJSONModel)

+ (nullable NSArray *)adScope_modelArrayWithClass:(Class)cls json:(id)json;

@end

@interface NSDictionary (AdScopeJSONModel)

+ (nullable NSDictionary *)adScope_modelDictionaryWithClass:(Class)cls json:(id)json;

@end

@protocol AdScopeJSONModel <NSObject>
@optional

+ (nullable NSDictionary<NSString *, id> *)adScope_modelCustomPropertyMapper;

+ (nullable NSDictionary<NSString *, id> *)adScope_modelContainerPropertyGenericClass;

+ (nullable Class)adScope_modelCustomClassForDictionary:(NSDictionary *)dictionary;

+ (nullable NSArray<NSString *> *)adScope_modelPropertyBlacklist;

+ (nullable NSArray<NSString *> *)adScope_modelPropertyWhitelist;

- (NSDictionary *)adScope_modelCustomWillTransformFromDictionary:(NSDictionary *)dic;

- (BOOL)adScope_modelCustomTransformFromDictionary:(NSDictionary *)dic;

- (BOOL)adScope_modelCustomTransformToDictionary:(NSMutableDictionary *)dic;

@end

NS_ASSUME_NONNULL_END

