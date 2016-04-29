//
//  playMaskView.h
//  BCVideoPlayer
//
//  Created by Jack on 16/4/28.
//  Copyright © 2016年 毕研超. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlayMaskViewDelegate <NSObject>

@required

- (void)clickMaskViewButton:(UIButton *)btn;

@end

@interface playMaskView : UIView
{
    float systemVolume;//系统音量值
    CGPoint startPoint;//起始位置
    UISlider* volumeViewSlider;


}
/** 开始播放按钮 */
@property (strong, nonatomic)  UIButton *startBtn;
/** 当前播放时长label */
@property (strong, nonatomic)  UILabel *currentTimeLabel;
/** 视频总时长label */
@property (strong, nonatomic)  UILabel *totalTimeLabel;
/** 缓冲进度条 */
@property (strong, nonatomic)  UIProgressView *progressView;
/** 滑杆 */
@property (strong, nonatomic)  UISlider *videoSlider;
/** 全屏按钮 */
@property (strong, nonatomic)  UIButton *fullScreenBtn;
@property (strong, nonatomic)  UIButton *lockBtn;
/** 音量进度 */
@property (nonatomic,strong) UIProgressView *volumeProgress;

/** 系统提示 */
@property (nonatomic,strong)UIActivityIndicatorView *activity;


/** bottomView*/
@property (strong, nonatomic  )  UIImageView *bottomImageView;
/** topView */
@property (strong, nonatomic  )  UIImageView *topImageView;
/** bottom渐变层*/
@property (nonatomic, strong) CAGradientLayer *bottomGradientLayer;
/** top渐变层 */
@property (nonatomic, strong) CAGradientLayer *topGradientLayer;

@property (nonatomic, weak) id<PlayMaskViewDelegate>delegate;
@end
