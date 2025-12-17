//
//  AdScopeAFSecurityPolicy.h
//  AdScopeFoundation
//
//  Created by Cookie on 2022/9/5.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

typedef NS_ENUM(NSUInteger, AdScopeAFSSLPinningMode) {
    AdScopeAFSSLPinningModeNone,
    AdScopeAFSSLPinningModePublicKey,
    AdScopeAFSSLPinningModeCertificate,
};

NS_ASSUME_NONNULL_BEGIN

@interface AdScopeAFSecurityPolicy : NSObject <NSSecureCoding, NSCopying>

@property (readonly, nonatomic, assign) AdScopeAFSSLPinningMode SSLPinningMode;

@property (nonatomic, strong, nullable) NSSet <NSData *> *pinnedCertificates;

@property (nonatomic, assign) BOOL allowInvalidCertificates;

@property (nonatomic, assign) BOOL validatesDomainName;

+ (NSSet <NSData *> *)certificatesInBundle:(NSBundle *)bundle;

+ (instancetype)defaultPolicy;

+ (instancetype)policyWithPinningMode:(AdScopeAFSSLPinningMode)pinningMode;

+ (instancetype)policyWithPinningMode:(AdScopeAFSSLPinningMode)pinningMode withPinnedCertificates:(NSSet <NSData *> *)pinnedCertificates;

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(nullable NSString *)domain;

@end

NS_ASSUME_NONNULL_END
