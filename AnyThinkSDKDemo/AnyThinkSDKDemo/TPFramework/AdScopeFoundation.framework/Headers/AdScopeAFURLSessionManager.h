//
//  AdScopeAFURLSessionManager.h
//  AdScopeFoundation
//
//  Created by Cookie on 2022/9/5.
//

#import <Foundation/Foundation.h>

#import <AdScopeFoundation/AdScopeAFURLResponseSerialization.h>
#import <AdScopeFoundation/AdScopeAFURLRequestSerialization.h>
#import <AdScopeFoundation/AdScopeAFSecurityPolicy.h>
#import <AdScopeFoundation/AdScopeAFCompatibilityMacros.h>
#if !TARGET_OS_WATCH
#import <AdScopeFoundation/AdScopeAFNetworkReachabilityManager.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface AdScopeAFURLSessionManager : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate, NSSecureCoding, NSCopying>

@property (readonly, nonatomic, strong) NSURLSession *session;

@property (readonly, nonatomic, strong) NSOperationQueue *operationQueue;

@property (nonatomic, strong) id <AdScopeAFURLResponseSerialization> responseSerializer;

@property (nonatomic, strong) AdScopeAFSecurityPolicy *securityPolicy;

#if !TARGET_OS_WATCH

@property (readwrite, nonatomic, strong) AdScopeAFNetworkReachabilityManager *reachabilityManager;
#endif

@property (readonly, nonatomic, strong) NSArray <NSURLSessionTask *> *tasks;

@property (readonly, nonatomic, strong) NSArray <NSURLSessionDataTask *> *dataTasks;

@property (readonly, nonatomic, strong) NSArray <NSURLSessionUploadTask *> *uploadTasks;

@property (readonly, nonatomic, strong) NSArray <NSURLSessionDownloadTask *> *downloadTasks;

@property (nonatomic, strong, nullable) dispatch_queue_t completionQueue;

@property (nonatomic, strong, nullable) dispatch_group_t completionGroup;

- (instancetype)initWithSessionConfiguration:(nullable NSURLSessionConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

- (void)invalidateSessionCancelingTasks:(BOOL)cancelPendingTasks resetSession:(BOOL)resetSession;

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
                             downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                            completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler;

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromFile:(NSURL *)fileURL
                                         progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject, NSError  * _Nullable error))completionHandler;

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromData:(nullable NSData *)bodyData
                                         progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error))completionHandler;

- (NSURLSessionUploadTask *)uploadTaskWithStreamedRequest:(NSURLRequest *)request
                                                 progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                        completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error))completionHandler;

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                             progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                          destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                    completionHandler:(nullable void (^)(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler;

- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
                                                progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                             destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                       completionHandler:(nullable void (^)(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler;

- (nullable NSProgress *)uploadProgressForTask:(NSURLSessionTask *)task;

- (nullable NSProgress *)downloadProgressForTask:(NSURLSessionTask *)task;

- (void)setSessionDidBecomeInvalidBlock:(nullable void (^)(NSURLSession *session, NSError *error))block;

- (void)setSessionDidReceiveAuthenticationChallengeBlock:(nullable NSURLSessionAuthChallengeDisposition (^)(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential * _Nullable __autoreleasing * _Nullable credential))block;

- (void)setTaskNeedNewBodyStreamBlock:(nullable NSInputStream * (^)(NSURLSession *session, NSURLSessionTask *task))block;

- (void)setTaskWillPerformHTTPRedirectionBlock:(nullable NSURLRequest * _Nullable (^)(NSURLSession *session, NSURLSessionTask *task, NSURLResponse *response, NSURLRequest *request))block;

- (void)setAuthenticationChallengeHandler:(id (^)(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, void (^completionHandler)(NSURLSessionAuthChallengeDisposition , NSURLCredential * _Nullable)))authenticationChallengeHandler;

- (void)setTaskDidSendBodyDataBlock:(nullable void (^)(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))block;

- (void)setTaskDidCompleteBlock:(nullable void (^)(NSURLSession *session, NSURLSessionTask *task, NSError * _Nullable error))block;

#if AdScope_AF_CAN_INCLUDE_SESSION_TASK_METRICS
- (void)setTaskDidFinishCollectingMetricsBlock:(nullable void (^)(NSURLSession *session, NSURLSessionTask *task, NSURLSessionTaskMetrics * _Nullable metrics))block AdScope_AF_API_AVAILABLE(ios(10), macosx(10.12), watchos(3), tvos(10));
#endif

- (void)setDataTaskDidReceiveResponseBlock:(nullable NSURLSessionResponseDisposition (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response))block;

- (void)setDataTaskDidBecomeDownloadTaskBlock:(nullable void (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask))block;

- (void)setDataTaskDidReceiveDataBlock:(nullable void (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data))block;

- (void)setDataTaskWillCacheResponseBlock:(nullable NSCachedURLResponse * (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSCachedURLResponse *proposedResponse))block;

- (void)setDidFinishEventsForBackgroundURLSessionBlock:(nullable void (^)(NSURLSession *session))block AdScope_AF_API_UNAVAILABLE(macos);

- (void)setDownloadTaskDidFinishDownloadingBlock:(nullable NSURL * _Nullable  (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location))block;

- (void)setDownloadTaskDidWriteDataBlock:(nullable void (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))block;

- (void)setDownloadTaskDidResumeBlock:(nullable void (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t fileOffset, int64_t expectedTotalBytes))block;

@end

FOUNDATION_EXPORT NSString * const AdScopeAFNetworkingTaskDidResumeNotification;

FOUNDATION_EXPORT NSString * const AdScopeAFNetworkingTaskDidCompleteNotification;

FOUNDATION_EXPORT NSString * const AdScopeAFNetworkingTaskDidSuspendNotification;

FOUNDATION_EXPORT NSString * const AdScopeAFURLSessionDidInvalidateNotification;

FOUNDATION_EXPORT NSString * const AdScopeAFURLSessionDownloadTaskDidMoveFileSuccessfullyNotification;

FOUNDATION_EXPORT NSString * const AdScopeAFURLSessionDownloadTaskDidFailToMoveFileNotification;

FOUNDATION_EXPORT NSString * const AdScopeAFNetworkingTaskDidCompleteResponseDataKey;

FOUNDATION_EXPORT NSString * const AdScopeAFNetworkingTaskDidCompleteSerializedResponseKey;

FOUNDATION_EXPORT NSString * const AdScopeAFNetworkingTaskDidCompleteResponseSerializerKey;

FOUNDATION_EXPORT NSString * const AdScopeAFNetworkingTaskDidCompleteAssetPathKey;

FOUNDATION_EXPORT NSString * const AdScopeAFNetworkingTaskDidCompleteErrorKey;

FOUNDATION_EXPORT NSString * const AdScopeAFNetworkingTaskDidCompleteSessionTaskMetrics;

NS_ASSUME_NONNULL_END
