//
//  ATBZCustomBiddingRequest.h
//  AnyThinkSDKDemo
//
//  Created by nie adhub on 2023/10/24.
//  Copyright © 2023 抽筋的灯. All rights reserved.
//

#import <AnyThinkNative/AnyThinkNative.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ESCAdFormat) {
    ESCAdFormatSplash = 0,
    ESCAdFormatNative = 1
};

@interface ATBZCustomBiddingRequest : NSObject

@property(nonatomic, strong) id customObject;

@property(nonatomic, strong) ATUnitGroupModel *unitGroup;

@property(nonatomic, strong) ATAdCustomEvent *customEvent;

@property (nonatomic, assign) NSTimeInterval tolerateTimeout;

@property(nonatomic, copy) NSString *unitID;

@property(nonatomic, copy) NSString *placementID;

@property(nonatomic, copy) NSString *publisherID;

@property(nonatomic, copy) NSDictionary *extraInfo;

@property(nonatomic, assign) ESCAdFormat adType;

@property(nonatomic, copy) void(^bidCompletion)(ATBidInfo * _Nullable bidInfo, NSError * _Nullable error);

@property(nonatomic, copy) NSArray<NSDictionary *> *assets;

@end

NS_ASSUME_NONNULL_END
