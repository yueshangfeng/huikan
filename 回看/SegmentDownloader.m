//
//  SegmentDownloader.m
//  回看
//
//  Created by zyl on 16/8/10.
//  Copyright © 2016年 . All rights reserved.
//

#import "SegmentDownloader.h"

#import <AFNetworking.h>

@interface SegmentDownloader ()

@property (strong, nonatomic) AFHTTPRequestSerializer *serializer;

@property (strong, nonatomic) AFURLSessionManager *downLoadSession;

@end

@implementation SegmentDownloader

#pragma mark - 初始化TS下载器
- (instancetype)initWithUrl:(NSString *)url andFilePath:(NSString *)path andFileName:(NSString *)fileName withDuration:(NSInteger)duration withIndex:(NSInteger)index {
    self = [super init];
    if (self) {
        self.downloadUrl = url;
        self.filePath = path;
        self.fileName = fileName;
        self.duration = duration;
        self.index = index;
    }
    return self;
}

#pragma mark - 开始下载
- (void)start {
    //首先检查此文件是否已经下载
    if ([self checkIsDownload]) {
        //下载了
        [self.delegate segmentDownloadFinished:self];
        return;
    } else {
        //没下载
        
    }
    
    //首先拼接存储数据的路径
    __block NSString *path = [[[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0] stringByAppendingPathComponent:@"Downloads"] stringByAppendingPathComponent:self.filePath] stringByAppendingPathComponent:self.fileName];
    
    //这里使用AFN下载,并将数据同时存储到沙盒目录制定的目录中
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.downloadUrl]];
    __block NSProgress *progress = nil;
    NSURLSessionDownloadTask *downloadTask = [self.downLoadSession downloadTaskWithRequest:request progress:&progress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //在这里告诉AFN数据存储的路径和文件名
        NSURL *documentsDirectoryURL = [NSURL fileURLWithPath:path isDirectory:NO];
        return documentsDirectoryURL;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error == nil) {
            //下载成功
            //NSLog(@"路径%@保存成功", filePath);
            [self.delegate segmentDownloadFinished:self];
        } else {
            //下载失败
            [self.delegate segmentDownloadFailed:self];
        }
        [progress removeObserver:self forKeyPath:@"completedUnitCount"];
    }];
    //添加对进度的监听
    [progress addObserver:self forKeyPath:@"completedUnitCount" options:NSKeyValueObservingOptionNew context:nil];
    //开始下载
    [downloadTask resume];
}

#pragma mark - 检查此文件是否下载过
- (BOOL)checkIsDownload {
    //获取缓存路径
    NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *saveTo = [[pathPrefix stringByAppendingPathComponent:@"Downloads"] stringByAppendingPathComponent:self.filePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    __block BOOL isE = NO;
    //获取缓存路径下的所有的文件名
    NSArray *subFileArray = [fm subpathsAtPath:saveTo];
    [subFileArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //判断是否已经缓存了此文件
        if ([self.fileName isEqualToString:[NSString stringWithFormat:@"%@", obj]]) {
            //已经下载
            isE = YES;
            *stop = YES;
        } else {
            //没有存在
            isE = NO;
        }
    }];
    
    return isE;
}

#pragma mark - 监听进度
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(NSProgress *)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"completedUnitCount"]) {
        [self.delegate segmentProgress:self TotalUnitCount:object.totalUnitCount completedUnitCount:object.completedUnitCount];
    }
}

#pragma mark - getter
- (AFHTTPRequestSerializer *)serializer {
    if (_serializer == nil) {
        _serializer = [AFHTTPRequestSerializer serializer];
    }
    return _serializer;
}

- (AFURLSessionManager *)downLoadSession {
    if (_downLoadSession == nil) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _downLoadSession = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    return _downLoadSession;
}

@end
