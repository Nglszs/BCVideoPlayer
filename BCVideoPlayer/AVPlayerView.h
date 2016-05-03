//
//  AVPlayerView.h
//  BCVideoPlayer
//
//  Created by Jack on 16/4/28.
//  Copyright © 2016年 毕研超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "playMaskView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
typedef NS_ENUM(NSInteger,PlayState){
    
    BCPlayerStateBuffering,
    BCPlayerStatePlaying,
    BCPlayerStateFinished,
    BCPlayerStatePause
};

@interface AVPlayerView : UIView<PlayMaskViewDelegate,UIGestureRecognizerDelegate>
{
    float systemVolume;//系统音量值
    CGPoint startPoint;//起始位置
    UISlider* volumeViewSlider;
}
@property (nonatomic, strong) NSURL *videoURL;
@property(nonatomic,strong)AVPlayer *player;
@property(nonatomic,strong)AVPlayerItem *playerItme;
@property(nonatomic,strong)AVPlayerLayer *playerLayer;
@property(nonatomic,assign)CGRect smallFrame;
@property(nonatomic,assign)CGRect bigFrame;

@property(nonatomic,strong)playMaskView *maskView;
@property(nonatomic,assign)PlayState playState;
@property(nonatomic,assign)BOOL isDragSlider;
/** 是否被用户暂停 */
@property (nonatomic,assign) BOOL isPauseByUser;
@property (nonatomic,assign) BOOL isFristPlay;



@property (nonatomic, strong) UIImageView *maskImage;
- (instancetype)initFrame:(CGRect)frame andVideo:(NSURL*)url;
@end
