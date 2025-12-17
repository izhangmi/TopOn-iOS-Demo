//
//  ATAMPSNativeCustomAdapter.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import "ATAMPSNativeCustomAdapter.h"
#import "ATAMPSNativeExpressCustomEvent.h"
#import "ATAMPSUnifiedNativeCustomEvent.h"
#import "ATAMPSNativeCustomRenderer.h"
#import "ATAMPSCustomBiddingRequest.h"
#import "ATAMPSC2SBiddingRequestManager.h"
#import <AMPSAdSDK/AMPSAdSDK.h>

static BOOL _isCustomRender = NO;

// HJC: AMPSAd Native 广告自定义适配器实现
@interface ATAMPSNativeCustomAdapter () <ATAdAdapter>

@property (nonatomic, strong) ATAMPSNativeExpressCustomEvent *expressCustomEvent;
@property (nonatomic, strong) ATAMPSUnifiedNativeCustomEvent *unifiedCustomEvent;

@property (nonatomic, strong) AMPSNativeExpressManager *nativeExpressManager;

@property (nonatomic, strong) AMPSUnifiedNativeManager *unifiedNativeManager;

@property (nonatomic, assign, class) BOOL isCustomRender;

@end

@implementation ATAMPSNativeCustomAdapter

+ (BOOL)isCustomRender {
    return _isCustomRender;
}

+ (void)setIsCustomRender:(BOOL)isCustomRender {
    _isCustomRender = isCustomRender;
}

// HJC: 初始化适配器，配置 SDK
- (instancetype)initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        // HJC: 检查是否已初始化，避免重复初始化
        if (![[ATAPI sharedInstance] initFlagForNetwork:@"AMPS"]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:@"AMPS"];
            [[ATAPI sharedInstance] setVersion:[AMPSAdSDKManager sdkVersion] forNetwork:@"AMPS"];
            
            // HJC: 配置个性化推荐
            AMPSAdSDKConfiguration *config = [[AMPSAdSDKConfiguration alloc] init];
            if ([[ATAPI sharedInstance] getPersonalizedAdState] == 2) {
                config.recommend = kAMPSPersonalizedRecommendStateClose;
            } else {
                config.recommend = kAMPSPersonalizedRecommendStateOpen;
            }
            
            // HJC: 异步初始化 SDK
            NSString *appId = serverInfo[@"appid"];
            if (appId && appId.length > 0) {
                [[AMPSAdSDKManager sharedInstance] startAsyncWithAppId:appId configuration:config results:^(AMPSAdSDKInitStatus statusResult) {
                    // HJC: 初始化状态回调处理
                }];
            }
        }
    }
    return self;
}

// HJC: 加载广告
- (void)loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    // HJC: 检查渲染类型，1 表示自渲染，其他表示模板渲染
    BOOL isCustomRender = [serverInfo[@"renderType"] integerValue] == 1;
    ATAMPSNativeCustomAdapter.isCustomRender = isCustomRender;
    
    // HJC: 根据渲染类型创建对应的 CustomEvent
    if (isCustomRender) {
        _unifiedCustomEvent = [[ATAMPSUnifiedNativeCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _unifiedCustomEvent.requestCompletionBlock = completion;
    } else {
        _expressCustomEvent = [[ATAMPSNativeExpressCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _expressCustomEvent.requestCompletionBlock = completion;
    }
    
    // HJC: 1. 检查 serverInfo 有效性
    if (!serverInfo || ![serverInfo isKindOfClass:[NSDictionary class]]) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load native.", NSLocalizedFailureReasonErrorKey:@"Invalid server info."}];
        if (isCustomRender) {
            [_unifiedCustomEvent trackNativeAdLoadFailed:error];
        } else {
            [_expressCustomEvent trackNativeAdLoadFailed:error];
        }
        return;
    }
    
    // HJC: 2. 安全获取 unitid
    NSString *unitID = [serverInfo objectForKey:@"unitid"];
    if (!unitID || unitID.length == 0) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load native.", NSLocalizedFailureReasonErrorKey:@"UnitID missing in server info."}];
        if (isCustomRender) {
            [_unifiedCustomEvent trackNativeAdLoadFailed:error];
        } else {
            [_expressCustomEvent trackNativeAdLoadFailed:error];
        }
        return;
    }
    
    // HJC: 3. 获取超时时间，默认 5000 毫秒
    NSTimeInterval tolerateTimeout = [serverInfo[@"timeout"] integerValue] > 0 ? [serverInfo[@"timeout"] integerValue] : 5000;
    
    // HJC: 4. 获取广告尺寸，默认屏幕宽度减去 30，高度 200
    CGSize size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 30.0f, 200.0f);
    if ([localInfo[kATExtraInfoNativeAdSizeKey] respondsToSelector:@selector(CGSizeValue)]) {
        size = [localInfo[kATExtraInfoNativeAdSizeKey] CGSizeValue];
    }
    
    // HJC: 5. 检查是否有竞价请求
    ATAMPSCustomBiddingRequest *request = [[ATAMPSC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:unitID];
    
    if (request) {
        // HJC: 有竞价请求，直接使用竞价结果
        if (request.assets && request.assets.count > 0) {
            // HJC: 竞价成功，使用竞价返回的 assets
            completion(request.assets, nil);
            // HJC: 竞价成功，assets 中已经包含了正确的 customEvent 和 customObject
        } else {
            // HJC: 竞价失败
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load native.", NSLocalizedFailureReasonErrorKey:@"It took too long to load placement strategy."}];
            if (isCustomRender) {
                [_unifiedCustomEvent trackNativeAdLoadFailed:error];
            } else {
                [_expressCustomEvent trackNativeAdLoadFailed:error];
            }
        }
        [[ATAMPSC2SBiddingRequestManager sharedInstance] removeRequestItemWithUnitID:unitID];
    } else {
        // HJC: 普通请求，创建广告对象并加载
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isCustomRender) {
                // HJC: 自渲染广告
                AMPSAdConfiguration *adConfig = [[AMPSAdConfiguration alloc] init];
                adConfig.spaceId = unitID;
                adConfig.timeoutInterval = tolerateTimeout;
                
                self.unifiedNativeManager = [[AMPSUnifiedNativeManager alloc] initWithAdConfiguration:adConfig];
                self.unifiedNativeManager.delegate = self.unifiedCustomEvent;
                [self.unifiedNativeManager loadUnifiedNativeManager];
            } else {
                // HJC: 模板广告
                AMPSAdConfiguration *adConfig = [[AMPSAdConfiguration alloc] init];
                adConfig.spaceId = unitID;
                adConfig.adSize = size;
                adConfig.timeoutInterval = tolerateTimeout;
                
                self.nativeExpressManager = [[AMPSNativeExpressManager alloc] initWithAdConfiguration:adConfig];
                self.nativeExpressManager.delegate = self.expressCustomEvent;
                [self.nativeExpressManager loadNativeExpressManager];
            }
        });
    }
}

// HJC: 检查广告是否准备好
+ (BOOL)adReadyWithCustomObject:(nonnull id)customObject info:(nonnull NSDictionary *)info {
    if ([customObject isKindOfClass:[AMPSNativeExpressView class]]) {
        // HJC: 模板广告视图，检查是否准备好
        AMPSNativeExpressView *view = (AMPSNativeExpressView *)customObject;
        return [view isReadyAd];
    } else if ([customObject isKindOfClass:[AMPSUnifiedNativeView class]]) {
        // HJC: 自渲染广告视图
        return YES;
    } else if ([customObject isKindOfClass:[AMPSNativeExpressManager class]]) {
        // HJC: 模板广告管理器
        AMPSNativeExpressManager *manager = (AMPSNativeExpressManager *)customObject;
        return manager.viewsArray.count > 0;
    } else if ([customObject isKindOfClass:[AMPSUnifiedNativeManager class]]) {
        // HJC: 自渲染广告管理器
        AMPSUnifiedNativeManager *manager = (AMPSUnifiedNativeManager *)customObject;
        return manager.adArray.count > 0;
    }
    return NO;
}

// HJC: 检查是否支持该广告类型
+ (BOOL)isSupportAdType:(nonnull ATUnitGroupModel *)unitGroupModel {
    return YES;
}

// HJC: 返回渲染器类
+ (Class)rendererClass {
    return [ATAMPSNativeCustomRenderer class];
}

// HJC: 竞价请求
+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    // HJC: 检查 SDK 是否初始化
    if (![[ATAPI sharedInstance] initFlagForNetwork:@"AMPS"]) {
        [[ATAPI sharedInstance] setInitFlagForNetwork:@"AMPS"];
        [[ATAPI sharedInstance] setVersion:[AMPSAdSDKManager sdkVersion] forNetwork:@"AMPS"];
        
        AMPSAdSDKConfiguration *config = [[AMPSAdSDKConfiguration alloc] init];
        if ([[ATAPI sharedInstance] getPersonalizedAdState] == 2) {
            config.recommend = kAMPSPersonalizedRecommendStateClose;
        } else {
            config.recommend = kAMPSPersonalizedRecommendStateOpen;
        }
        
        NSString *appId = info[@"appid"];
        if (appId && appId.length > 0) {
            [[AMPSAdSDKManager sharedInstance] startAsyncWithAppId:appId configuration:config results:^(AMPSAdSDKInitStatus statusResult) {
                // HJC: 初始化状态回调
            }];
        }
    }
    
    // HJC: 检查渲染类型，创建对应的 CustomEvent
    BOOL isCustomRenderBid = [info[@"renderType"] integerValue] == 1;
    id customEvent = nil;
    if (isCustomRenderBid) {
        ATAMPSUnifiedNativeCustomEvent *unifiedEvent = [[ATAMPSUnifiedNativeCustomEvent alloc] initWithInfo:info localInfo:info];
        unifiedEvent.isC2SBiding = YES;
        unifiedEvent.spaceId = info[@"unitid"];
        customEvent = unifiedEvent;
    } else {
        ATAMPSNativeExpressCustomEvent *expressEvent = [[ATAMPSNativeExpressCustomEvent alloc] initWithInfo:info localInfo:info];
        expressEvent.isC2SBiding = YES;
        expressEvent.spaceId = info[@"unitid"];
        customEvent = expressEvent;
    }
    NSTimeInterval tolerateTimeout = [info[@"timeout"] integerValue] > 0 ? [info[@"timeout"] integerValue] : 5000;
    
    ATAMPSC2SBiddingRequestManager *biddingManage = [ATAMPSC2SBiddingRequestManager sharedInstance];
    ATAMPSCustomBiddingRequest *request = [ATAMPSCustomBiddingRequest new];
    request.unitGroup = unitGroupModel;
    request.placementID = placementModel.placementID;
    request.bidCompletion = completion;
    request.unitID = info[@"unitid"];
    request.extraInfo = info;
    request.adType = AMPSAdFormatNative;
    request.customEvent = customEvent;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isCustomRenderBid) {
            // HJC: 自渲染广告竞价
            AMPSAdConfiguration *adConfig = [[AMPSAdConfiguration alloc] init];
            adConfig.spaceId = info[@"unitid"];
            adConfig.timeoutInterval = tolerateTimeout;
            
            AMPSUnifiedNativeManager *unifiedManager = [[AMPSUnifiedNativeManager alloc] initWithAdConfiguration:adConfig];
            request.customObject = unifiedManager;
            [biddingManage startWithRequestItem:request];
            unifiedManager.delegate = (ATAMPSUnifiedNativeCustomEvent *)customEvent;
            [unifiedManager loadUnifiedNativeManager];
        } else {
            // HJC: 模板广告竞价
            CGSize size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 30.0f, 200.0f);
            if ([info[kATExtraInfoNativeAdSizeKey] respondsToSelector:@selector(CGSizeValue)]) {
                size = [info[kATExtraInfoNativeAdSizeKey] CGSizeValue];
            }
            
            AMPSAdConfiguration *adConfig = [[AMPSAdConfiguration alloc] init];
            adConfig.spaceId = info[@"unitid"];
            adConfig.adSize = size;
            adConfig.timeoutInterval = tolerateTimeout;
            
            AMPSNativeExpressManager *expressManager = [[AMPSNativeExpressManager alloc] initWithAdConfiguration:adConfig];
            request.customObject = expressManager;
            [biddingManage startWithRequestItem:request];
            expressManager.delegate = (ATAMPSNativeExpressCustomEvent *)customEvent;
            [expressManager loadNativeExpressManager];
        }
    });
}

// HJC: 发送竞价成功通知
+ (void)sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    NSMutableDictionary *winInfo = [[NSMutableDictionary alloc] init];
    
    // HJC: 处理不同类型的对象
    id<AMPSBiddingProtocol> biddingObject = nil;
    
    if ([customObject isKindOfClass:[AMPSNativeExpressView class]]) {
        // HJC: 模板广告视图
        biddingObject = (id<AMPSBiddingProtocol>)customObject;
    } else if ([customObject isKindOfClass:[AMPSUnifiedNativeView class]]) {
        // HJC: 自渲染广告视图
        biddingObject = (id<AMPSBiddingProtocol>)customObject;
    } else if ([customObject isKindOfClass:[AMPSNativeExpressManager class]]) {
        // HJC: 模板广告管理器，需要从 viewsArray 中获取视图
        AMPSNativeExpressManager *manager = (AMPSNativeExpressManager *)customObject;
        if (manager.viewsArray.count > 0) {
            biddingObject = (id<AMPSBiddingProtocol>)manager.viewsArray.firstObject;
        }
    } else if ([customObject isKindOfClass:[AMPSUnifiedNativeManager class]]) {
        // HJC: 自渲染广告管理器，无法直接获取 eCPM，需要创建视图
        // 这种情况不应该发生，因为在竞价时已经创建了视图
        return;
    }
    
    if (biddingObject && [biddingObject conformsToProtocol:@protocol(AMPSBiddingProtocol)]) {
        NSInteger eCPM = [biddingObject eCPM];
        [winInfo setObject:[NSString stringWithFormat:@"%ld", (long)eCPM] forKey:@"AMPS_WIN_PRICE"];
        [winInfo setObject:@"9999" forKey:@"AMPS_WIN_ADNID"];
        
        if (price && price.length > 0) {
            [winInfo setObject:price forKey:@"AMPS_HIGHRST_LOSS_PRICE"];
        } else {
            [winInfo setObject:@"0" forKey:@"AMPS_HIGHRST_LOSS_PRICE"];
        }
        
        [biddingObject sendWinNotificationWithInfo:winInfo];
    }
}

// HJC: 发送竞价失败通知
+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    NSMutableDictionary *lossInfo = [[NSMutableDictionary alloc] init];
    
    // HJC: 处理不同类型的对象
    id<AMPSBiddingProtocol> biddingObject = nil;
    
    if ([customObject isKindOfClass:[AMPSNativeExpressView class]]) {
        // HJC: 模板广告视图
        biddingObject = (id<AMPSBiddingProtocol>)customObject;
    } else if ([customObject isKindOfClass:[AMPSUnifiedNativeView class]]) {
        // HJC: 自渲染广告视图
        biddingObject = (id<AMPSBiddingProtocol>)customObject;
    } else if ([customObject isKindOfClass:[AMPSNativeExpressManager class]]) {
        // HJC: 模板广告管理器，需要从 viewsArray 中获取视图
        AMPSNativeExpressManager *manager = (AMPSNativeExpressManager *)customObject;
        if (manager.viewsArray.count > 0) {
            biddingObject = (id<AMPSBiddingProtocol>)manager.viewsArray.firstObject;
        }
    } else if ([customObject isKindOfClass:[AMPSUnifiedNativeManager class]]) {
        // HJC: 自渲染广告管理器，无法直接获取 eCPM
        return;
    }
    
    if (biddingObject && [biddingObject conformsToProtocol:@protocol(AMPSBiddingProtocol)]) {
        if (price && price.length > 0) {
            [lossInfo setObject:price forKey:@"AMPS_WIN_PRICE"];
        } else {
            [lossInfo setObject:@"0" forKey:@"AMPS_WIN_PRICE"];
        }
        [lossInfo setObject:@"9999" forKey:@"AMPS_WIN_ADNID"];
        
        if (lossType == ATBiddingLossWithLowPriceInNormal || lossType == ATBiddingLossWithLowPriceInHB) {
            [lossInfo setObject:@"1" forKey:@"AMPS_LOSS_REASON"];
        } else if (lossType == ATBiddingLossWithBiddingTimeOut) {
            [lossInfo setObject:@"2" forKey:@"AMPS_LOSS_REASON"];
        } else {
            [lossInfo setObject:@"999" forKey:@"AMPS_LOSS_REASON"];
        }
        
        [biddingObject sendLossNotificationWithInfo:lossInfo];
    }
}

@end

