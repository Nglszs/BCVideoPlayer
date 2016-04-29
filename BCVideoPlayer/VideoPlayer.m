//
//  VideoPlayer.m
//  BCVideoPlayer
//
//  Created by Jack on 16/4/28.
//  Copyright © 2016年 毕研超. All rights reserved.
//

#import "VideoPlayer.h"

@implementation VideoPlayer

//此播放器与MPMoviePlayerController相比，他是全屏的，配合presentMoviePlayerViewControllerAnimated:使用
+ (MPMoviePlayerViewController *)playVideoFromMPPlayerViewController:(NSURL *)url {

    MPMoviePlayerViewController *playerVieController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    
    return playerVieController;



}

+ (AVPlayerViewController *)playVideoFromAVPlayerViewController:(NSURL *)url {


    AVPlayerViewController *avplayerController = [[AVPlayerViewController alloc] init];
    avplayerController.player = [[AVPlayer alloc] initWithURL:url];
    //aa.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [avplayerController.player play];
    
    return avplayerController;




}
@end
