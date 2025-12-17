//
//  AMPSMediaView.h
//  AMPSAdSDK
//
//  Created by Cookie on 2025/1/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//视频播放状态
typedef NS_ENUM(NSUInteger, AMPSMediaVideoPlayerStatus) {
    kAMPSMediaVideoPlayerStatusNormal                  = 0,//默认
    kAMPSMediaVideoPlayerStatusPlayable                = 1,//可播放
    kAMPSMediaVideoPlayerStatusBufferEmpty             = 2,//缓冲
    kAMPSMediaVideoPlayerStatusPlay                    = 3,//播放
    kAMPSMediaVideoPlayerStatusPause                   = 4,//暂停
    kAMPSMediaVideoPlayerStatusFinishPlay              = 5,//播放完成
    kAMPSMediaVideoPlayerStatusFailedToPlay            = 888,//播放失败
    kAMPSMediaVideoPlayerStatusUnPlayable              = 999,//不可播放
};

@protocol AMPSMediaVideoViewDelegate;

@interface AMPSMediaView : UIView

/**
 ADN delegate
 */
@property (nonatomic, weak, nullable) id<AMPSMediaVideoViewDelegate> delegate;

/**
 must, 更新布局
 */
- (void)resetLayoutWithRect:(CGRect)rect;

/**
 播放
 */
- (void)play;

/**
 暂停
 */
- (void)pause;

/**
 停止
 */
- (void)stop;

/**
 自定义播放按钮
 @param image 自定义播放按钮图片，不设置为默认图
 @param size 自定义播放按钮大小，不设置为默认大小 44 * 44
 */
- (void)playerPlayIncon:(UIImage *)image playInconSize:(CGSize)size;

@end

@protocol AMPSMediaVideoViewDelegate <NSObject>

@optional

/**
 视频播放
 */
- (void)ampsMediaVideoViewDidPlay:(AMPSMediaView *)mediaView;

/**
 视频暂停
 */
- (void)ampsMediaVideoViewDidPause:(AMPSMediaView *)mediaView;

/**
 视频播放时间
 */
- (void)ampsMediaVideoViewPlayerLeftTime:(NSInteger)leftTime mediaView:(AMPSMediaView *)mediaView;

/**
 视频播放完成
 */
- (void)ampsMediaVideoViewDidFinishPlay:(AMPSMediaView *)mediaView;

/**
 视频播放失败
 */
- (void)ampsMediaVideoViewDidFailedToPlay:(AMPSMediaView *)mediaView;

@end

NS_ASSUME_NONNULL_END
