//
//  ATAMPSCustomSplashDelegate.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import "ATAMPSCustomSplashDelegate.h"
#import "../Bidding/ATAMPSCustomBiddingRequest.h"
#import "../Bidding/ATAMPSC2SBiddingRequestManager.h"
#import <AnyThinkSDK/NSDictionary+KAKit.h>

@implementation ATAMPSCustomSplashDelegate

- (instancetype)initWithInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    self = [super init];
    if (self) {
        self.serverInfo = serverInfo;
        self.localInfo = localInfo;
        self.spaceId = serverInfo[@"unitid"];
    }
    return self;
}

- (void)removeCustomViewAndsplashAd:(AMPSSplashAd *)splashAd {
    if (self.containerView) {
        [self.containerView removeFromSuperview];
    }
    if (splashAd) {
        [splashAd removeSplashAd];
    }
}

#pragma mark - AMPSSplashAdDelegate
- (void)ampsSplashAdLoadSuccess:(AMPSSplashAd *)splashAd {
    if (self.expireDate && [[NSDate date] timeIntervalSinceDate:self.expireDate] > 0) {
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AT has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"It took too long for AMPS to load splash."}];
        if (self.isC2SBiding) {
            ATAMPSCustomBiddingRequest *request = [[ATAMPSC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
            if (request.bidCompletion) {
                request.bidCompletion(nil, error);
            }
            self.isC2SBiding = NO;
        } else {
            if (self.adStatusBridge) {
                [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
            }
        }
        if (splashAd) {
            [splashAd removeSplashAd];
        }
        return;
    }
    
    NSInteger ecpm = [splashAd eCPM];
    NSString *priceStr = [NSString stringWithFormat:@"%ld", (long)ecpm];
    if ([priceStr doubleValue] < 0) {
        priceStr = @"0";
    }
    
    // C2S 竞价逻辑
    if (self.isC2SBiding) {
        ATAMPSCustomBiddingRequest *request = [[ATAMPSC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
        if (request) {
            ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID 
                                                      unitGroupUnitID:request.unitGroup.unitID 
                                                 adapterClassString:request.unitGroup.adapterClassString 
                                                               price:priceStr 
                                                           sortPrice:priceStr 
                                                         currencyType:ATBiddingCurrencyTypeCNYCents 
                                                   expirationInterval:request.unitGroup.bidTokenTime 
                                                         customObject:splashAd];
            bidInfo.networkFirmID = request.unitGroup.networkFirmID;
            if (request.bidCompletion) {
                request.bidCompletion(bidInfo, nil);
            }
        }
        self.isC2SBiding = NO;
    } else {
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
        [infoDic AT_setDictValue:priceStr key:ATAdSendC2SBidPriceKey];
        [infoDic AT_setDictValue:@(ATBiddingCurrencyTypeCNYCents) key:ATAdSendC2SCurrencyTypeKey];
        
        if (self.adStatusBridge) {
            [self.adStatusBridge atOnAdMetaLoadFinish:infoDic];
        }
    }
}

- (void)ampsSplashAdLoadFail:(AMPSSplashAd *)splashAd error:(NSError *)error {
    if (self.isC2SBiding) {
        ATAMPSCustomBiddingRequest *request = [[ATAMPSC2SBiddingRequestManager sharedInstance] getRequestItemWithUnitID:self.spaceId];
        if (request.bidCompletion) {
            request.bidCompletion(nil, error);
        }
        self.isC2SBiding = NO;
    } else {
        if (self.adStatusBridge) {
            [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
        }
    }
    
    if (splashAd) {
        [splashAd removeSplashAd];
    }
}

- (void)ampsSplashAdRenderSuccess:(AMPSSplashAd *)splashAd {
}

- (void)ampsSplashAdRenderFail:(AMPSSplashAd *)splashAd error:(NSError *)error {
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdLoadFailed:error adExtra:nil];
    }
}

- (void)ampsSplashAdShowFail:(AMPSSplashAd *)splashAd error:(NSError *)error {
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdShowFailed:error extra:nil];
    }
}

- (void)ampsSplashAdDidShow:(AMPSSplashAd *)splashAd {
}

// 曝光回调，用于统计上报
- (void)ampsSplashAdExposured:(AMPSSplashAd *)splashAd {
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdShow:nil];
    }
}

- (void)ampsSplashAdDidClick:(AMPSSplashAd *)splashAd {
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdClick:nil];
    }
}

- (void)ampsSplashAdDidClose:(AMPSSplashAd *)splashAd {
    [self removeCustomViewAndsplashAd:splashAd];
    if (self.adStatusBridge) {
        [self.adStatusBridge atOnAdClosed:nil];
    }
}

@end

