//
//  WJVideoPlayerView.h
//  WJVideoPlayer
//
//  Created by WJ on 16/6/17.
//  Copyright © 2016年 WJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@class WJVideoPlayerView;
@protocol WJPlayerViewDelegate <NSObject>

@optional
- (void)playerViewFullScreenButtonClicked:(WJVideoPlayerView *)view;

- (void)backBtn;

@end

@interface WJVideoPlayerView : UIView


@property (nonatomic, assign) id<WJPlayerViewDelegate> delegate;
/**
 *  AVPlayerItem: 一个媒体资源管理对象，管理视频的一些基本信息和状态，一个AVPlayerItem对应一个视频资源
 */
@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, copy) NSString *contentStr;

@property (nonatomic, strong) NSURL *contentURL;

@property (nonatomic, assign) BOOL isFullScreen;

@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, assign) BOOL playerIsBuffering;

@property (nonatomic, strong) UIButton *playBtn;

@property (nonatomic, strong) UIButton *fullScreenBtn;

@property (nonatomic, strong) UISlider *progressBar;

@property (nonatomic, strong) UIProgressView *loadProgressView;

@property (nonatomic, strong) UILabel *playTime;

@property (nonatomic, strong) UILabel *playTotalTime;

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UIView *playerHUDBottomView;

@property (nonatomic, strong) UIView *playerHUDTopView;

- (instancetype)initWithFrame:(CGRect)frame contentURL:(NSURL *)contentURL;

- (void)play;

- (void)pause;

- (void)stop;

@end
