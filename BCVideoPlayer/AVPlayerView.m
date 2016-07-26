//
//  AVPlayerView.m
//  BCVideoPlayer
//
//  Created by Jack on 16/4/28.
//  Copyright © 2016年 毕研超. All rights reserved.
//

#import "AVPlayerView.h"


@implementation AVPlayerView

- (instancetype)initFrame:(CGRect)frame andVideo:(NSURL *)url {

    _videoURL = url;
    
    return [self initWithFrame:frame];

}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
  
    _maskImage = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:_maskImage];
    
    
    _isFristPlay = YES;
    self.smallFrame = frame;
    self.bigFrame = CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    
    self.player = [[AVPlayer alloc] init];
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    [self.layer insertSublayer:_playerLayer atIndex:0];

    
    
    self.maskView = [[playMaskView alloc] initWithFrame:self.bounds];
    
    self.maskView.delegate = self;
    
    [self addSubview:_maskView];
    
    
    
    // 注册退出后台，进入前台时的通知
    [self  addNotification];
    
    
    
    // slider开始滑动事件
    [self.maskView.videoSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    // slider滑动中事件
    [self.maskView.videoSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    // slider结束滑动事件
    [self.maskView.videoSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    
    
    
    [self observeRotating];
    [self setTheProgressOfPlayTime];
    [self setPlayerVideoURL:_videoURL];
    
    
    NSError *error;
    
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    
    // add event handler, for this example, it is `volumeChange:` method
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    systemVolume = volumeViewSlider.value;

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(changeVolume:)];
    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];
    

    

    return self;
    
  
    
}

- (void)volumeChanged:(NSNotification *)notification
{
    
    NSString *valueStr = notification.userInfo[@"AVSystemController_AudioVolumeNotificationParameter"];
    systemVolume = [valueStr floatValue];
    
    [volumeViewSlider setValue:systemVolume animated:YES];
    
}
#pragma mark  监听设备旋转方向


- (void)observeRotating {


    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];



}

- (void)onDeviceOrientationChange{
    
    UIDeviceOrientation orientation             = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    
    [self transformScreenDirection:interfaceOrientation];
    
}


-(void)transformScreenDirection:(UIInterfaceOrientation)direction
{
    
    if (direction == UIInterfaceOrientationPortrait ) {
        
        self.frame = self.smallFrame;
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
        
    }else if(direction == UIInterfaceOrientationLandscapeRight)
    {
        self.frame = self.bigFrame;
        
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}
//设备旋转
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val                  = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}


//设置播放进度和时间
-(void)setTheProgressOfPlayTime
{
    __weak typeof(self) weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        
        //如果是拖拽slider中就不执行.
        
        if (weakSelf.isDragSlider) {
            return ;
        }
        
        float current=CMTimeGetSeconds(time);
        float total=CMTimeGetSeconds([weakSelf.playerItme duration]);
        
        if (current) {
            [weakSelf.maskView.videoSlider setValue:(current/total) animated:YES];
        }
        
        //秒数
        NSInteger proSec = (NSInteger)current%60;
        //分钟
        NSInteger proMin = (NSInteger)current/60;
        
        //总秒数和分钟
        NSInteger durSec = (NSInteger)total%60;
        NSInteger durMin = (NSInteger)total/60;
        weakSelf.maskView.currentTimeLabel.text    = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
        weakSelf.maskView.totalTimeLabel.text      = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
    } ];
}


-(void)setPlayerVideoURL:(NSURL *)url {


    //将之前的监听时间移除掉。
    [self.playerItme removeObserver:self forKeyPath:@"status"];
    [self.playerItme removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItme removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItme removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    self.playerItme = nil;
    
    self.playerItme = [AVPlayerItem playerItemWithURL:url];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItme];
    // AVPlayer播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
    // 监听播放状态
    [self.playerItme addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 监听loadedTimeRanges属性
    [self.playerItme addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    // Will warn you when your buffer is empty
    [self.playerItme addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    // Will warn you when your buffer is good to go again.
    [self.playerItme addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    
    
    self.playState = BCPlayerStatePause;
    [self.maskView.activity startAnimating];

    
    [self thumbnailImageRequest:10];

}

#pragma mark - slider事件

// slider开始滑动事件
- (void)progressSliderTouchBegan:(UISlider *)slider
{
    self.isDragSlider = YES;
}

// slider滑动中事件
- (void)progressSliderValueChanged:(UISlider *)slider
{
    CGFloat total   = (CGFloat)self.playerItme.duration.value / self.playerItme.duration.timescale;
    
    CGFloat current = total*slider.value;
    //秒数
    NSInteger proSec = (NSInteger)current%60;
    //分钟
    NSInteger proMin = (NSInteger)current/60;
    self.maskView.currentTimeLabel.text    = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
}

// slider结束滑动事件
- (void)progressSliderTouchEnded:(UISlider *)slider
{
    //计算出拖动的当前秒数
    CGFloat total           = (CGFloat)self.playerItme.duration.value / self.playerItme.duration.timescale;
    
    NSInteger dragedSeconds = floorf(total * slider.value);
    
    //转换成CMTime才能给player来控制播放进度
    
    CMTime dragedCMTime     = CMTimeMake(dragedSeconds, 1);
    
    [self endSlideTheVideo:dragedCMTime];
}

// 滑动结束视频跳转
- (void)endSlideTheVideo:(CMTime)dragedCMTime
{
    
    [self.player pause];
    [self.maskView.activity startAnimating];
    
    [_player seekToTime:dragedCMTime completionHandler:^(BOOL finish){
        
        // 如果点击了暂停按钮
        [self.maskView.activity stopAnimating];
        if (self.isPauseByUser) {
            //NSLog(@"已暂停");
            self.isDragSlider = NO;
            return ;
        }
       
        if ((self.maskView.progressView.progress - self.maskView.videoSlider.value) > 0.01) {
            [self.maskView.activity stopAnimating];
            [self.player play];
        }
        else
        {
            [self bufferingSomeSecond];
            
        }
        self.isDragSlider = NO;
    }];
    
    
    
}
#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == self.playerItme) {
        if ([keyPath isEqualToString:@"status"]) {
            
            if (self.player.status == AVPlayerStatusReadyToPlay) {
                
                self.playState = BCPlayerStatePause;
                
                [self.maskView.activity stopAnimating];
                
            } else if (self.player.status == AVPlayerStatusFailed){
               
                [self.maskView.activity startAnimating];
            }
        } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            
            NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
            CMTime duration             = self.playerItme.duration;
            CGFloat totalDuration       = CMTimeGetSeconds(duration);
            [self.maskView.progressView setProgress:timeInterval / totalDuration animated:NO];
            
        }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            
            
            // 当缓冲是空的时候
            if (self.playerItme.playbackBufferEmpty) {
                self.playState = BCPlayerStateBuffering;
                [self bufferingSomeSecond];
            }
            
        }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            // 当缓冲好的时候
            NSLog(@"playbackLikelyToKeepUp:%d",self.playerItme.playbackLikelyToKeepUp);
            
            if (self.playerItme.playbackLikelyToKeepUp){
                NSLog(@"playbackLikelyToKeepUp");
                self.playState = BCPlayerStatePause;
            }
        }
    }
}
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (void)bufferingSomeSecond
{
    
    [self.maskView.activity startAnimating];
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    static BOOL isBuffering = NO;
    if (isBuffering) {
        return;
    }
    isBuffering = YES;
    
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.player pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 如果此时用户已经暂停了，则不再需要开启播放了
        if (self.isPauseByUser) {
            isBuffering = NO;
            return;
        }
        
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        isBuffering = NO;
        
        //播放缓冲区已满的时候 在播放否则继续缓冲
        //         [self.player play];
        
        
        /** 是否缓冲好的标准 （系统默认是1分钟。不建议用 ）*/
        //self.playerItme.isPlaybackLikelyToKeepUp
        
        if ((self.maskView.progressView.progress - self.maskView.videoSlider.value) > 0.01) {
            
            self.playState = BCPlayerStatePause;
            [_player play];
        }
        else
        {
            [self bufferingSomeSecond];
        }
    });
}


//旋转时调整尺寸
-(void)layoutSubviews
{
    [super layoutSubviews];
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.playerLayer.frame = self.bounds;
    self.maskView.frame = self.bounds;
    
}

- (void)addNotification {

    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];


}
#pragma mark - NSNotification Action

// 播放完了
- (void)moviePlayDidEnd:(NSNotification *)notification
{
    
    NSLog(@"播放完了");
    
    
    [_player seekToTime:CMTimeMake(0, 1) completionHandler:^(BOOL finish){
        
        [self.maskView.videoSlider setValue:0.0 animated:YES];
        self.maskView.currentTimeLabel.text = @"00:00";
        
    }];
    
    self.playState = BCPlayerStateFinished;
    self.maskView.startBtn.selected = NO;
}

// 应用退到后台
- (void)appDidEnterBackground
{
    
    
    
    [_player pause];
    self.playState = BCPlayerStatePause;
   
}

// 应用进入前台
- (void)appDidEnterPlayGround
{
    
   
    
    if (self.playState == BCPlayerStatePause &&_isFristPlay == NO) {
        
        [_player play];
    }
    
    
    _isFristPlay = NO;
}


#pragma mark  maskView的代理事件
- (void)clickMaskViewButton:(UIButton *)btn {

    if (btn.tag == 100) {//开始
        
        btn.selected = !btn.selected;
        if (btn.selected) {
            self.isPauseByUser = NO;
            [_player play];
            
            if (self.maskImage.image) {
                self.maskImage.image = nil;
            }
            
            self.playState = BCPlayerStatePlaying;
        } else {
            [_player pause];
            self.isPauseByUser = YES;
            self.playState = BCPlayerStatePause;
        }
        
        [self delayMaskView];
    
    
    
    } else {//全屏
        
    
        btn.selected = !btn.selected;
        [self interfaceOrientation:(btn.selected==YES)?UIInterfaceOrientationLandscapeRight:UIInterfaceOrientationPortrait];
        

    
    
    }
    

}
#pragma mark  手势相关处理
- (void)changeVolume:(UIPanGestureRecognizer *)pan {
    CGPoint veloctyPoint = [pan velocityInView:self];
    
    if (pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged) {
        CGFloat x = fabs(veloctyPoint.x);
        CGFloat y = fabs(veloctyPoint.y);
        
        
        if (x > y) {//水平
            
            [UIScreen mainScreen].brightness += veloctyPoint.x/10000;
            
           

            
        } else if (x < y) {//垂直
            
            systemVolume -= veloctyPoint.y/10000;
            [volumeViewSlider setValue:systemVolume animated:YES];
            [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
            
            
        }
        
        
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        [self progressSliderValueChanged:self.maskView.videoSlider];
       
    }
    
    
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {

 UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    if (orientation == UIDeviceOrientationPortrait) {
        
        return NO;
        
    } else {
    
    
        return YES;
    
    }

}

//缩略图
-(void)thumbnailImageRequest:(CGFloat )timeBySecond{
    //创建URL
    NSURL *url = _videoURL;
    //根据url创建AVURLAsset
    AVURLAsset *urlAsset=[AVURLAsset assetWithURL:url];
    //根据AVURLAsset创建AVAssetImageGenerator
    AVAssetImageGenerator *imageGenerator=[AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    /*截图
     * requestTime:缩略图创建时间
     * actualTime:缩略图实际生成的时间
     */
    NSError *error=nil;
    CMTime time=CMTimeMakeWithSeconds(timeBySecond, 10);//CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要活的某一秒的第几帧可以使用CMTimeMake方法)
    CMTime actualTime;
    CGImageRef cgImage= [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    if(error){
        NSLog(@"截取视频缩略图时发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    CMTimeShow(actualTime);
    UIImage *image=[UIImage imageWithCGImage:cgImage];//转化为UIImage
  
    
    self.maskImage.image = image;
    CGImageRelease(cgImage);
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

#pragma mark  隐藏和显示maskView
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    self.maskView.hidden = !self.maskView.hidden;

    
    [self delayMaskView];
    

}

- (void)delayMaskView {

    if (!self.maskView.hidden) {
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            self.maskView.hidden = YES;
        });
    }

}
@end
