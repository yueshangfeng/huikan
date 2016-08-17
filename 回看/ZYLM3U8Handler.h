//
//  ZYLM3U8Handler.h
//  回看
//
//  Created by zyl on 16/8/9.
//  Copyright © 2016年 . All rights reserved.
//

#import <Foundation/Foundation.h>

#import "M3U8Playlist.h"

@class ZYLM3U8Handler;

@protocol ZYLM3U8HandlerDelegate <NSObject>

/**
 * 解析M3U8连接失败
 */
-(void)praseM3U8Finished:(ZYLM3U8Handler *)handler;

/**
 * 解析M3U8成功
 */
-(void)praseM3U8Failed:(ZYLM3U8Handler *)handler;

@end

@interface ZYLM3U8Handler : NSObject

/**
 * 解码M3U8
 */
-(void)praseUrl:(NSString *)urlStr;

/**
 * 传输成功或者失败的代理
 */
@property (weak, nonatomic)id <ZYLM3U8HandlerDelegate> delegate;

/**
 * 存储TS片段的数组
 */
@property (strong, nonatomic) NSMutableArray *segmentArray;

/**
 * 打包获取的TS片段
 */
@property (strong, nonatomic) M3U8Playlist *playList;

/**
 * 存储原始的M3U8数据
 */
@property (copy, nonatomic) NSString *oriM3U8Str;

@end
