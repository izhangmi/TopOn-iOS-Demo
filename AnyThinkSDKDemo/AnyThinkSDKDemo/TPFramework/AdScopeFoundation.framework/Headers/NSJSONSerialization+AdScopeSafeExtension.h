//
//  NSJSONSerialization+AdScopeSafeExtension.h
//  AdScopeFoundation
//
//  Created by Cookie on 2022/9/29.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSJSONSerialization (AdScopeSafeExtension)

+ (nullable id)adScopeSafeJSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
