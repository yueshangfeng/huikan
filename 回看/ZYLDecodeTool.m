//
//  ZYLDecodeTool.m
//  回看
//
//  Created by zyl on 16/8/9.
//  Copyright © 2016年. All rights reserved.
//

#import "ZYLDecodeTool.h"

#import "ZYLM3U8Handler.h"
#import "ZYLVideoDownLoader.h"
#import "M3U8SegmentModel.h"

@interface ZYLDecodeTool () <ZYLM3U8HandlerDelegate, ZYLVideoDownLoaderDelegate>

//解码器
@property (strong, nonatomic) ZYLM3U8Handler *handler;

//下载器
@property (strong, nonatomic) ZYLVideoDownLoader *downLoader;

//播放链接
@property (copy, nonatomic) NSString *playUrl;

//定时解码的定时器
@property (strong, nonatomic) NSTimer *decodeTimer;

//标记第一次是否已经创建多M3U8
@property (assign, nonatomic) BOOL isM3U8;

@end

@implementation ZYLDecodeTool

-(instancetype)init {
    self = [super init];
    if (self) {
        //检查是否有缓存，并清空缓存
        //创建缓存路径
//        NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
//        NSString *saveTo = [[pathPrefix stringByAppendingPathComponent:@"Downloads"] stringByAppendingPathComponent:@"moive1"];
//        NSFileManager *fm = [NSFileManager defaultManager];
//        //路径不存在就创建一个
//        BOOL isD = [fm fileExistsAtPath:saveTo];
//        if (isD) {
//            //存在
//            //清空当前的M3U8文件
//            NSArray *subFileArray = [fm subpathsAtPath:saveTo];
//            [subFileArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                BOOL isS = [fm removeItemAtPath:[saveTo stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", obj]] error:nil];
//                if (isS) {
//                    NSLog(@"路径存在清空成功%@", obj);
//                } else {
//                    NSLog(@"路径存在清空失败%@", obj);
//                }
//            }];
//            
//        }
    }
    return self;
}

- (void)handleM3U8Url:(NSString *)urlStr {
    [self.handler praseUrl:urlStr];
    self.playUrl = urlStr;
    self.isM3U8 = NO;
}

#pragma mark - M3U8连接解析失败
- (void)praseM3U8Failed:(ZYLM3U8Handler *)handler {
    [self.delegate decodeFail];
}

#pragma mark - M3U8链接解析成功
- (void)praseM3U8Finished:(ZYLM3U8Handler *)handler {
    //从这里获取解析的TS片段数据
    //解析成功后开始下载
    self.downLoader.playList = handler.playList;
    self.downLoader.oriM3U8Str = handler.oriM3U8Str;
    [self.downLoader startDownloadVideo];
    //解析成功后开启定时器，定时解析和请求播放数据
    [self openDecodeTimer];
}

#pragma mark - 开启循环解码定时器
- (void)openDecodeTimer {
    if (_decodeTimer == nil) {
        NSLog(@"循环解码定时器已经开启");
        //分析定时器的循环时间，这里取一个M3U8时间的一半
        __block NSTimeInterval time = 0;
        [self.downLoader.playList.segmentArray enumerateObjectsUsingBlock:^(M3U8SegmentModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            time += obj.duration;
        }];
        
        time /= self.downLoader.playList.segmentArray.count;
        _decodeTimer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(circleDecode) userInfo:nil repeats:YES];
    } else {
        return;
    }
}

#pragma mark - 循环解码
- (void)circleDecode {
    [self.handler praseUrl:self.playUrl];
}

#pragma mark - 数据下载成功
- (void)videoDownloaderFinished:(ZYLVideoDownLoader *)videoDownloader {
    NSLog(@"数据下载成功");
    
    //文件创建成功开始播放,这里需要建立本地HTTP服务器
    [self.delegate decodeSuccess];
}

#pragma mark - 数据下载失败
- (void)videoDownloaderFailed:(ZYLVideoDownLoader *)videoDownloader {
    NSLog(@"数据下载失败");
    [self.delegate decodeFail];
}

#pragma mark - getter
- (ZYLM3U8Handler *)handler {
    if (_handler == nil) {
        _handler = [[ZYLM3U8Handler alloc] init];
        _handler.delegate = self;
    }
    return _handler;
}

- (ZYLVideoDownLoader *)downLoader {
    if (_downLoader == nil) {
        _downLoader = [[ZYLVideoDownLoader alloc] init];
        _downLoader.delegate = self;
    }
    return _downLoader;
}

@end
