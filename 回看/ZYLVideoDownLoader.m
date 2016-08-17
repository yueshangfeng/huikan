//
//  ZYLVideoDownLoader.m
//  回看
//
//  Created by zyl on 16/8/10.
//  Copyright © 2016年 . All rights reserved.
//

#import "ZYLVideoDownLoader.h"

#import "M3U8SegmentModel.h"
#import "SegmentDownloader.h"

@interface ZYLVideoDownLoader () <SegmentDownloaderDelegate>

@property (assign, nonatomic) NSInteger index;//记录一共多少TS文件

@property (strong, nonatomic) NSMutableArray *downloadUrlArray;//记录所有的下载链接

@property (assign, nonatomic) NSInteger sIndex;//记录下载成功的文件的数量（以3为基数）

@end

@implementation ZYLVideoDownLoader

-(instancetype)init {
    self = [super init];
    if (self) {
        self.index = 0;
        self.sIndex = 0;
    }
    return self;
}

#pragma mark - 下载TS数据
- (void)startDownloadVideo {
    //首相检查是否存在路径
    [self checkDirectoryIsCreateM3U8:NO];
    
    __weak __typeof(self)weakSelf = self;
        //将解析的数据打包成一个个独立的下载器装进数组
        [self.playList.segmentArray enumerateObjectsUsingBlock:^(M3U8SegmentModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //检查此下载对象是否存在
            __block BOOL isE = NO;
            [weakSelf.downloadUrlArray enumerateObjectsUsingBlock:^(NSString *inObj, NSUInteger inIdx, BOOL * _Nonnull inStop) {
                if ([inObj isEqualToString:obj.locationUrl]) {
                    //已经存在
                    isE = YES;
                    *inStop = YES;
                } else {
                    //不存在
                    isE = NO;
                }
            }];
            
            if (isE) {
                //存在
            } else {
                //不存在
                NSString *fileName = [NSString stringWithFormat:@"id%ld.ts", (long)weakSelf.index];
                SegmentDownloader *sgDownloader = [[SegmentDownloader alloc] initWithUrl:[@"http://111.206.23.22:55336/tslive/c25_ct_btv2_btvwyHD_smooth_t10/" stringByAppendingString:obj.locationUrl] andFilePath:weakSelf.playList.uuid andFileName:fileName withDuration:obj.duration withIndex:weakSelf.index];
                sgDownloader.delegate = weakSelf;
                [weakSelf.downLoadArray addObject:sgDownloader];
                [weakSelf.downloadUrlArray addObject:obj.locationUrl];
                weakSelf.index++;
            }
            
        }];
    
    //根据新的数据更改新的playList
    __block NSMutableArray *newPlaylistArray = [[NSMutableArray alloc] init];
    [self.downLoadArray enumerateObjectsUsingBlock:^(SegmentDownloader *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        M3U8SegmentModel *model = [[M3U8SegmentModel alloc] init];
        model.duration = obj.duration;
        model.locationUrl = obj.fileName;
        model.index = obj.index;
        [newPlaylistArray addObject:model];
    }];
    
    if (newPlaylistArray.count > 0) {
        self.playList.segmentArray = newPlaylistArray;
    }
    
    //打包完成开始下载
    [self.downLoadArray enumerateObjectsUsingBlock:^(SegmentDownloader *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.flag = YES;
        [obj start];
    }];
}

#pragma mark - 检查路径
- (void)checkDirectoryIsCreateM3U8:(BOOL)isC {
    //创建缓存路径
    NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *saveTo = [[pathPrefix stringByAppendingPathComponent:@"Downloads"] stringByAppendingPathComponent:self.playList.uuid];
    NSFileManager *fm = [NSFileManager defaultManager];
    //路径不存在就创建一个
    BOOL isD = [fm fileExistsAtPath:saveTo];
    if (isD) {
        //存在
        
    } else {
        //不存在
        BOOL isS = [fm createDirectoryAtPath:saveTo withIntermediateDirectories:YES attributes:nil error:nil];
        if (isS) {
            NSLog(@"路径不存在创建成功");
        } else {
            NSLog(@"路径不存在创建失败");
        }
        
    }
}

#pragma mark - SegmentDownloaderDelegate
#pragma mark - 数据下载成功
- (void)segmentDownloadFinished:(SegmentDownloader *)downloader {
    //数据下载成功后再数据源中移除当前下载器
    self.sIndex++;
    if (self.sIndex >= 3) {
        //每次下载完成后都要创建M3U8文件
        [self createLocalM3U8file];
        //证明所有的TS已经下载完成
        [self.delegate videoDownloaderFinished:self];
    }
    
}

#pragma mark - 数据下载失败
- (void)segmentDownloadFailed:(SegmentDownloader *)downloader {
    [self.delegate videoDownloaderFailed:self];
}

#pragma mark - 进度更新
- (void)segmentProgress:(SegmentDownloader *)downloader TotalUnitCount:(int64_t)totalUnitCount completedUnitCount:(int64_t)completedUnitCount {
    //NSLog(@"下载进度：%f", completedUnitCount * 1.0 / totalUnitCount * 1.0);
}

#pragma mark - 创建M3U8文件
- (void)createLocalM3U8file {
    
    [self checkDirectoryIsCreateM3U8:YES];
    //创建M3U8的链接地址
    NSString *path = [[[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0] stringByAppendingPathComponent:@"Downloads"] stringByAppendingPathComponent:self.playList.uuid] stringByAppendingPathComponent:@"movie.m3u8"];
    
    //拼接M3U8链接的头部具体内容
    //NSString *header = @"#EXTM3U\n#EXT-X-VERSION:2\n#EXT-X-MEDIA-SEQUENCE:371\n#EXT-X-TARGETDURATION:12\n";
    NSString *header = [NSString stringWithFormat:@"#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-MEDIA-SEQUENCE:0\n#EXT-X-TARGETDURATION:15\n"];
    //填充M3U8数据
    __block NSString *tsStr = [[NSString alloc] init];
    [self.playList.segmentArray enumerateObjectsUsingBlock:^(M3U8SegmentModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //文件名
            NSString *fileName = [NSString stringWithFormat:@"id%ld.ts", obj.index];
            //文件时长
            NSString* length = [NSString stringWithFormat:@"#EXTINF:%ld,\n",obj.duration];
            //拼接M3U8
            tsStr = [tsStr stringByAppendingString:[NSString stringWithFormat:@"%@%@\n", length, fileName]];
    }];
    //M3U8头部和中间拼接,到此我们完成的新的M3U8链接的拼接
    header = [header stringByAppendingString:tsStr];
    header = [header stringByAppendingString:@"#EXT-X-ENDLIST"];
    //拼接完成，存储到本地
    NSMutableData *writer = [[NSMutableData alloc] init];
    NSFileManager *fm = [NSFileManager defaultManager];
    //判断m3u8是否存在,已经存在的话就不再重新创建
    if ([fm fileExistsAtPath:path isDirectory:nil]) {
        //存在这个链接
        NSLog(@"存在这个链接");
    } else {
        //不存在这个链接
        NSString *saveTo = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0] stringByAppendingPathComponent:@"Downloads"] stringByAppendingPathComponent:self.playList.uuid];
        BOOL isS = [fm createDirectoryAtPath:saveTo withIntermediateDirectories:YES attributes:nil error:nil];
        if (isS) {
            NSLog(@"创建目录成功");
        } else {
            NSLog(@"创建目录失败");
        }
    }
    [writer appendData:[header dataUsingEncoding:NSUTF8StringEncoding]];
    BOOL bSucc = [writer writeToFile:path atomically:YES];
    if (bSucc) {
        //成功
        NSLog(@"M3U8数据保存成功");
    } else {
        //失败
        NSLog(@"M3U8数据保存失败");
    }
    NSLog(@"新数据\n%@", header);
}

#pragma mark - 删除缓存文件
- (void)deleteCache {
    //获取缓存路径
    NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *saveTo = [[pathPrefix stringByAppendingPathComponent:@"Downloads"] stringByAppendingPathComponent:@"moive1"];
    NSFileManager *fm = [NSFileManager defaultManager];
    //路径不存在就创建一个
    BOOL isD = [fm fileExistsAtPath:saveTo];
    if (isD) {
        //存在
        NSArray *deleteArray = [_downloadUrlArray subarrayWithRange:NSMakeRange(0, _downloadUrlArray.count - 20)];
        //清空当前的M3U8文件
        [deleteArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BOOL isS = [fm removeItemAtPath:[saveTo stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", obj]] error:nil];
            if (isS) {
                NSLog(@"多余路径存在清空成功%@", obj);
            } else {
                NSLog(@"多余路径存在清空失败%@", obj);
            }
        }];
    }
}

#pragma mark - getter
- (NSMutableArray *)downLoadArray {
    if (_downLoadArray == nil) {
        _downLoadArray = [[NSMutableArray alloc] init];
    }
    return _downLoadArray;
}

- (NSMutableArray *)downloadUrlArray {
    if (_downloadUrlArray == nil) {
        _downloadUrlArray = [[NSMutableArray alloc] init];
    }
    return _downloadUrlArray;
}


@end
