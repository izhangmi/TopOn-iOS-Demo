//
//  TGNativeAdController.m
//  AncloudCam
//
//  Created by Darren Xia on 2025/5/9.
//  Copyright © 2025 eye. All rights reserved.
//

#import "TGNativeAdController.h"
#import <Masonry/Masonry.h>
#import <AnyThinkSDK/AnyThinkSDK.h>
#import "TGToponNativeAdTool.h"

#define TGShowNativeInfo     1

@interface TGNativeAdController ()<ATAdLoadingDelegate,ATNativeADDelegate>

@property (nonatomic, strong) UIView *nativeView;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, assign) CGSize nativeSize;

@end

@implementation TGNativeAdController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor redColor];
    
    UIButton *nativeButton = [[UIButton alloc] init];
    nativeButton.backgroundColor = [UIColor blueColor];
    nativeButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [nativeButton setTitle:@"加载原生广告" forState:UIControlStateNormal];
    [nativeButton addTarget:self action:@selector(loadNativeAd) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nativeButton];
    [nativeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(100);
        make.center.mas_equalTo(self.view);
    }];
    
    self.nativeView = [[UIView alloc] init];
    self.nativeView.layer.masksToBounds = YES;
    self.nativeView.layer.cornerRadius = TG_RelativeHeightX(20);
    self.nativeView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.nativeView];
    [self.nativeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(DeviceListBottomNativeAdHeight);
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-TG_RelativeHeightX(20));
        make.leading.mas_equalTo(self.view.mas_leading).mas_offset(TG_RelativeWidthX(20));
        make.trailing.mas_equalTo(self.view.mas_trailing).mas_offset(-TG_RelativeWidthX(20));
    }];
}

- (void)loadNativeAd{
    self.containerView = self.nativeView;
    self.nativeSize = self.nativeView.frame.size;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //[ATAPI setLogEnabled:YES];
        //[ATAPI integrationChecking];
        [[ATAPI sharedInstance] startWithAppID:kTopOnAppID appKey:kTopOnAppKey error:nil];
        [ATAPI sharedInstance].preferredAdLogoPosition = ATAdLogoPositionBottomRightCorner;
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        /*
        // 设置测试竞价的idfa，例如Meta广告测试设备等
        NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        [ATAPI setHeaderBiddingTestModeWithDeviceID:idfa];
        // 注意事项：调用该代码，广告请求会使用服务器下发的广告配置，如果测试完成，需要使用自己的广告配置，需要把这段去掉。qqqqqqqqqqqqqq
        [ATAPI setDebuggerConfig:^(ATDebuggerConfig *debuggerConfig) {
            // device idfa
            debuggerConfig.deviceIdfaStr = idfa;
            // 指定测试的广告平台
            //debuggerConfig.netWorkType = ATAdNetWorkKuaiShouType;
            //debuggerConfig.kuaiShou_bannerAdType = ATKuaiShouBannerAdDefaultType;
            
            //debuggerConfig.netWorkType = ATAdNetWorkBaiduType;
            //debuggerConfig.baidu_bannerAdType = ATBaiduBannerAdDefaultType;
            
            //debuggerConfig.netWorkType = ATAdNetWorkGDTType;
            //debuggerConfig.gdt_bannerAdType = ATGDTBannerAdDefaultType;
            
            //debuggerConfig.netWorkType = ATAdNetWorkCSJType;
            //debuggerConfig.csj_bannerAdType = ATCSJBannerAdDefaultType;
            
            //debuggerConfig.netWorkType = ATAdNetWorkPangleType;
            //debuggerConfig.pangle_bannerAdType = ATPangleBannerAdDefaultType;
            
            //debuggerConfig.netWorkType = ATAdNetWorkAdmobType;
            //debuggerConfig.adMob_bannerAdType = ATAdMobBannerAdDefaultType;
        }];
         */
        // 设置请求的广告尺寸大小，请保持跟后台配置的比例相近
        NSDictionary *extra = @{kATExtraInfoNativeAdSizeKey:[NSValue valueWithCGSize:self.nativeSize], kATExtraNativeImageSizeKey:kATExtraNativeImageSize1280_720};
        [[ATAdManager sharedManager] loadADWithPlacementID:TG_ToponNativeUnitId extra:extra delegate:self];
    });
    NSLog(@"TGAdvertManager TopOn Native广告开始加载");
}

- (void)showNativeAd{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ATAdManager sharedManager] entryNativeScenarioWithPlacementID:TG_ToponNativeUnitId scene:@""];
        if ([[ATAdManager sharedManager] nativeAdReadyForPlacementID:TG_ToponNativeUnitId]) {
            ATNativeAdOffer *offer = [[ATAdManager sharedManager] getNativeAdOfferWithPlacementID:TG_ToponNativeUnitId scene:@""];
            [TGToponNativeAdTool handleNativeRenderWithOffer:offer containerView:self.containerView nativeSize:self.nativeSize delegate:self];
        }
    });
    NSLog(@"TGAdvertManager TopOn Native广告准备展示");
}

- (void)removeNativeAd{
    NSLog(@"TGAdvertManager TopOn Native广告准备移除");
    self.nativeSize = CGSizeMake(355, 90);
    NSArray *subviews = [self.containerView.subviews copy];
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
    self.containerView = nil;
    [[ATAdManager sharedManager] customCloseADEventWithPlacementID:TG_ToponNativeUnitId];
}

// 发起广告源广告请求：AD Request offer with network info:
// 广告源广告请求成功：handler success Request offer with network info:
// 广告源广告请求失败：handler fail Request offer with network info:
// 得知展示广告的信息：Impression with ad info:
// 得知关闭广告的信息：Close with ad info:
// Callback when the successful loading of the ad
- (void)didFinishLoadingADWithPlacementID:(NSString *)placementID{
    NSLog(@"TGAdvertManager TopOn Native广告位广告加载成功：%@", placementID);
    [self showNativeAd];
}

// Callback of ad loading failure
- (void)didFailToLoadADWithPlacementID:(NSString *)placementID error:(NSError *)error{
#if TGShowNativeInfo
    NSLog(@"TGAdvertManager TopOn Native广告位广告加载失败：%@，%@", placementID, error);
#else
    NSLog(@"TGAdvertManager TopOn Native广告位广告加载失败：%@", placementID);
#endif
    [self removeNativeAd];
}

// Ad start load
- (void)didStartLoadingADSourceWithPlacementID:(NSString *)placementID extra:(NSDictionary *)extra{
    NSString *adSourceId = extra[@"adsource_id"];
#if TGShowNativeInfo
     NSLog(@"TGAdvertManager TopOn Native广告位广告源开始加载广告：%@，%@，%@", placementID, adSourceId, extra);
#else
    NSLog(@"TGAdvertManager TopOn Native广告位广告源开始加载广告：%@，%@", placementID, adSourceId);
#endif
}

// Ad load success
- (void)didFinishLoadingADSourceWithPlacementID:(NSString *)placementID extra:(NSDictionary *)extra{
    NSString *adSourceId = extra[@"adsource_id"];
#if TGShowNativeInfo
    NSLog(@"TGAdvertManager TopOn Native广告位广告源广告加载成功：%@，%@，%@", placementID, adSourceId, extra);
#else
    NSLog(@"TGAdvertManager TopOn Native广告位广告源广告加载成功：%@，%@", placementID, adSourceId);
#endif
}

// Ad load fail
- (void)didFailToLoadADSourceWithPlacementID:(NSString *)placementID extra:(NSDictionary *)extra error:(NSError *)error{
    NSString *adSourceId = extra[@"adsource_id"];
#if TGShowNativeInfo
    NSLog(@"TGAdvertManager TopOn Native广告位广告源广告加载失败：%@，%@，%@，%@", placementID, adSourceId, extra, error);
#else
    NSLog(@"TGAdvertManager TopOn Native广告位广告源广告加载失败：%@，%@", placementID, adSourceId);
#endif
}

// Ad start bidding
- (void)didStartBiddingADSourceWithPlacementID:(NSString *)placementID extra:(NSDictionary *)extra{
    NSString *adSourceId = extra[@"adsource_id"];
#if TGShowNativeInfo
    NSLog(@"TGAdvertManager TopOn Native广告位广告源竞价广告开始竞价：%@，%@，%@", placementID, adSourceId, extra);
#else
    NSLog(@"TGAdvertManager TopOn Native广告位广告源竞价广告开始竞价：%@，%@", placementID, adSourceId);
#endif
}

// Ad bidding success
- (void)didFinishBiddingADSourceWithPlacementID:(NSString *)placementID extra:(NSDictionary *)extra{
    NSString *adSourceId = extra[@"adsource_id"];
#if TGShowNativeInfo
    NSLog(@"TGAdvertManager TopOn Native广告位广告源竞价广告竞价成功：%@，%@，%@", placementID, adSourceId, extra);
#else
    NSLog(@"TGAdvertManager TopOn Native广告位广告源竞价广告竞价成功：%@，%@", placementID, adSourceId);
#endif
}

// Ad bidding fail
- (void)didFailBiddingADSourceWithPlacementID:(NSString *)placementID extra:(NSDictionary *)extra error:(NSError *)error{
    NSString *adSourceId = extra[@"adsource_id"];
#if TGShowNativeInfo
    NSLog(@"TGAdvertManager TopOn Native广告位广告源竞价广告竞价失败：%@，%@，%@，%@", placementID, adSourceId, extra, error);
#else
    NSLog(@"TGAdvertManager TopOn Native广告位广告源竞价广告竞价失败：%@，%@", placementID, adSourceId);
#endif
}

#pragma mark -ATNativeADDelegate
/// Native ads displayed successfully
- (void)didShowNativeAdInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra{
    NSString *adSourceId = extra[@"adsource_id"];
#if TGShowNativeInfo
    NSLog(@"TGAdvertManager TopOn Native广告展示成功：%@，%@，%@", placementID, adSourceId, extra);
#else
    NSLog(@"TGAdvertManager TopOn Native广告展示成功：%@，%@", placementID, adSourceId);
#endif
}

/// Native ad click
- (void)didClickNativeAdInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra{
    NSString *adSourceId = extra[@"adsource_id"];
#if TGShowNativeInfo
    NSLog(@"TGAdvertManager TopOn Native广告点击：%@，%@，%@", placementID, adSourceId, extra);
#else
    NSLog(@"TGAdvertManager TopOn Native广告点击：%@，%@", placementID, adSourceId);
#endif
}

/// Native video ad starts playing
- (void)didStartPlayingVideoInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra{
    NSString *adSourceId = extra[@"adsource_id"];
#if TGShowNativeInfo
    NSLog(@"TGAdvertManager TopOn Native视频广告开始播放：%@，%@，%@", placementID, adSourceId, extra);
#else
    NSLog(@"TGAdvertManager TopOn Native视频广告开始播放：%@，%@", placementID, adSourceId);
#endif
}

/// Native video ad ends playing
- (void)didEndPlayingVideoInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra{
    NSString *adSourceId = extra[@"adsource_id"];
#if TGShowNativeInfo
    NSLog(@"TGAdvertManager TopOn Native视频广告播放结束：%@，%@，%@", placementID, adSourceId, extra);
#else
    NSLog(@"TGAdvertManager TopOn Native视频广告播放结束：%@，%@", placementID, adSourceId);
#endif
}

/// Native ad close button cliecked
- (void)didTapCloseButtonInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra{
    NSString *adSourceId = extra[@"adsource_id"];
#if TGShowNativeInfo
    NSLog(@"TGAdvertManager TopOn Native广告关闭：%@，%@，%@", placementID, adSourceId, extra);
#else
    NSLog(@"TGAdvertManager TopOn Native广告关闭：%@，%@", placementID, adSourceId);
#endif
    [self removeNativeAd];
}

/// Native ads click to close the details page
/// v5.7.47+
- (void)didCloseDetailInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra{
    NSString *adSourceId = extra[@"adsource_id"];
#if TGShowNativeInfo
    NSLog(@"TGAdvertManager TopOn Native广告关闭详情页：%@，%@，%@", placementID, adSourceId, extra);
#else
    NSLog(@"TGAdvertManager TopOn Native广告关闭详情页：%@，%@", placementID, adSourceId);
#endif
}

/// Whether the click jump of Native ads is in the form of Deeplink
/// currently only returns for TopOn Adx ads
- (void)didDeepLinkOrJumpInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra result:(BOOL)success{
    NSString *adSourceId = extra[@"adsource_id"];
#if TGShowNativeInfo
    NSLog(@"TGAdvertManager TopOn Native广告是否为Deeplink跳转：%@，%@，%@，%d", placementID, adSourceId, extra, success);
#else
    NSLog(@"TGAdvertManager TopOn Native广告是否为Deeplink跳转：%@，%@，%d", placementID, adSourceId, success);
#endif
}

/// Native enters full screen video ads, only for Nend
- (void)didEnterFullScreenVideoInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra{
    NSString *adSourceId = extra[@"adsource_id"];
#if TGShowNativeInfo
    NSLog(@"TGAdvertManager TopOn Native广告进入全屏：%@，%@，%@", placementID, adSourceId, extra);
#else
    NSLog(@"TGAdvertManager TopOn Native广告进入全屏：%@，%@", placementID, adSourceId);
#endif
}

/// Native exit full screen video ad, only for Nend
- (void)didExitFullScreenVideoInAdView:(ATNativeADView *)adView placementID:(NSString *)placementID extra:(NSDictionary *)extra{
    NSString *adSourceId = extra[@"adsource_id"];
#if TGShowNativeInfo
    NSLog(@"TGAdvertManager TopOn Native广告退出全屏：%@，%@，%@", placementID, adSourceId, extra);
#else
    NSLog(@"TGAdvertManager TopOn Native广告退出全屏：%@，%@", placementID, adSourceId);
#endif
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
