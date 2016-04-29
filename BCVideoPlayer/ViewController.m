//
//  ViewController.m
//  BCVideoPlayer
//
//  Created by Jack on 16/4/28.
//  Copyright © 2016年 毕研超. All rights reserved.
//参考http://www.cnblogs.com/kenshincui/p/4186022.html#video

#import "ViewController.h"
#import "VideoPlayer.h"
#import "AVPlayerView.h"
#define videoUrl  [NSURL URLWithString:@"http://baobab.wdjcdn.com/1455782903700jy.mp4"]
@interface ViewController ()<NSURLSessionDownloadDelegate>
{

    MPMoviePlayerController *moviePlayer;
    NSURLSessionDownloadTask *task; //下载任务
    NSData *downloadData;           //暂存下载的数据
    NSURLSession *urlSession;
}

@property (nonatomic, strong) NSString *path;//存储路径

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    AVPlayerView *pp = [[AVPlayerView alloc] initFrame:CGRectMake(10, 100, 300, 300) andVideo:videoUrl];
  pp.backgroundColor = [UIColor grayColor];
    
    [self.view addSubview:pp];
    
    //开启下载任务,本地没有就请求网络，有则加载本地数据
   //[self playVideo:videoUrl];
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    //使用MPMoviePlayerViewController,注意和MPMoviePlayerController的区别
    
   // [self presentMoviePlayerViewControllerAnimated:[VideoPlayer playVideoFromMPPlayerViewController:videoUrl]];

    //AVPlayerViewController的使用
    
   // [self presentViewController:[VideoPlayer playVideoFromAVPlayerViewController:videoUrl] animated:YES completion:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    


}


#pragma mark MPMoviePlayerController 的使用

- (void)playVideoFromMPPlayerController:(NSURL *)url {
    
    //简单设置，这里类似于一个小窗口,当然它还有很多其它设置，可以自行查看
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    moviePlayer.view.frame = CGRectMake(100, 200, 200, 200);
    [self.view addSubview:moviePlayer.view];
    [moviePlayer play];

    
    //生成缩略图
//     [self thumbnailImageRequest];
//    
//    //监听截图通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlayerThumbnailRequestFinished:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:moviePlayer];
}

-(void)thumbnailImageRequest{
  
    //获取13.0s、21.5s的缩略图
    [moviePlayer requestThumbnailImagesAtTimes:@[@13.0,@21.5] timeOption:MPMovieTimeOptionNearestKeyFrame];
}
-(void)mediaPlayerThumbnailRequestFinished:(NSNotification *)notification{
    
    NSLog(@"视频截图完成.");
    UIImage *image = notification.userInfo[MPMoviePlayerThumbnailImageKey];

    //保存图片到相册,你也可以保存到其它地方
    //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}



#pragma mark 断点下载相关
//文件路径
- (NSString *)path {

    if (!_path) {
        
        NSString *pathStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        _path = [pathStr stringByAppendingPathComponent:[videoUrl lastPathComponent]];
    
    }

    return _path;
}
//缓存没有再请求网络

- (void)playVideo:(NSURL *)url {
    
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:self.path];
    
    if (data) {
        
        [self playVideoFromMPPlayerController:[NSURL fileURLWithPath:self.path]];
        
        NSLog(@"从本地加载");
        
    } else {
        
        
        [self playVideoFromMPPlayerController:url];
        
        //这里下载任务需要异步，这里不写
        [self downloadVideoFromUrl:videoUrl];
        
        NSLog(@"网络");
    }
    
    
    
    
}

//下载
- (void)downloadVideoFromUrl:(NSURL *)url {

    NSURLRequest *videoRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
  
    NSURLSessionConfiguration *conFiguation = [NSURLSessionConfiguration defaultSessionConfiguration];


    urlSession = [NSURLSession sessionWithConfiguration:conFiguation delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    task = [urlSession downloadTaskWithRequest:videoRequest];
    
    

}

#pragma mark NSURLSession 代理

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
   
    NSLog(@"下载完成");
    
    CGFloat total = [[[NSFileManager defaultManager] attributesOfItemAtPath:[location path] error:nil] fileSize];
    NSLog(@"文件总大小为  %2.1fM",total/(1000 * 1000));
    
    //这里会默认将数据放在tem文件夹下，所以需要拷贝到自己想要的文件夹下
    [[NSFileManager defaultManager] copyItemAtURL:location toURL:[NSURL fileURLWithPath:self.path] error:nil];
    
    
   
    [urlSession finishTasksAndInvalidate];
     urlSession = nil;
    
    
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    
    CGFloat progress = (CGFloat)totalBytesWritten / totalBytesExpectedToWrite;
    
   
    
       NSLog(@"%2.1f%@",progress * 100,@"%");
    
}


- (void)clearVideoCacheFromDisk {


    [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
    
    NSLog(@"清除缓存成功");

}

#pragma mark 点击事件
- (IBAction)start:(id)sender {
    
    [task resume];
}
- (IBAction)pause:(id)sender {
    
    NSLog(@"暂停下载");
    [task cancelByProducingResumeData:^(NSData *resumeData) {
        downloadData = resumeData;
        task = nil;
    }];

    
}
- (IBAction)contiune:(id)sender {
    
    NSLog(@"继续下载");
    if (!task) {
        if (downloadData) {
            task = [urlSession downloadTaskWithResumeData:downloadData];
        }
        else{
            task = [urlSession downloadTaskWithURL:videoUrl];
        }
    }
    [task resume];

    
}
- (IBAction)clearDisk:(id)sender {
    
    [self clearVideoCacheFromDisk];
    
}
@end
