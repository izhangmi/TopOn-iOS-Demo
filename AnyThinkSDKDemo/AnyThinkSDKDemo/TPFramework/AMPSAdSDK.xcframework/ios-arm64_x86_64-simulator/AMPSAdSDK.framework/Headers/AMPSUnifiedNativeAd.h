//
//  AMPSUnifiedNativeAd.h
//  AMPSAdSDK
//
//  Created by Cookie on 2025/1/22.
//

#import <AMPSAdSDK/AMPSInterfaceBaseObject.h>
#import <AMPSAdSDK/AMPSAdSDKDefines.h>

NS_ASSUME_NONNULL_BEGIN

@interface AMPSUnifiedNativeAd : AMPSInterfaceBaseObject

//  广告类型
@property (nonatomic, assign, readonly) AMPSUnifiedNativeMode nativeMode;
//  广告标题
@property (nonatomic, copy, readonly) NSString *title;
//  广告描述
@property (nonatomic, copy, readonly) NSString *desc;
//  应用类广告App 图标Url
@property (nonatomic, copy, readonly) NSString *iconUrl;
//  广告大图Url
@property (nonatomic, copy, readonly) NSString *imageUrl;
//  广告对应的按钮展示文案, 此字段可能为空
@property (nonatomic, copy, readonly) NSString *actionText;
//  广告logo url, 此字段可能为空
@property (nonatomic, copy, readonly) NSString *adLogoUrl;
//  三小图广告的图片Url集合
@property (nonatomic, strong, readonly) NSArray *imageUrls;

@end

NS_ASSUME_NONNULL_END
