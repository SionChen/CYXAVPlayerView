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
@optional
/**
 进入后台
 */
-(void)enterBackgroundNotification;

/**
 进入前台
 */
-(void)enterForegroundNotification;
/**
 x号按钮点击
 */
-(void)backButtonAction;

/**
 全屏按钮点击
 */
-(void)fullScreenButtonAction;


@end
@interface CYXAVPlayerView : UIView{
    TouchPlayerViewMode _touchMode;
}
#pragma mark ---property
// AVPlayer 控制视频播放
@property (nonatomic, strong) AVPlayer *player;
/**
 关闭按钮
 */
@property (nonatomic,strong) UIButton *backButton;

// 播放状态
@property (nonatomic, assign) BOOL isPlaying;

// 是否横屏
@property (nonatomic, assign) BOOL isLandscape;

// 是否锁屏
@property (nonatomic, assign) BOOL isLock;
@property (nonatomic,weak) id<CYXAVPlayerViewDelegate> delegate;

/**
 是否是第一次播放
 */
@property (nonatomic,assign) BOOL isFirstPlay;
#pragma mark ---Method
// 传入视频地址
- (void)updatePlayerWithURL:(NSURL *)url;

// 移除通知
- (void)removeObserveAndNOtification;

// 播放
- (void)play;
// 暂停
- (void)pause;

@end

