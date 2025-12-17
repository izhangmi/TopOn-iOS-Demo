//
//  AdScopeDeviceInfo.h
//  AdScopeFoundation
//
//  Created by Cookie on 2022/4/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_subclassing_restricted))
@interface AdScopeDeviceInfo : NSObject

+ (AdScopeDeviceInfo *)sharedInstance;

- (void)setCustomConfigure:(NSDictionary *)paramData;
- (void)registerGeoInfo;
- (void)updateGeoInfo;

@property (nonatomic, readonly) NSString *adScopeFoundationVersion;
@property (nonatomic, readonly) uint64_t adScopeTimeStamp;
@property (nonatomic, readonly) uint64_t adScopeMTimeStamp;
@property (nonatomic, readonly) NSInteger adScopeDeviceType;
@property (nonatomic, readonly) NSString *adScopeBrand;
@property (nonatomic, readonly) NSString *adScopeModel;
@property (nonatomic, readonly) NSString *adScopeOS;
@property (nonatomic, readonly) NSString *adScopeOSVersion;
@property (nonatomic, readonly) NSString *adScopeCarrier;
@property (nonatomic, readonly) NSInteger adScopeConnectType;
@property (nonatomic, readonly) NSString *adScopeLanguage;
@property (nonatomic, readonly) NSInteger adScopeScreenWidth;
@property (nonatomic, readonly) NSInteger adScopeScreenHeight;
@property (nonatomic, readonly) NSInteger adScopeResolutionWidth;
@property (nonatomic, readonly) NSInteger adScopeResolutionHeight;
@property (nonatomic, readonly) NSInteger adScopeOrientation;
@property (nonatomic, readonly) CGFloat adScopePxration;
@property (nonatomic, readonly) NSString *adScopeIDFV;
@property (nonatomic, readonly) NSString *adScopeRoot;
@property (nonatomic, readonly) NSString *adScopeBootMark;
@property (nonatomic, readonly) NSString *adScopeUpdateMark;
@property (nonatomic, readonly) NSString *adScopeSysUpdateMark;
@property (nonatomic, readonly) NSString *adScopeFileMark;
@property (nonatomic, readonly) NSString *adScopePhysicalMemory;
@property (nonatomic, readonly) NSString *adScopeHarddiskSize;
@property (nonatomic, readonly) NSString *adScopeUserAgent;
@property (nonatomic, readonly) NSString *adScopeIDFA;
@property (nonatomic, readonly) NSString *adScopeSDKId;
@property (nonatomic, readonly) NSString *adScopeCountryCode;
@property (nonatomic, readonly) NSString *adScopeDeviceModel;
@property (nonatomic, readonly) NSString *adScopeTimeZone;
@property (nonatomic, readonly) NSString *adScopeDeviceName;
@property (nonatomic, readonly) NSString *adScopeMntId;
@property (nonatomic, readonly) NSInteger adScopeInterfaceStyle;
@property (nonatomic, readonly) NSInteger adScopeActive;
@property (nonatomic, readonly) NSInteger adScopeDeveloper;
@property (nonatomic, strong)   NSString *adScopeCustomIDFA;
@property (nonatomic, readonly) float adScopeLatitude;
@property (nonatomic, readonly) float adScopeLongitude;
@property (nonatomic, readonly) uint64_t adScopeGeoTimestamp;
@property (nonatomic, readonly) NSString *adScopeCoordinate;
@property (nonatomic, assign)   BOOL adScopeLmtStatus;

@end

NS_ASSUME_NONNULL_END
