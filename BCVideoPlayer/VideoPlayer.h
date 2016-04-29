//
//  VideoPlayer.h
//  BCVideoPlayer
//
//  Created by Jack on 16/4/28.
//  Copyright © 2016年 毕研超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface VideoPlayer : NSObject


/**
    这是使用 MPMoviePlayerViewController 来实现的播放器，但是在iOS9.0以后被拒绝
 */


+ (MPMoviePlayerViewController *)playVideoFromMPPlayerViewController:(NSURL *)url;


/**
 这是使用AVPlayerViewController来实现的播放器，和MPMoviePlayerViewController基本类似，推荐使用
 */
+ (AVPlayerViewController *)playVideoFromAVPlayerViewController:(NSURL *)url;
@end
