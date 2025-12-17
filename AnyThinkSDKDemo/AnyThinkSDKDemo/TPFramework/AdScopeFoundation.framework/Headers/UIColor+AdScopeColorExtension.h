//
//  UIColor+AdScopeColorExtension.h
//  AdScopeFoundation
//
//  Created by Cookie on 2022/4/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (AdScopeColorExtension)

+ (UIColor *)adScopeColorWithHexString:(NSString *)hexString;
- (UIImage *)adScopeImageColorWithSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
