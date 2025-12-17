//
//  AdScopeUserInfo.h
//  AdScopeFoundation
//
//  Created by Cookie on 2022/9/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_subclassing_restricted))
@interface AdScopeUserInfo : NSObject

+ (AdScopeUserInfo *)sharedInstance;

@property (nonatomic, strong) NSDictionary *extInfo;

@end

NS_ASSUME_NONNULL_END
