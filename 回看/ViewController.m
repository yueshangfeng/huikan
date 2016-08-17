//
//  ViewController.m
//  回看
//
//  Created by zyl on 16/7/25.
//  Copyright © 2016年 . All rights reserved.
// http://111.206.23.22:55336/tslive/c25_ct_btv2_btvwyHD_smooth_t10/c25_ct_btv2_btvwyHD_smooth_t10.m3u8?key=023621c1e5e50473f2d23479feb5630dc&qd_src=ih5&qd_tm=1432691425321&qd_ip=111.206.82.146&qd_sc=6aab50fbbe712188ed18d0f413c5e94c&callback=QV.http.__callba

// http://127.0.0.1:9479/moive1/movie.m3u8

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "ZYLDecodeTool.h"

@interface ViewController () <ZYLDecodeToolDelegate>

@property (strong, nonatomic) AVPlayer *player;

@property (strong, nonatomic) AVPlayerItem *playerItem;

@property (copy, nonatomic) NSString *playerUrl;

@property (strong, nonatomic) AVPlayerLayer *playerLayer;

@property (strong, nonatomic) UIView *playerView;

@property (strong, nonatomic) AVPlayerViewController *playerVC;

@property (strong, nonatomic) ZYLDecodeTool *decodeTool;

@property (strong, nonatomic) UIButton *downloadButton;

@property (strong, nonatomic) UIButton *playButton;

@property (strong, nonatomic) UILabel *indiLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置UI
    [self setUI];
    
    //创建播放器
    [self createPlayer];
    
    /*
     第一种情况就是直接拿到播放的回看M3U8链接直接播放即可
     */
    
    /*
     第二种情况要调整回看的进度、获取节目总时长
     */
    
    /*
     第三种是下载直播节目
     */
}

#pragma mark - 设置UI
- (void)setUI {
    //创建下载和播放按钮
    self.downloadButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 400, 80, 30)];
    [self.downloadButton setTitle:@"下载" forState:UIControlStateNormal];
    [self.downloadButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.downloadButton addTarget:self action:@selector(downloadButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.downloadButton];
    
    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(140, 400, 80, 30)];
    [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
    [self.playButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playButton];
    
    self.indiLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 450, 200, 30)];
    self.indiLabel.backgroundColor = [UIColor lightGrayColor];
    self.indiLabel.textColor = [UIColor blackColor];
    [self.view addSubview:self.indiLabel];
    
}

#pragma mark - 下载直播
- (void)downloadButtonClick {
    //解析M3U8
    [self.decodeTool handleM3U8Url:self.playerUrl];
}

#pragma mark - 播放下载的直播
- (void)playButtonClick {
    if (self.player == nil) {
        //没有创建播放器
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"http://127.0.0.1:9479/moive1/movie.m3u8"]];
        //添加监听
        [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * 9.0 / 16.0);
        self.playerView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.playerLayer.frame), CGRectGetHeight(self.playerLayer.frame))];
        self.playerView.backgroundColor = [UIColor blackColor];
        [self.playerView.layer addSublayer:self.playerLayer];
        [self.view addSubview:self.playerView];
    } else {
        //已经创建过播放器
        NSLog(@"已经创建过播放器，继续播放");
    }
}

#pragma mark - 创建播放器***********************************************************
- (void)createPlayer {
    //self.playerUrl = [NSURL URLWithStrinhttp://cctv2.vtime.cntv.wscdns.com:8000/live/no/204_/seg0/index.m3u8?begintimeback=1661830&AUTH=Kpr0K6wX/0ZYn180eui2JMOOuHdr0Om+VGS5/R3m2JEuh/gdC6SAlMiNoeVNeoEMkL9QGOkoLDoSl1s4Ckg+VQ==g:@""];
    
    //self.playerUrl = [NSURL URLWithString:@"http://cctv2.vtime.cntv.wscdns.com:8000/live/no/204_/seg0/index.m3u8?AUTH=axtKYlWMiWCiypWxMYQMVAIriPIHqGnf6BqnjPLIwhpF8c+dGNOaiD2lKw7o2W3gRjLkjqkGiQ/rXlTAC/894w==&begintimeabs=1469509516000"];//对话栏目
    self.playerUrl = @"http://111.206.23.22:55336/tslive/c25_ct_btv2_btvwyHD_smooth_t10/c25_ct_btv2_btvwyHD_smooth_t10.m3u8?key=023621c1e5e50473f2d23479feb5630dc&qd_src=ih5&qd_tm=1432691425321&qd_ip=111.206.82.146&qd_sc=6aab50fbbe712188ed18d0f413c5e94c&callback=QV.http.__callba";
    
    //TS:http://cctv2.vtime.cntv.wscdns.com:8000/cache/204_/seg0/index146950917-146950917.ts?AUTH=Nn1wtNC4CjHKM/5eOVIfZ7RGTKxDnMsBkA5riRsWJc1Trz/3OU7OPW9ijSizrRXqjfX0jYAQ7xHdZdV3BwbSsQ==
    
}

#pragma mark - 监听回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"loadedTimeRanges"]){
        
    }else if ([keyPath isEqualToString:@"status"]){
        //获取播放状态
        if (playerItem.status == AVPlayerItemStatusReadyToPlay){
            [self.player play];
            NSLog(@"开始播放");
        } else{
            NSLog(@"播放失败%@", playerItem.error);
        }
    }
    
}

#pragma mark - getter
- (ZYLDecodeTool *)decodeTool {
    if (_decodeTool == nil) {
        _decodeTool = [[ZYLDecodeTool alloc] init];
        _decodeTool.delegate = self;
    }
    return _decodeTool;
}

#pragma mark - ZYLDecodeToolDelegate
#pragma mark - 解码成功
- (void)decodeSuccess {
        NSLog(@"解码成功");
    
    //显示一共下载了多少文件
    NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *saveTo = [[pathPrefix stringByAppendingPathComponent:@"Downloads"] stringByAppendingPathComponent:@"moive1"];
    NSFileManager *fm = [NSFileManager defaultManager];
    //路径不存在就创建一个
    BOOL isD = [fm fileExistsAtPath:saveTo];
    if (isD) {
        //存在
        //清空当前的M3U8文件
        NSArray *subFileArray = [fm subpathsAtPath:saveTo];
        NSMutableArray *tsArray = [[NSMutableArray alloc] init];
        [subFileArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[NSString stringWithFormat:@"%@", obj] hasSuffix:@".ts"]) {
                [tsArray addObject:obj];
            }
        }];
        self.indiLabel.text = [NSString stringWithFormat:@"一共下载了%ld个文件", (long)tsArray.count];
    }
}

#pragma mark - 解码失败
- (void)decodeFail {
    NSLog(@"解码失败");
}



@end
