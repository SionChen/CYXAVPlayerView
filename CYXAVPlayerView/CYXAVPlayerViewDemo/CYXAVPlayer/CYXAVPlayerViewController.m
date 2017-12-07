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
#import "RotationScreen.h"
#import "AppDelegate.h"
@interface CYXAVPlayerViewController ()<CYXAVPlayerViewDelegate>


/**
 playerView初始superView
 */
@property (nonatomic,strong) UIView *playerViewSuperView;

/**
 playerView初始delegate
 */
@property (nonatomic,weak) id<CYXAVPlayerViewDelegate> playerViewdelegate;
@end

@implementation CYXAVPlayerViewController
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewWillAppear:(BOOL)animated{
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.allowRotate = 1;
}
-(void)viewWillDisappear:(BOOL)animated{
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.allowRotate = 0;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    self.view.backgroundColor = [UIColor blackColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [self initViews];
}

-(void)initViews{
    //self.playerViewRect = self.playerView.frame;
    self.playerViewSuperView = self.playerView.superview;
    self.playerViewdelegate = self.playerView.delegate;
    
    
    self.playerView.frame = self.view.bounds;
    self.playerView.delegate = self;
    self.playerView.backButton.hidden = NO;
    [self.view addSubview:self.playerView];
    
}
- (void)statusBarOrientationChange:(NSNotification *)notification
{
    self.playerView.frame = self.view.bounds;
}
#pragma mark ---CYXAVPlayerViewDelegate
-(void)enterBackgroundNotification{
    //[self dismissViewControllerAnimated:NO completion:nil];
}
-(void)backButtonAction{
    NSLog(@"%f ",self.playerViewRect.origin.y);
    [self.view removeAllSubviews];
    
    self.playerView.frame = self.playerViewRect;
    [self.playerViewSuperView addSubview:self.playerView];
    self.playerView.delegate = self.playerViewdelegate;
    self.playerView.backButton.hidden = YES;
    [self dismissViewControllerAnimated:NO completion:nil];
}
-(void)fullScreenButtonAction{
    if ([RotationScreen isOrientationLandscape]) { // 如果是横屏，
        [RotationScreen forceOrientation:(UIInterfaceOrientationPortrait)]; // 切换为竖屏
    } else {
        [RotationScreen forceOrientation:(UIInterfaceOrientationLandscapeRight)]; // 否则，切换为横屏
    }
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
