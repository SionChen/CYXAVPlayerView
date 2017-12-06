//
//  CYXAVPlayerView.h
//  CYXAVPlayerViewDemo
//
//  Created by 超级腕电商 on 2017/12/5.
//  Copyright © 2017年 超级腕电商. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
typedef NS_ENUM(NSInteger, TouchPlayerViewMode) {
    TouchPlayerViewModeNone, // 轻触
    TouchPlayerViewModeHorizontal, // 水平滑动
    TouchPlayerViewModeUnknow, // 未知
};
@protocol CYXAVPlayerViewDelegate <NSObject>

/**
 进入后台
 */
-(void)enterBackgroundNotification;

/**
 x号按钮点击
 */
-(void)backButtonAction;

@end
@interface CYXAVPlayerView : UIView{
    TouchPlayerViewMode _touchMode;
}
#pragma mark ---property
// AVPlayer 控制视频播放
@property (nonatomic, strong) AVPlayer *player;

// 播放状态
@property (nonatomic, assign) BOOL isPlaying;

// 是否横屏
@property (nonatomic, assign) BOOL isLandscape;

// 是否锁屏
@property (nonatomic, assign) BOOL isLock;
@property (nonatomic,weak) id<CYXAVPlayerViewDelegate> delegate;
#pragma mark ---Method
// 传入视频地址
- (void)updatePlayerWithURL:(NSURL *)url;

// 移除通知
- (void)removeObserveAndNOtification;

// 切换为横屏
- (void)setLandscapeLayout;
// 切换为竖屏
- (void)setProtraitLayout;
// 播放
- (void)play;
// 暂停
- (void)pause;

@end

