//
//  playMaskView.m
//  BCVideoPlayer
//
//  Created by Jack on 16/4/28.
//  Copyright © 2016年 毕研超. All rights reserved.
//

#import "playMaskView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
@implementation playMaskView


- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        
        
        self.hidden = NO;
        
        //缩略图
       
        
        self.topImageView = [[UIImageView alloc]init];
        self.topImageView.userInteractionEnabled = YES;
        [self addSubview:_topImageView];
        
        self.bottomImageView = [[UIImageView alloc]init];
        self.bottomImageView.userInteractionEnabled = YES;
        [self addSubview:_bottomImageView];
        
        //提示
        self.activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self addSubview:_activity];
        
        
        [self initView];
        
        
        
    }


    return self;

}

- (void)initView {
    
    
    
    
    
    //开始按钮
    self.startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _startBtn.frame = CGRectMake(0, 0, 50, 50);
    _startBtn.tag = 100;
    [self.startBtn setImage:[UIImage imageNamed:@"kr-video-player-play"] forState:UIControlStateNormal];
    [self.startBtn setImage:[UIImage imageNamed:@"kr-video-player-pause"]forState:UIControlStateSelected];

    
    //全屏按钮
    self.fullScreenBtn = [[UIButton alloc]init];
    self.fullScreenBtn.tag = 200;
    [self.fullScreenBtn setImage:[UIImage imageNamed:@"kr-video-player-fullscreen"] forState:UIControlStateNormal];
    
    //左侧时间条
    self.currentTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 10,60, 30)];
    self.currentTimeLabel.text = @"00:00";
    self.currentTimeLabel.textColor = [UIColor whiteColor];
    self.currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.currentTimeLabel.font = [UIFont systemFontOfSize:15];
    
    //右侧时间条
    self.totalTimeLabel = [[UILabel alloc]init];
    self.totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.totalTimeLabel.font = [UIFont systemFontOfSize:15];
    self.totalTimeLabel.textColor = [UIColor whiteColor];
    self.totalTimeLabel.text = @"00:00";
    
    
    
    //进度条
    self.progressView = [[UIProgressView alloc]init];
    self.progressView.progressTintColor    = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
    self.progressView.trackTintColor       = [UIColor clearColor];
    
   
    
    // 设置slider
    self.videoSlider = [[UISlider alloc]init];
    [self.videoSlider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    self.videoSlider.minimumTrackTintColor = [UIColor whiteColor];
    self.videoSlider.maximumTrackTintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.3];

    
    [_bottomImageView addSubview:self.startBtn];
    [_bottomImageView addSubview:self.fullScreenBtn];
    [_bottomImageView addSubview:self.currentTimeLabel];
      [_bottomImageView addSubview:self.totalTimeLabel];
    [_bottomImageView addSubview:self.progressView];
    [_bottomImageView addSubview:self.videoSlider];
    
    
    [self.fullScreenBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    // 播放按钮点击事件
    [self.startBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
}


- (void)layoutSubviews {

    [super layoutSubviews];

    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    self.topImageView.frame = CGRectMake(0, 0, width, 50);
    self.bottomImageView.frame = CGRectMake(0, height - 50, width, 50);
    
    self.fullScreenBtn.frame = CGRectMake(width - 50, 0, 50, 50);
    
    
    CGFloat progressWidth = width - 2 * (self.startBtn.frame.size.width+self.currentTimeLabel.frame.size.width);
    
    self.progressView.frame = CGRectMake(0,0,progressWidth,20);
    self.progressView.center = CGPointMake(width/2, 25);
    self.totalTimeLabel.frame = CGRectMake(width-110,10,60,30);
    self.videoSlider.frame = self.progressView.frame;
    self.activity.center = CGPointMake(width/2, height/2);

}


#pragma mark  各种点击事件

- (void)clickButton:(UIButton *)btn {

    [self.delegate clickMaskViewButton:btn];

}

@end
