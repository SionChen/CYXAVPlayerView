//
//  ViewController.m
//  CYXAVPlayerViewDemo
//
//  Created by 超级腕电商 on 2017/12/5.
//  Copyright © 2017年 超级腕电商. All rights reserved.
//

#import "ViewController.h"
#import "CYXAVPlayerView.h"
#import "CYXAVPlayerViewController.h"
#import "UIView+Size.h"
@interface ViewController ()<CYXAVPlayerViewDelegate>

@property (nonatomic,strong) UIButton *playerButton;
@property (nonatomic,strong) CYXAVPlayerView *playerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //self.playerButton.frame = CGRectMake(100, 100, 200, 200);
    //[self.view addSubview:self.playerButton];
    [self initViews];
    NSURL *url = [NSURL URLWithString:@"http://flv2.bn.netease.com/videolib3/1512/18/gLBNm0789/SD/gLBNm0789-mobile.mp4"];
    [self.playerView updatePlayerWithURL:url];
}

-(void)initViews{
    self.playerView.frame = CGRectMake(0, 20, self.view.width, 210);
    [self.view addSubview:self.playerView];
}
#pragma mark ---CYXAVPlayerViewDelegate
-(void)fullScreenButtonAction{
    CGRect playerRect = self.playerView.frame;
    [UIView animateWithDuration:0.2 animations:^{
        self.playerView.frame = self.view.bounds;
    } completion:^(BOOL finished) {
        CYXAVPlayerViewController * viewController = [[CYXAVPlayerViewController alloc] init];
        viewController.playerView = self.playerView;
        viewController.playerViewRect = playerRect;
        [self presentViewController:viewController animated:NO completion:nil];
    }];
}
#pragma mark ---Method
-(void)presentToAVPlayerViewController{
    CYXAVPlayerViewController * viewController = [[CYXAVPlayerViewController alloc] init];
    [self presentViewController:viewController animated:NO completion:nil];
}

#pragma mark ---G
-(UIButton*)playerButton{
    if(!_playerButton){
        _playerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playerButton setTitle:@"点击播放" forState:UIControlStateNormal];
        [_playerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_playerButton addTarget:self action:@selector(presentToAVPlayerViewController) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playerButton;
}
-(CYXAVPlayerView*)playerView{
    if(!_playerView){
        _playerView = [[CYXAVPlayerView alloc] initWithFrame:CGRectZero];
        _playerView.delegate =self;
        _playerView.backButton.hidden = YES;
    }
    return _playerView;
}



@end
