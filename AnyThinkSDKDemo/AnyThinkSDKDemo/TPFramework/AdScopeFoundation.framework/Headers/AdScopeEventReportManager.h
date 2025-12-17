//
//  AdScopeEventReportManager.h
//  AdScopeFoundation
//
//  Created by nie adhub on 2024/6/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdScopeEventReportManager : NSObject

+ (AdScopeEventReportManager *)sharedInstance;

- (void)initializeReportLoaderWithInitializeData:(NSData *)initializeData;

- (void)updateReportLoaderWithUpdateData:(NSData *)updateData;

- (void)trackReportWithReportData:(NSData *)reportData;

@end

NS_ASSUME_NONNULL_END
