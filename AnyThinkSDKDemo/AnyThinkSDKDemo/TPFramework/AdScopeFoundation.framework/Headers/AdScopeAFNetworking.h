//
//  AdScopeAFNetworking.h
//  AdScopeFoundation
//
//  Created by Cookie on 2022/9/5.
//

#ifndef AdScopeAFNetworking_h
#define AdScopeAFNetworking_h

#import <Foundation/Foundation.h>
#import <Availability.h>
#import <TargetConditionals.h>

#ifndef _AdScopeAFNETWORKING_
    #define _AdScopeAFNETWORKING_

    #import <AdScopeFoundation/AdScopeAFURLRequestSerialization.h>
    #import <AdScopeFoundation/AdScopeAFURLResponseSerialization.h>
    #import <AdScopeFoundation/AdScopeAFSecurityPolicy.h>

#if !TARGET_OS_WATCH
    #import <AdScopeFoundation/AdScopeAFNetworkReachabilityManager.h>
#endif

    #import <AdScopeFoundation/AdScopeAFURLSessionManager.h>
    #import <AdScopeFoundation/AdScopeAFHTTPSessionManager.h>

#endif

#endif /* AdScopeAFNetworking_h */
