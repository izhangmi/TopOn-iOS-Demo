//
//  AdScopeEventManager.h
//  AdScopeFoundation
//
//  Created by Cookie on 2025/3/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdScopeEventManager : NSObject

+ (instancetype)sharedInstance;

- (void)initializeOrUpdateWithData:(NSData *)data customId:(NSString *)customId;

- (void)trackReportWithData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
