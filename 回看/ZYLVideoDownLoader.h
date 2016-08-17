//
//  ZYLVideoDownLoader.h
//  回看
//
//  Created by zyl on 16/8/10.
//  Copyright © 2016年 . All rights reserved.
//

#import <Foundation/Foundation.h>

#import "M3U8Playlist.h"

@class ZYLVideoDownLoader;

@protocol ZYLVideoDownLoaderDelegate <NSObject>

/**
 * 下载成功
 */
- (void)videoDownloaderFinished:(ZYLVideoDownLoader *)videoDownloader;

/**
 * 下载失败
 */
- (void)videoDownloaderFailed:(ZYLVideoDownLoader *)videoDownloader;

@end

@interface ZYLVideoDownLoader : NSObject

@property (strong, nonatomic) M3U8Playlist *playList;

/**
 * 记录原始的M3U8
 */
@property (copy, nonatomic) NSString *oriM3U8Str;

/**
 * 下载TS数据
 */
- (void)startDownloadVideo;

/**
 * 储存正在下载的数组
 */
@property (strong, nonatomic) NSMutableArray *downLoadArray;

/**
 * 下载成功或者失败的代理
 */
@property (weak, nonatomic) id <ZYLVideoDownLoaderDelegate> delegate;

/**
 * 创建M3U8文件
 */
- (void)createLocalM3U8file;

@end
