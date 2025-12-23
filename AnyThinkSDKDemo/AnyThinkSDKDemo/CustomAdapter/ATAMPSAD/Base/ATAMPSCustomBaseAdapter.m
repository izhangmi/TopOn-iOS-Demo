//
//  ATAMPSCustomBaseAdapter.m
//  AnyThinkSDKDemo
//
//  Created by imac on 12/16/2025.
//  Copyright © 2025 抽筋的灯. All rights reserved.
//

#import "ATAMPSCustomBaseAdapter.h"
#import "ATAMPSCustomInitAdapter.h"

@implementation ATAMPSCustomBaseAdapter

#pragma mark - adapter init class name define

- (Class)initializeClassName {
    NSLog(@"ATAMPSCustomBaseAdapter initializeClassName被调用，返回 ATAMPSCustomInitAdapter");
    return [ATAMPSCustomInitAdapter class];
}

@end
