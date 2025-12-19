//
//  ATAMPSCustomNativeAdapter.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//
// HJC: Native 广告适配器实现文件

#import "ATAMPSCustomNativeAdapter.h"
#import "../Base/ATAMPSCustomInitAdapter.h"
#import "ATAMPSCustomNativeExpressDelegate.h"
#import "ATAMPSCustomNativeUnifiedDelegate.h"
#import "ATAMPSCustomNativeRenderer.h"
#import "../ATAMPSCustomBiddingRequest.h"
#import "../ATAMPSC2SBiddingRequestManager.h"
#import <AMPSAdSDK/AMPSAdSDK.h>

// HJC: ATAMPS Native 广告适配器实现
@interface ATAMPSCustomNativeAdapter ()

@property (nonatomic, strong) ATAMPSCustomNativeExpressDelegate *expressDelegate;
@property (nonatomic, strong) ATAMPSCustomNativeUnifiedDelegate *unifiedDelegate;
@property (nonatomic, strong) AMPSNativeExpressManager *nativeExpressManager;
@property (nonatomic, strong) AMPSUnifiedNativeManager *unifiedNativeManager;

@end

@implementation ATAMPSCustomNativeAdapter

#pragma mark - Ad load
// HJC: 实现广告加载方法
- (void)loadADWithArgument:(ATAdMediationArgument *)argument {
    // AAAAA: 这是非竞价模式（普通加载）
    // 竞价/非竞价是在 TopOn 后台配置的：
    // - 非竞价：TopOn SDK 会调用此方法 loadADWithArgument:
    // - 竞价（C2S）：TopOn SDK 会调用 bidRequestWithPlacementModel:unitGroupModel:info:completion:
    // 如需测试竞价，请在 TopOn 后台将广告源配置为竞价模式
    NSLog(@"HJC测试: ATAMPSCustomNativeAdapter loadADWithArgument 被调用（这是非竞价模式）");
    
    NSDictionary *serverInfo = argument.serverContentDic;
    NSDictionary *localInfo = argument.localInfoDic ?: @{};
    
    NSLog(@"HJC测试: 加载广告时的 serverInfo = %@", serverInfo);
    
    // HJC: 检查 serverInfo 有效性
    if (!serverInfo || ![serverInfo isKindOfClass:[NSDictionary class]]) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain 
                                             code:ATAdErrorCodeThirdPartySDKNotImportedProperly 
                                         userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load native.", 
                                                   NSLocalizedFailureReasonErrorKey:@"Invalid server info."}];
        if (self.adStatusBridge) {
            [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
        }
        return;
    }
    
    // AAAAA: 测试原生广告渲染类型（手动修改测试用）
    // renderType = 0 或不设置：模板渲染（Native Express）
    // renderType = 1：自渲染（Native Unified）
    // 正常情况下从 serverInfo[@"renderType"] 获取，如果需要在代码中强制测试，可以取消下面注释
    // NSMutableDictionary *testServerInfo = [serverInfo mutableCopy];
    // testServerInfo[@"renderType"] = @(0);  // 0=模板渲染，1=自渲染
    // serverInfo = testServerInfo;
    BOOL isCustomRender = [serverInfo[@"renderType"] integerValue] == 1;
    
    NSString *unitID = serverInfo[@"unitid"];
    if (!unitID || unitID.length == 0) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain 
                                             code:ATAdErrorCodeThirdPartySDKNotImportedProperly 
                                         userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load native.", 
                                                   NSLocalizedFailureReasonErrorKey:@"UnitID missing in server info."}];
        if (self.adStatusBridge) {
            [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
        }
        return;
    }
    
    // HJC: 获取超时时间，默认 5000 毫秒
    NSTimeInterval tolerateTimeout = [serverInfo[@"timeout"] integerValue] > 0 ? [serverInfo[@"timeout"] integerValue] : 5000;
    
    // HJC: 获取广告尺寸，默认屏幕宽度减去 30，高度 200
    CGSize size = argument.nativeSize.width > 0 && argument.nativeSize.height > 0 
        ? argument.nativeSize 
        : CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 30.0f, 200.0f);
    if ([localInfo[kATExtraInfoNativeAdSizeKey] respondsToSelector:@selector(CGSizeValue)]) {
        size = [localInfo[kATExtraInfoNativeAdSizeKey] CGSizeValue];
    }
    
    // HJC: 根据渲染类型创建对应的 Delegate 并设置 adStatusBridge
    if (isCustomRender) {
        // HJC: 自渲染广告
        self.unifiedDelegate = [[ATAMPSCustomNativeUnifiedDelegate alloc] initWithInfo:serverInfo localInfo:localInfo];
        self.unifiedDelegate.adStatusBridge = self.adStatusBridge;
    } else {
        // HJC: 模板广告
        self.expressDelegate = [[ATAMPSCustomNativeExpressDelegate alloc] initWithInfo:serverInfo localInfo:localInfo];
        self.expressDelegate.adStatusBridge = self.adStatusBridge;
    }
    
    // HJC: 创建广告对象并加载
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isCustomRender) {
            // HJC: 自渲染广告
            AMPSAdConfiguration *adConfig = [[AMPSAdConfiguration alloc] init];
            adConfig.spaceId = unitID;
            adConfig.timeoutInterval = tolerateTimeout;
            
            self.unifiedNativeManager = [[AMPSUnifiedNativeManager alloc] initWithAdConfiguration:adConfig];
            self.unifiedNativeManager.delegate = self.unifiedDelegate;
            // HJC: 保存 manager 引用到 delegate，以便在创建 NativeObject 时使用
            self.unifiedDelegate.unifiedNativeManager = self.unifiedNativeManager;
            [self.unifiedNativeManager loadUnifiedNativeManager];
        } else {
            // HJC: 模板广告
            AMPSAdConfiguration *adConfig = [[AMPSAdConfiguration alloc] init];
            adConfig.spaceId = unitID;
            adConfig.adSize = size;
            adConfig.timeoutInterval = tolerateTimeout;
            
            self.nativeExpressManager = [[AMPSNativeExpressManager alloc] initWithAdConfiguration:adConfig];
            self.nativeExpressManager.delegate = self.expressDelegate;
            // HJC: 保存 manager 引用到 delegate，以便在创建 NativeObject 时使用
            self.expressDelegate.nativeExpressManager = self.nativeExpressManager;
            [self.nativeExpressManager loadNativeExpressManager];
        }
    });
}

// HJC: 返回渲染器类
+ (Class)rendererClass {
    return [ATAMPSCustomNativeRenderer class];
}

#pragma mark - C2S Bidding
// HJC: 按照 C2S 竞价文档 https://help.takuad.com/docs/9IQVOUk5，实现竞价请求类方法
+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel 
                       unitGroupModel:(ATUnitGroupModel*)unitGroupModel 
                                 info:(NSDictionary*)info 
                           completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    NSLog(@"HJC测试: ATAMPSCustomNativeAdapter bidRequestWithPlacementModel 被调用（这是 C2S 竞价模式）");
    
    // AAAAA: 测试原生广告渲染类型（手动修改测试用，仅用于 C2S 竞价模式）
    // renderType = 0 或不设置：模板渲染（Native Express）
    // renderType = 1：自渲染（Native Unified）
    // 正常情况下从 info[@"renderType"] 获取，如果需要在代码中强制测试，可以取消下面注释
    // NSMutableDictionary *testInfo = [info mutableCopy];
    // testInfo[@"renderType"] = @(0);  // 0=模板渲染，1=自渲染
    // info = testInfo;
    BOOL isCustomRenderBid = [info[@"renderType"] integerValue] == 1;
    id customDelegate = nil;
    if (isCustomRenderBid) {
        ATAMPSCustomNativeUnifiedDelegate *unifiedDelegate = [[ATAMPSCustomNativeUnifiedDelegate alloc] initWithInfo:info localInfo:info];
        unifiedDelegate.isC2SBiding = YES;
        unifiedDelegate.spaceId = info[@"unitid"];
        customDelegate = unifiedDelegate;
    } else {
        ATAMPSCustomNativeExpressDelegate *expressDelegate = [[ATAMPSCustomNativeExpressDelegate alloc] initWithInfo:info localInfo:info];
        expressDelegate.isC2SBiding = YES;
        expressDelegate.spaceId = info[@"unitid"];
        customDelegate = expressDelegate;
    }
    NSTimeInterval tolerateTimeout = [info[@"timeout"] doubleValue] > 0 ? [info[@"timeout"] doubleValue] : 5000;
    
    ATAMPSC2SBiddingRequestManager *biddingManage = [ATAMPSC2SBiddingRequestManager sharedInstance];
    ATAMPSCustomBiddingRequest *request = [ATAMPSCustomBiddingRequest new];
    request.unitGroup = unitGroupModel;
    request.placementID = placementModel.placementID;
    request.bidCompletion = completion;
    request.unitID = info[@"unitid"];
    request.extraInfo = info;
    request.adType = ATAMPSAdFormatNative;
    request.customEvent = customDelegate;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isCustomRenderBid) {
            // HJC: 自渲染广告竞价
            AMPSAdConfiguration *adConfig = [[AMPSAdConfiguration alloc] init];
            adConfig.spaceId = info[@"unitid"];
            adConfig.timeoutInterval = tolerateTimeout;
            
            AMPSUnifiedNativeManager *unifiedManager = [[AMPSUnifiedNativeManager alloc] initWithAdConfiguration:adConfig];
            request.customObject = unifiedManager;
            [biddingManage startWithRequestItem:request];
            unifiedManager.delegate = (ATAMPSCustomNativeUnifiedDelegate *)customDelegate;
            ((ATAMPSCustomNativeUnifiedDelegate *)customDelegate).unifiedNativeManager = unifiedManager;
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
            expressManager.delegate = (ATAMPSCustomNativeExpressDelegate *)customDelegate;
            ((ATAMPSCustomNativeExpressDelegate *)customDelegate).nativeExpressManager = expressManager;
            [expressManager loadNativeExpressManager];
        }
    });
}

// HJC: 发送竞价成功通知
+ (void)sendWinnerNotifyWithCustomObject:(id)customObject 
                              secondPrice:(NSString*)price 
                                 userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
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
+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject 
                               lossType:(ATBiddingLossType)lossType 
                                winPrice:(nonnull NSString *)price 
                                userInfo:(NSDictionary *)userInfo {
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

#pragma mark - C2S Bidding Result
// HJC: 按照 C2S 竞价文档，实现 didReceiveBidResult: 处理竞价结果
- (void)didReceiveBidResult:(ATBidWinLossResult *)result {
    NSLog(@"HJC测试: didReceiveBidResult 被调用，bidResultType = %ld", (long)result.bidResultType);
    
    if (result.bidResultType == ATBidWinLossResultTypeWin) {
        NSLog(@"HJC测试: ✅ 竞价成功，winPrice = %@", result.winPrice);
    } else if (result.bidResultType == ATBidWinLossResultTypeLoss) {
        NSLog(@"HJC测试: ❌ 竞价失败，lossReasonType = %ld", (long)result.lossReasonType);
    }
}

@end

