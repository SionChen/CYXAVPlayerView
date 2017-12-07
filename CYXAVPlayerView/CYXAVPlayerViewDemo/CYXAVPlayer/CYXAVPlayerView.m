//
//  CYXAVPlayerView.m
//  CYXAVPlayerViewDemo
//
//  Created by 超级腕电商 on 2017/12/5.
//  Copyright © 2017年 超级腕电商. All rights reserved.
//

#import "CYXAVPlayerView.h"
#import "RotationScreen.h"
#import "CommonUI.h"
#import "UIView+Size.h"
#import "NSString+time.h"

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define CALL_DELEGATE(_delegate, _selector) \
do { \
id _theDelegate = _delegate; \
if(_theDelegate != nil && [_theDelegate respondsToSelector:_selector]) { \
[_theDelegate performSelector:_selector]; \
} \
} while(0);
@interface CYXAVPlayerView(){
    BOOL _isIntoBackground; // 是否在后台
    BOOL _isShowToolbar; // 是否显示工具条
    BOOL _isSliding; // 是否正在滑动
    AVPlayerItem *_playerItem;
    AVPlayerLayer *_playerLayer;
    NSTimer *_timer;
    id _playTimeObserver; // 观察者
}

/**
 主要播放视图
 */
@property (nonatomic,strong) UIView *playerView;

/**
 下部分视图
 */
@property (nonatomic,strong) UIView *downView;

/**
 播放按钮
 */
@property (nonatomic,strong) UIButton *playButton;

/**
 当前播放时间
 */
@property (nonatomic,strong) UILabel *beginLabel;

/**
 总时间
 */
@property (nonatomic,strong) UILabel *endLabel;

/**
 进度条
 */
@property (nonatomic,strong) UISlider *playProgress;

/**
 缓冲条
 */
@property (nonatomic,strong) UIProgressView *loadedProgress;

/**
 横竖屏
 */
@property (nonatomic,strong) UIButton *rotationButton;


/**
 发送隐藏消息的时间
 */
@property (nonatomic,strong) NSDate *sendHideDate;
@end
@implementation CYXAVPlayerView
- (void)dealloc {
    [self removeObserveAndNOtification];
    [_player removeTimeObserver:_playTimeObserver]; // 移除playTimeObserver
}

- (void)removeObserveAndNOtification {
    [_player replaceCurrentItemWithPlayerItem:nil];
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_player removeTimeObserver:_playTimeObserver];
    _playTimeObserver = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.playerView];
        // setAVPlayer
        self.player = [[AVPlayer alloc] init];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        [self.playerView.layer addSublayer:_playerLayer];
        
        [self addSubview:self.playButton];
        [self addSubview:self.downView];
        [self.downView addSubview:self.beginLabel];
        [self.downView addSubview:self.loadedProgress];
        [self.downView addSubview:self.playProgress];
        [self.downView addSubview:self.endLabel];
        [self.downView addSubview:self.rotationButton];
        
        [self addSubview:self.backButton];
        self.playProgress.value = 0.0;
        self.loadedProgress.progress = 0.0;
        // setPortraintLayout
        [self setPortarintLayout];
        
        self.isFirstPlay = YES;
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    _playerLayer.frame = self.bounds;
    self.downView.frame = CGRectMake(0, 0, self.width, 30);
    self.downView.bottom =self.height;
    self.playButton.frame = CGRectMake(0, 0, 60, 60);
    self.playButton.centerX = self.width/2;
    self.playButton.centerY = self.height/2;
    
    self.beginLabel.frame = CGRectMake(0, 0, 40, 30);
    self.playProgress.frame = CGRectMake(self.beginLabel.right, 0, self.width-110, 30);
    self.playProgress.centerY = self.downView.height/2;
    self.loadedProgress.frame = CGRectMake(self.playProgress.left+2, 0, self.playProgress.width-4, 30);
    self.loadedProgress.centerY = self.playProgress.centerY;
    self.endLabel.frame = CGRectMake(self.loadedProgress.right, 0, 40, 30);
    self.rotationButton.frame = CGRectMake(0, 0, 30, 30);
    self.rotationButton.right = self.downView.width;
    self.backButton.frame =  CGRectMake(15, 15+20, 30, 30);
    [self.rotationButton setImage:[UIImage imageNamed:[RotationScreen isOrientationLandscape]?@"RotationDown":@"RotationUp"] forState:UIControlStateNormal];
    if (self.isFirstPlay) {
        self.downView.alpha = 0;
        self.backButton.alpha = 0;
        self.playButton.alpha = 1;
    }
}
#pragma mark 横竖屏约束
- (void)setPortarintLayout {
    _isLandscape = NO;
    
    // 不隐藏工具条
    [self portraitShow];
    // hideInspector
    //self.inspectorViewHeight.constant = 0.0f;
    [self layoutIfNeeded];
}

// 显示工具条
- (void)portraitShow {
    _isShowToolbar = YES; // 显示工具条置为 yes
    self.sendHideDate = [NSDate date];
    [UIView animateWithDuration:0.1 animations:^{
        //self.downView.bottom = self.height;
        self.downView.alpha = 1;
        self.backButton.alpha = 1;
        self.playButton.alpha = 1;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(setAutoHide) withObject:nil afterDelay:3.0];
    }];
    // 显示状态条
    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:(UIStatusBarStyleLightContent)];
}
- (void)portraitHide {
    _isShowToolbar = NO; // 显示工具条置为 no
    
    // 约束动画
    [UIView animateWithDuration:0.1 animations:^{
        //self.downView.bottom = self.height+self.downView.height;
        self.downView.alpha = 0;
        self.backButton.alpha = 0;
        self.playButton.alpha = 0;
    } completion:^(BOOL finished) {
    }];
    // 隐藏状态条
    [[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
    
}

/**
 自动隐藏
 */
-(void)setAutoHide{
    NSDate * nowDate = [NSDate date];
    // 需要对比的时间数据
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth
    | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    // 当前日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateCom = [calendar components:unit fromDate:self.sendHideDate toDate:nowDate options:0];
    if (self.isPlaying&&dateCom.second==3) {
        [self portraitHide];
    }
}
#pragma mark 横竖屏切换
-(void)rotationAction{
    CALL_DELEGATE(self.delegate, @selector(fullScreenButtonAction));
}

- (void)checkRotation {
    
}


- (void)updatePlayerWithURL:(NSURL *)url {
    _playerItem = [AVPlayerItem playerItemWithURL:url]; // create item
    [_player  replaceCurrentItemWithPlayerItem:_playerItem]; // replaceCurrentItem
    [self addObserverAndNotification]; // 添加观察者，发布通知
}
/**
 *  添加观察者 、通知 、监听播放进度
 */
- (void)addObserverAndNotification {
    [_playerItem addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew) context:nil]; // 观察status属性， 一共有三种属性
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil]; // 观察缓冲进度
    [self monitoringPlayback:_playerItem]; // 监听播放
    [self addNotification]; // 添加通知
}
#pragma mark 添加通知
- (void)addNotification {
    // 播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    // 前台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    //后台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)playbackFinished:(NSNotification *)notification {
    NSLog(@"视频播放完成通知");
    _playerItem = [notification object];
    // 是否无限循环
    [_playerItem seekToTime:kCMTimeZero]; // 跳转到初始
    //    [_player play]; // 是否无限循环
    [self pause];
    [self portraitShow];
}

// 观察播放进度
- (void)monitoringPlayback:(AVPlayerItem *)item {
    __weak typeof(self)WeakSelf = self;
    
    // 播放进度, 每秒执行30次， CMTime 为30分之一秒
    _playTimeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if (_touchMode != TouchPlayerViewModeHorizontal) {
            // 当前播放秒
            float currentPlayTime = (double)item.currentTime.value/ item.currentTime.timescale;
            // 更新slider, 如果正在滑动则不更新
            if (_isSliding == NO) {
                [WeakSelf updateVideoSlider:currentPlayTime];
            }
        } else {
            return;
        }
    }];
}

// 更新滑动条
- (void)updateVideoSlider:(float)currentTime {
    self.playProgress.value = currentTime;
    self.beginLabel.text = [NSString convertTime:currentTime];
}
-(void)enterBackgroundNotification{
    [self pause];
    CALL_DELEGATE(self.delegate, @selector(enterBackgroundNotification));
}
-(void)enterForegroundNotification{
    
}
#pragma mark KVO - status
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    AVPlayerItem *item = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if (_isIntoBackground) {
            return;
        } else { // 判断status 的 状态
            AVPlayerStatus status = [[change objectForKey:@"new"] intValue]; // 获取更改后的状态
            if (status == AVPlayerStatusReadyToPlay) {
                NSLog(@"准备播放");
                // CMTime 本身是一个结构体
                CMTime duration = item.duration; // 获取视频长度
                NSLog(@"%.2f", CMTimeGetSeconds(duration));
                // 设置视频时间
                [self setMaxDuration:CMTimeGetSeconds(duration)];
                // 播放
                //[self play];
                
            } else if (status == AVPlayerStatusFailed) {
                NSLog(@"AVPlayerStatusFailed");
            } else {
                NSLog(@"AVPlayerStatusUnknown");
            }
        }
        
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval timeInterval = [self availableDurationRanges]; // 缓冲时间
        CGFloat totalDuration = CMTimeGetSeconds(_playerItem.duration); // 总时间
        [self.loadedProgress setProgress:timeInterval / totalDuration animated:YES];
    }
}

// 设置最大时间
- (void)setMaxDuration:(CGFloat)duration {
    self.playProgress.maximumValue = duration; // maxValue = CMGetSecond(item.duration)
    self.endLabel.text = [NSString convertTime:duration];
}

// 已缓冲进度
- (NSTimeInterval)availableDurationRanges {
    NSArray *loadedTimeRanges = [_playerItem loadedTimeRanges]; // 获取item的缓冲数组
    // discussion Returns an NSArray of NSValues containing CMTimeRanges
    
    // CMTimeRange 结构体 start duration 表示起始位置 和 持续时间
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue]; // 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds; // 计算总缓冲时间 = start + duration
    return result;
}
- (void)play {
    _isPlaying = YES;
    if (self.isFirstPlay) {[self portraitHide];}
    self.isFirstPlay = NO;
    [_player play]; // 调用avplayer 的play方法
    [self.playButton setImage:[UIImage imageNamed:@"moviePause"] forState:(UIControlStateNormal)];
    self.sendHideDate = [NSDate date];
    [self performSelector:@selector(setAutoHide) withObject:nil afterDelay:3.0];
}

- (void)pause {
    _isPlaying = NO;
    [_player pause];
    [self.playButton setImage:[UIImage imageNamed:@"moviePlay"] forState:(UIControlStateNormal)];
}
#pragma mark 处理点击事件
-(void)playOrStopAction{
    if (_isPlaying) {
        [self pause];
    } else {
        [self play];
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _touchMode = TouchPlayerViewModeNone;
}

//
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.isFirstPlay) {return;}
    if (_touchMode == TouchPlayerViewModeNone) {
        if (_isLandscape) { // 如果当前是横屏
            if (_isShowToolbar) {
                //                [self landscapeHide];
            } else {
                //                [self landscapeShow];
            }
        } else { // 如果是竖屏
            if (_isShowToolbar) {
                [self portraitHide];
            } else {
                [self portraitShow];
            }
        }
    }
}

//
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}
#pragma mark 滑块事件
-(void)playerSliderTouchDown{
    [self pause];
}
-(void)playerSliderTouchUpInside{
    _isSliding = NO; // 滑动结束
    CMTime changedTime = CMTimeMakeWithSeconds(self.playProgress.value, 1.0);
    NSLog(@"%.2f", self.playProgress.value);
    [_playerItem seekToTime:changedTime completionHandler:^(BOOL finished) {
        // 跳转完成后做某事
    }];
    [self play];
    
}
-(void)playerSliderValueChanged{
    _isSliding = YES;
    [self pause];
    // 跳转到拖拽秒处
    // self.playProgress.maxValue = value / timeScale
    // value = progress.value * timeScale
    // CMTimemake(value, timeScale) =  (progress.value, 1.0)
//    CMTime changedTime = CMTimeMakeWithSeconds(self.playProgress.value, 1.0);
//    NSLog(@"%.2f", self.playProgress.value);
//    [_playerItem seekToTime:changedTime completionHandler:^(BOOL finished) {
//        // 跳转完成后做某事
//    }];
}
#pragma mark ---G
-(UIView*)playerView{
    if(!_playerView){
        _playerView = [[UIView alloc] init];
    }
    return _playerView;
}
-(UIView*)downView{
    if(!_downView){
        _downView = [[UIView alloc] init];
        _downView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        _downView.userInteractionEnabled = YES;
    }
    return _downView;
}
-(UIButton*)playButton{
    if(!_playButton){
        WS(_self);
        _playButton = [CommonUI creatButtonWithFrame:CGRectZero backgroundColor:[UIColor clearColor] title:@"" titleFont:[UIFont systemFontOfSize:14] titleColor:[UIColor clearColor] actionBlock:^(UIControl *control) {
            [_self playOrStopAction];
        }];
        [_playButton setImage:[UIImage imageNamed:@"moviePlay"] forState:(UIControlStateNormal)];
    }
    return _playButton;
}
-(UILabel*)beginLabel{
    if(!_beginLabel){
        _beginLabel = [[UILabel alloc] init];
        _beginLabel.textColor = [UIColor whiteColor];
        _beginLabel.font = [UIFont systemFontOfSize:10];
        _beginLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _beginLabel;
}
-(UILabel*)endLabel{
    if(!_endLabel){
        _endLabel = [[UILabel alloc] init];
        _endLabel.textColor = [UIColor whiteColor];
        _endLabel.font = [UIFont systemFontOfSize:10];
        _endLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _endLabel;
}
-(UISlider*)playProgress{
    if(!_playProgress){
        _playProgress = [[UISlider alloc] init];
        [_playProgress setThumbImage:[UIImage imageNamed:@"Slider_thumb"] forState:UIControlStateNormal];
        [_playProgress addTarget:self action:@selector(playerSliderTouchDown) forControlEvents:UIControlEventTouchDown];
        [_playProgress addTarget:self action:@selector(playerSliderValueChanged) forControlEvents:UIControlEventValueChanged];
        [_playProgress addTarget:self action:@selector(playerSliderTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [_playProgress setMinimumValueImage:nil];
        [_playProgress setMinimumValueImage:nil];
        [_playProgress setMinimumTrackTintColor:[UIColor redColor]];          //左边轨道的颜色
        [_playProgress setMaximumTrackTintColor:[UIColor clearColor]];
    }
    return _playProgress;
}
-(UIProgressView*)loadedProgress{
    if(!_loadedProgress){
        _loadedProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _loadedProgress.progressTintColor = [UIColor whiteColor];
    }
    return _loadedProgress;
}
-(UIButton*)rotationButton{
    if(!_rotationButton){
        WS(_self);
        _rotationButton = [CommonUI creatButtonWithFrame:CGRectZero backgroundColor:[UIColor clearColor] title:@"" titleFont:[UIFont systemFontOfSize:14] titleColor:[UIColor clearColor] actionBlock:^(UIControl *control) {
            [_self rotationAction];
        }];
        [_rotationButton setImage:[UIImage imageNamed:@"RotationUp"] forState:UIControlStateNormal];
    }
    return _rotationButton;
}
-(UIButton*)backButton{
    if(!_backButton){
        WS(_self);
        _backButton = [CommonUI creatButtonWithFrame:CGRectZero backgroundColor:[UIColor clearColor] title:@"" titleFont:[UIFont systemFontOfSize:14] titleColor:[UIColor clearColor] actionBlock:^(UIControl *control) {
            if ([RotationScreen isOrientationLandscape]) { // 如果是横屏，
                [RotationScreen forceOrientation:(UIInterfaceOrientationPortrait)]; // 切换为竖屏
            }
            CALL_DELEGATE(_self.delegate, @selector(backButtonAction));
        }];
        [_backButton setImage:[UIImage imageNamed:@"movieClose"] forState:UIControlStateNormal];
        
    }
    return _backButton;
}
@end
