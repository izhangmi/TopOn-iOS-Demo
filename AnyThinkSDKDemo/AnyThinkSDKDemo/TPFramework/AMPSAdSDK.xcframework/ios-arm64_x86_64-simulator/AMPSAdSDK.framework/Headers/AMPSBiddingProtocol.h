//
//  AMPSBiddingProtocol.h
//  AMPSAdSDK
//
//  Created by Cookie on 2024/11/27.
//

#import <Foundation/Foundation.h>
#import <AMPSAdSDK/AMPSBaseProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AMPSBiddingProtocol <AMPSBaseProtocol>

/**
 本次广告价格，单位分
 */
- (NSInteger)eCPM;

/**
 @pararm winInfo 竞胜信息，字典类型
 AMPS_WIN_PRICE ：竞胜价格 (单位: 分)，必填
 AMPS_WIN_ADNID ：竞胜渠道ID，必填
 AMPS_HIGHRST_LOSS_PRICE ：失败渠道中最高价格，必填
 AMPS_EXPECT_PRICE ：期望价格，选填
 */
- (void)sendWinNotificationWithInfo:(NSDictionary *)winInfo;

/**
 @pararm lossInfo 竞败信息，字典类型
 AMPS_WIN_PRICE ：竞胜价格 (单位: 分)，必填
 AMPS_WIN_ADNID ：竞胜渠道ID，必填
 AMPS_HIGHRST_LOSS_PRICE ：失败渠道中最高价格，必填
 AMPS_LOSS_REASON ：失败原因，必填
 AMPS_EXPECT_PRICE ：期望价格，选填
 */
- (void)sendLossNotificationWithInfo:(NSDictionary *)lossInfo;

@end

NS_ASSUME_NONNULL_END
