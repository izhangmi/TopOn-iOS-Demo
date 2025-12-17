//
//  AdScopeAFCompatibilityMacros.h
//  AdScopeFoundation
//
//  Created by Cookie on 2022/9/5.
//

#ifndef AdScopeAFCompatibilityMacros_h
#define AdScopeAFCompatibilityMacros_h

#ifdef API_AVAILABLE
    #define AdScope_AF_API_AVAILABLE(...) API_AVAILABLE(__VA_ARGS__)
#else
    #define AdScope_AF_API_AVAILABLE(...)
#endif // API_AVAILABLE

#ifdef API_UNAVAILABLE
    #define AdScope_AF_API_UNAVAILABLE(...) API_UNAVAILABLE(__VA_ARGS__)
#else
    #define AdScope_AF_API_UNAVAILABLE(...)
#endif // API_UNAVAILABLE

#if __has_warning("-Wunguarded-availability-new")
    #define AdScope_AF_CAN_USE_AT_AVAILABLE 1
#else
    #define AdScope_AF_CAN_USE_AT_AVAILABLE 0
#endif

#if ((__IPHONE_OS_VERSION_MAX_ALLOWED && __IPHONE_OS_VERSION_MAX_ALLOWED < 100000) || (__MAC_OS_VERSION_MAX_ALLOWED && __MAC_OS_VERSION_MAX_ALLOWED < 101200) ||(__WATCH_OS_MAX_VERSION_ALLOWED && __WATCH_OS_MAX_VERSION_ALLOWED < 30000) ||(__TV_OS_MAX_VERSION_ALLOWED && __TV_OS_MAX_VERSION_ALLOWED < 100000))
    #define AdScope_AF_CAN_INCLUDE_SESSION_TASK_METRICS 0
#else
    #define AdScope_AF_CAN_INCLUDE_SESSION_TASK_METRICS 1
#endif

#endif /* AdScopeAFCompatibilityMacros_h */
