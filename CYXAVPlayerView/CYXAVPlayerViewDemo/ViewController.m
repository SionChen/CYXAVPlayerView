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
@interface ViewController ()

@property (nonatomic,strong) UIButton *playerButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.playerButton.frame = CGRectMake(100, 100, 200, 200);
    [self.view addSubview:self.playerButton];
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


@end
