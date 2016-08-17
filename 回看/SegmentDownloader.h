//
//  SegmentDownloader.h
//  回看
//
//  Created by zyl on 16/8/10.
//  Copyright © 2016年 . All rights reserved.
//

#import <Foundation/Foundation.h>
@class SegmentDownloader;

@protocol SegmentDownloaderDelegate <NSObject>

/**
 * 下载成功
 */
- (void)segmentDownloadFinished:(SegmentDownloader *)downloader;

/**
 * 下载失败
 */
- (void)segmentDownloadFailed:(SegmentDownloader *)downloader;

/**
 * 监听进度
 */
- (void)segmentProgress:(SegmentDownloader *)downloader TotalUnitCount:(int64_t)totalUnitCount completedUnitCount:(int64_t)completedUnitCount;

@end

@interface SegmentDownloader : NSObject

@property (nonatomic, copy) NSString *fileName;

@property (nonatomic, copy) NSString *filePath;

@property (nonatomic, copy) NSString *downloadUrl;

@property (assign, nonatomic) NSInteger duration;

@property (assign, nonatomic) NSInteger index;

/**
 * 标记这个下载器是否正在下载
 */
@property (assign, nonatomic) BOOL flag;

/**
 * 初始化TS下载器
 */
- (instancetype)initWithUrl:(NSString *)url andFilePath:(NSString *)path andFileName:(NSString *)fileName withDuration:(NSInteger)duration withIndex:(NSInteger)index;

/**
 * 传递数据下载成功或者失败的代理
 */
@property (strong, nonatomic) id <SegmentDownloaderDelegate> delegate;

/**
 * 开始下载
 */
- (void)start;

@end
