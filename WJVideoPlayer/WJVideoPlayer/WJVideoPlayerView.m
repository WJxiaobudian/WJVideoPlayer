//
//  WJVideoPlayerView.m
//  WJVideoPlayer
//
//  Created by WJ on 16/6/7.
//  Copyright © 2016年 WJ. All rights reserved.
//

#import "WJVideoPlayerView.h"

#define RGBA(r, g, b, a)                    [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r, g, b)                        RGBA(r, g, b, 1.0f)


@interface WJVideoPlayerView ()

@property (nonatomic, strong) id playBackObserver;
@property (nonatomic, strong) UIView *loadView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL viewIsShowing;
@end

@implementation WJVideoPlayerView

- (instancetype)initWithFrame:(CGRect)frame contentURL:(NSURL *)contentURL {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.playerItem = [AVPlayerItem playerItemWithURL:contentURL];
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.frame = frame;
        [self.layer addSublayer:self.playerLayer];
        
        [self initLoadingView];
        [self initControlView];
        
        self.viewIsShowing = YES;
        
        [self addNotification];
        [self addObserverToPlayerItem:self.playerItem];
        [self addProgressObserver];
//        [self startTimer];
        
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame: frame];
    [self.playerLayer setFrame:frame];
}

- (void)setIsFullScreen:(BOOL)isFullScreen {
    _isFullScreen = isFullScreen;
    
}

- (void)play {
    [self.player play];
    self.isPlaying = YES;
    [self.playBtn setSelected:YES];
}

- (void)pause {
    [self.player pause];
    self.isPlaying = NO;
    [self.playBtn setSelected:NO];
}

- (void)stop {
    
   
}

- (void)initLoadingView {
    
    self.loadView = [[UIView alloc] initWithFrame:self.playerLayer.frame];
    self.loadView.backgroundColor = [UIColor clearColor];
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.activityIndicatorView.center = self.loadView.center;
    self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [self.activityIndicatorView startAnimating];
    [self.loadView addSubview:self.activityIndicatorView];
    
    [self addSubview:self.loadView];
}

- (void)initControlView {
    int frameWidth = self.frame.size.width;
    int frameHeight = self.frame.size.height;
    
    // 上面的遮罩
    self.playerHUDTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, frameWidth, 40)];
    [self addSubview:self.playerHUDTopView];
    // 返回按钮
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backBtn.frame = CGRectMake(15, 0, 30, 30);
    [self.backBtn addTarget:self action:@selector(OnBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [self.playerHUDTopView addSubview:self.backBtn];
    
    // 下面的遮罩
    self.playerHUDBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, frameHeight - 44, frameWidth, 44)];
    self.playerHUDBottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4]
    ;
    [self addSubview:self.playerHUDBottomView];
    // 播放，暂停按钮
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playBtn.frame = CGRectMake(8, 10, 20, 20);
    [self.playBtn addTarget:self action:@selector(OnPlayBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.playBtn.selected = NO;
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"full_pause_icon"] forState:UIControlStateSelected];
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"full_play_icon"] forState:UIControlStateNormal];
    [self.playBtn setTintColor:[UIColor clearColor]];
    [self.playerHUDBottomView addSubview:self.playBtn];
    
    // 全屏按钮
    self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fullScreenBtn.frame = CGRectMake(frameWidth - 27, 10, 20, 20);
    [self.fullScreenBtn addTarget:self action:@selector(OnFullScreenBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.fullScreenBtn setImage:[UIImage imageNamed:@"zoomout1"] forState:UIControlStateSelected];
    [self.fullScreenBtn setImage:[UIImage imageNamed:@"zoomin1"] forState:UIControlStateNormal];
    [self.fullScreenBtn setTintColor:[UIColor clearColor]];
    [self.playerHUDBottomView addSubview:self.fullScreenBtn];
    
    // 缓存进度条
    self.loadProgressView = [[UIProgressView alloc] init];
    self.loadProgressView.frame = CGRectMake(32, 17, frameWidth - 60, 14);
    self.loadProgressView.progressViewStyle = UIProgressViewStyleBar;
    self.loadProgressView.progressTintColor = RGB(181, 181, 181);
    self.loadProgressView.backgroundColor = [UIColor greenColor];
    self.loadProgressView.progress = 0;
    [self.playerHUDBottomView addSubview:self.loadProgressView];
    
    // 播放进度条
    self.progressBar = [[UISlider alloc] init];
    self.progressBar.frame = CGRectMake(30, 11, frameWidth - 60, 14);
    [self.progressBar addTarget:self action:@selector(progressBarChanged:) forControlEvents:UIControlEventValueChanged];
    [self.progressBar addTarget:self action:@selector(progressBarChangeEnded:) forControlEvents:UIControlEventTouchUpInside];
    [self.progressBar setMinimumTrackTintColor:RGB(242, 96, 0)];
    [self.progressBar setMaximumTrackTintColor:[UIColor clearColor]];
    [self.progressBar setThumbTintColor:[UIColor clearColor]];
    
    // 滑块图片
    UIImage *thumbImage = [UIImage imageNamed:@"account_cache_isplay"];
    [self.progressBar setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [self.progressBar setThumbImage:thumbImage forState:UIControlStateNormal];
    [self.playerHUDBottomView addSubview:self.progressBar];
    
    // 播放时间
    self.playTime = [[UILabel alloc] initWithFrame:CGRectMake(30, 20, 200, 20)];
    self.playTime.text = @"00:00:00/00:00:00";
    self.playTime.font = [UIFont systemFontOfSize:13];
    self.playTime.textAlignment = NSTextAlignmentLeft;
    self.playTime.textColor = [UIColor whiteColor];
    [self.playerHUDBottomView addSubview:self.playTime];
}

- (void)initPlayTime {
    NSString *currentTime = [self getStringFromCMTime:self.player.currentTime];
    NSString *totalTime = [self getStringFromCMTime:self.player.currentItem.asset.duration];
    self.playTime.text = [NSString stringWithFormat:@"%@/%@",currentTime, totalTime];
    
}

- (NSString *)getStringFromCMTime:(CMTime)time {
    Float64 currentSeconds = CMTimeGetSeconds(time);
    int mins = currentSeconds/60.0;
    int hours = mins/60.0;
    int secs = fmodf(currentSeconds, 60.0);
    mins = fmodf(mins, 60.0);
    
    NSString *hoursStriing = [NSString stringWithFormat:@"%02d",hours];
    NSString *minsString = [NSString stringWithFormat:@"%02d",mins];
    NSString *secsString = [NSString stringWithFormat:@"%02d",secs];
    
    return [NSString stringWithFormat:@"%@:%@:%@",hoursStriing,minsString, secsString];
}

// 添加计时器， 显示/隐藏播放栏
- (void)startTimer {
    if (self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(initHUDViewShowing:) userInfo:nil repeats:YES];
    }
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)initHUDViewShowing:(NSTimer *)timer {
    [self showHud:self.viewIsShowing];
    
}

- (void)showHud:(BOOL)showing {
    if (showing) {
        self.viewIsShowing = !showing;
        self.playerHUDBottomView.hidden = YES;
        [self stopTimer];
    } else {
        self.viewIsShowing = !showing;
        self.playerHUDBottomView.hidden = NO;
        [self startTimer];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        self.isFullScreen = YES;
        [self initLandscape];
    } else {
        self.isFullScreen = NO;
        [self initProtraint];
    }
}

- (void)initLandscape {
    float frameWidth = self.frame.size.width;
    float frameHeight = self.frame.size.height;
    self.playerHUDBottomView.frame = CGRectMake(0, frameHeight - 44, frameWidth, 44);
    self.fullScreenBtn.frame = CGRectMake(frameWidth - 27, 10, 20, 20);
    self.progressBar.frame = CGRectMake(30, 11, frameWidth - 60, 14);
    self.loadProgressView.frame = CGRectMake(32, 17, frameWidth - 60, 14);
}

- (void)initProtraint {
    float frameWidth = self.frame.size.width;
    float frameHeight = self.frame.size.height;
    self.playerHUDBottomView.frame = CGRectMake(0, frameHeight - 44, frameWidth, 44);
    self.fullScreenBtn.frame = CGRectMake(frameWidth - 27, 10, 20, 20);
    self.progressBar.frame = CGRectMake(30, 11, frameWidth - 60, 14);
    self.loadProgressView.frame = CGRectMake(32, 17, frameWidth - 60, 14);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject]locationInView:self];
    
    if (CGRectContainsPoint(self.playerLayer.frame, point)) {
        [self showHud:self.viewIsShowing];

    }
}

- (void)OnPlayBtn:(UIButton *)sender {
    if (self.isPlaying) {
        [self pause];
    } else {
        [self play];
    }
}

- (void)OnFullScreenBtn:(UIButton *)sender {
    self.isFullScreen = !self.isFullScreen;
    if (self.isFullScreen) {
        [self.fullScreenBtn setSelected:YES];
    } else {
        [self.fullScreenBtn setSelected:NO];
    }
    
    [self.delegate playerViewFullScreenButtonClicked:self];
    
}

- (void)OnBackBtn:(UIButton *)sender {
    if (self.isFullScreen) {
        self.isFullScreen = !self.isFullScreen;
        [self.delegate playerViewFullScreenButtonClicked:self];
    } else {
        [self.delegate backBtn];
    }
}

- (void)progressBarChanged:(UISlider *)sender {
    if (self.isPlaying) {
        [self.player pause];
    }
    
    CMTime time = CMTimeMakeWithSeconds(sender.value*(double)self.player.currentItem.asset.duration.value/(double)self.player.currentItem.asset.duration.timescale, self.player.currentTime.timescale);
    [self.player seekToTime:time];
}

- (void)progressBarChangeEnded:(UISlider *)sender {
    [self startTimer];
    if (self.isPlaying) {
        [self.player play];
    }
}

// 播放进度条更新
- (void)addProgressObserver {
    AVPlayerItem *playerItem = self.player.currentItem;
    [self.playBackObserver = self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds(playerItem.duration);
        float progress = current/total;
        self.progressBar.value = progress;
        NSString *currentTime = [self getStringFromCMTime:self.player.currentTime];
        NSString *totalTime = [self getStringFromCMTime:playerItem.duration];
        self.playTime.text = [NSString stringWithFormat:@"%@/%@",currentTime, totalTime];
        
    }];
}

// 添加播放完成通知
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinish) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

- (void)playbackFinish {
    
}

/**
 *  给 AVPlayerItem 添加监控
 *
 *  @param playerItem AVPlayerItem 对象
 */
- (void)addObserverToPlayerItem:(AVPlayerItem *)playerItem {
    // 监控状态属性，注意AVPlayer 也有一个status属性，通过监控它的status 也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    // 监控缓存区大小
    [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    
    [self performSelectorInBackground:@selector(initPlayTime) withObject:nil];
}

/**
 *  移除KVO观察
 */
- (void)removeObserverToPlayerItem:(AVPlayerItem *)playerItem {
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
}

// 观察视频播放各个监听触发
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerStatusFailed:
                [self.loadView setHidden:NO];
                break;
            case AVPlayerStatusReadyToPlay:
                [self.loadView setHidden:YES];
                break;
            default:
                
                break;
        }
    } else if([keyPath isEqualToString:@"loadedTimeRanges"]) { //缓存
        NSArray *array = self.playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;
        
        //        float durationTime = CMTimeGetSeconds([[self.player currentItem] duration]);
        [self.loadProgressView setProgress:totalBuffer/durationSeconds animated:YES];
        if (self.playerIsBuffering && self.isPlaying) {
            [self.player play];
            self.playerIsBuffering = NO;
        }
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        if (self.player.currentItem.playbackBufferEmpty) {
            self.playerIsBuffering = YES;
        }
    }
}

- (void)dealloc {
    [self removeObserverToPlayerItem:self.playerItem];
    [self.player removeTimeObserver:self.playBackObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
