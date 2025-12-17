//
//  AdScopeMacros.h
//  AdScopeFoundation
//
//  Created by Cookie on 2022/7/27.
//

#import <pthread.h>
#import <AdScopeFoundation/NSObject+AdScopeJSONModel.h>

#ifndef AdScopeMacros_h
#define AdScopeMacros_h

#define AdScopeCancelPerformSelectorLeakWarning(Cookie) \
    do { \
        _Pragma("clang diagnostic push") \
        _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
        Cookie; \
        _Pragma("clang diagnostic pop") \
    } while (0)

#define ADSCOPE_IS_NULL(obj)             (obj == nil || obj == (id)[NSNull null])
#define ADSCOPE_IS_NOT_NULL(obj)         (obj != nil && obj != (id)[NSNull null])
#define ADSCOPE_STRING_EMPTY(obj)        ((ADSCOPE_IS_NULL(obj)) || (![obj isKindOfClass:[NSString class]]) || [obj length] == 0 )
#define ADSCOPE_DATA_EMPTY(obj)          ((ADSCOPE_IS_NULL(obj)) || (![obj isKindOfClass:[NSData class]]) || [obj length] == 0 )
#define ADSCOPE_SAFE_STRING(obj)         ((ADSCOPE_IS_NOT_NULL(obj))?obj:@"")
#define ADSCOPE_MODEML_NULL(obj)         ((ADSCOPE_IS_NULL(obj)) || [[obj adScope_modelToJSONObject]count] == 0 )

// 判断是否为iPhone X 系列  这样写消除了在Xcode10上的警告。
#define ADSCOPE_IPHONE_X \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

#define weakObj(obj) autoreleasepool{} __weak typeof(obj) obj##Weak = obj;
#define strongObj(obj) autoreleasepool{} __strong typeof(obj) obj = obj##Weak;

/**
 屏幕宽高
 */
#define kAdScopeScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kAdScopeScreenHeight [[UIScreen mainScreen] bounds].size.height

/*状态栏高度*/
#define kAdScopeStatusBarHeight (CGFloat)(ADSCOPE_IPHONE_X ? 44.0 : 20.0)
#define kAdScopeSafeAreaBottomHeight (CGFloat)(ADSCOPE_IPHONE_X ? 34.0 : 22.0)
#define kAdScopeSafeAreaTopHeight (CGFloat)(ADSCOPE_IPHONE_X ? 44.0 : 22.0)
#define kAdScopeNavHeight (CGFloat)(ADSCOPE_IPHONE_X ? 88.0 : 64.0)
#define kAdScopeTabbarHeight (CGFloat)(ADSCOPE_IPHONE_X ? 80.0 : 49.0)

/*返回主线程*/
#ifndef adscope_back_main_queue_safe
#define adscope_back_main_queue_safe(block)\
if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(dispatch_get_main_queue())) {\
    block();\
} else {\
    dispatch_async(dispatch_get_main_queue(), block);\
}
#endif


static inline bool adscope_dispatch_is_main_queue(void) {
    return pthread_main_np() != 0;
}

static inline void adscope_dispatch_async_on_main_queue(void (^block)(void)) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

static inline void adscope_dispatch_sync_on_main_queue(void (^block)(void)) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

#endif /* AdScopeMacros_h */
