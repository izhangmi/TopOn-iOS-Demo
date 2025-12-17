//
//  AdScopeFoundation.h
//  AdScopeFoundation
//
//  Created by Cookie on 2022/2/8.
//

#import <Foundation/Foundation.h>

//! Project version number for AdScopeFoundation.
FOUNDATION_EXPORT double AdScopeFoundationVersionNumber;

//! Project version string for AdScopeFoundation.
FOUNDATION_EXPORT const unsigned char AdScopeFoundationVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <AdScopeFoundation/PublicHeader.h>

/*Category*/
#import <AdScopeFoundation/UIColor+AdScopeColorExtension.h>
#import <AdScopeFoundation/NSData+AdScopeDataExtension.h>
#import <AdScopeFoundation/NSTimer+AdScopeTimerExtension.h>
#import <AdScopeFoundation/NSString+AdScopeStringExtension.h>
#import <AdScopeFoundation/NSObject+AdScopeInvoker.h>
#import <AdScopeFoundation/UIView+AdScopeAutoLayout.h>
#import <AdScopeFoundation/UIImage+AdScopeImageExtension.h>

/*Safe*/
#import <AdScopeFoundation/AdScpoeSafeUtilities.h>
#import <AdScopeFoundation/NSObject+AdScopeThreadSafeExtension.h>
#import <AdScopeFoundation/AdScopeThreadSafeAccessor.h>
#import <AdScopeFoundation/NSJSONSerialization+AdScopeSafeExtension.h>

//  数组安全
#import <AdScopeFoundation/NSArray+AdScopeSafeExtension.h>
#import <AdScopeFoundation/AdScopeThreadSafeArray.h>

//  字典安全
#import <AdScopeFoundation/NSDictionary+AdScopeSafeExtension.h>
#import <AdScopeFoundation/AdScopeThreadSafeDictionary.h>

//  Tools
#import <AdScopeFoundation/AdScopeDeviceInfo.h>
#import <AdScopeFoundation/AdScopeAppInfo.h>
#import <AdScopeFoundation/AdScopeUserInfo.h>
#import <AdScopeFoundation/AdScopeMacros.h>
#import <AdScopeFoundation/AdScopeCrashHandle.h>
#import <AdScopeFoundation/AdScopeTimer.h>
#import <AdScopeFoundation/AdScopeIOAOPs.h>
#import <AdScopeFoundation/AdScopeOSLogTools.h>

//  Networking
#import <AdScopeFoundation/AdScopeAFNetworking.h>
#import <AdScopeFoundation/AdScopeAFCompatibilityMacros.h>
#import <AdScopeFoundation/AdScopeAFHTTPSessionManager.h>
#import <AdScopeFoundation/AdScopeAFURLSessionManager.h>
#import <AdScopeFoundation/AdScopeAFNetworkReachabilityManager.h>
#import <AdScopeFoundation/AdScopeAFSecurityPolicy.h>
#import <AdScopeFoundation/AdScopeAFURLRequestSerialization.h>
#import <AdScopeFoundation/AdScopeAFURLResponseSerialization.h>

//  Model解析器
#import <AdScopeFoundation/NSObject+AdScopeJSONModel.h>

//  数据库
#import <AdScopeFoundation/AdScopeDBHelperModel.h>
//  日志
#import <AdScopeFoundation/AdScopeEventReportManager.h>
#import <AdScopeFoundation/AdScopeEventManager.h>
