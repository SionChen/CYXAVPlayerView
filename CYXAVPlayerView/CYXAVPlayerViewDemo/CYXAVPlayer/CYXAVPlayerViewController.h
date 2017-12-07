//
//  CYXAVPlayerViewController.h
//  CYXAVPlayerViewDemo
//
//  Created by 超级腕电商 on 2017/12/6.
//  Copyright © 2017年 超级腕电商. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CYXAVPlayerView;
@interface CYXAVPlayerViewController : UIViewController
/**
 播放器
 */
@property (nonatomic,strong) CYXAVPlayerView *playerView;
/**
 playerView初始frame
 */
@property (nonatomic,assign) CGRect playerViewRect;
@end
