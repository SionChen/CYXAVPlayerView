//
//  CYXAVPlayerViewController.m
//  CYXAVPlayerViewDemo
//
//  Created by 超级腕电商 on 2017/12/6.
//  Copyright © 2017年 超级腕电商. All rights reserved.
//

#import "CYXAVPlayerViewController.h"
#import "CYXAVPlayerView.h"
#import "UIView+Size.h"
@interface CYXAVPlayerViewController ()<CYXAVPlayerViewDelegate>

/**
 播放器
 */
@property (nonatomic,strong) CYXAVPlayerView *playerView;
@end

@implementation CYXAVPlayerViewController
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [self initViews];
    NSURL *url = [NSURL URLWithString:@"http://flv2.bn.netease.com/videolib3/1512/18/gLBNm0789/SD/gLBNm0789-mobile.mp4"];
    [self.playerView updatePlayerWithURL:url];
}
-(void)initViews{
    self.playerView.frame = self.view.bounds;
    [self.view addSubview:self.playerView];
}
- (void)statusBarOrientationChange:(NSNotification *)notification
{
    self.playerView.frame = self.view.bounds;
}
#pragma mark ---CYXAVPlayerViewDelegate
-(void)enterBackgroundNotification{
    [self dismissViewControllerAnimated:NO completion:nil];
}
-(void)backButtonAction{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent; // 白色的
}
// 2. 横屏时显示 statusBar
- (BOOL)prefersStatusBarHidden {
    return NO; // 显示
}

// 3. 设置隐藏动画
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

#pragma mark ---G
-(CYXAVPlayerView*)playerView{
    if(!_playerView){
        _playerView = [[CYXAVPlayerView alloc] initWithFrame:CGRectZero];
        _playerView.delegate = self;
    }
    return _playerView;
}

@end
