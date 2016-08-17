//
//  ZYLM3U8Handler.m
//  回看
//
//  Created by zyl on 16/8/9.
//  Copyright © 2016年 . All rights reserved.
//

#import "ZYLM3U8Handler.h"

#import "M3U8SegmentModel.h"

@implementation ZYLM3U8Handler

#pragma mark - 解析M3U8链接
-(void)praseUrl:(NSString *)urlStr {
        //判断是否是HTTP连接
        if (!([urlStr hasPrefix:@"http://"] || [urlStr hasPrefix:@"https://"])) {
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(praseM3U8Failed:)]) {
                [self.delegate praseM3U8Failed:self];
            }
            return;
        }
        
        //解析出M3U8
        NSError *error = nil;
        NSStringEncoding encoding;
        NSString *m3u8Str = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:urlStr] usedEncoding:&encoding error:&error];//注意这一步是耗时操作，要在子线程中进行
    self.oriM3U8Str = m3u8Str;
        if (m3u8Str == nil) {
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(praseM3U8Failed:)]) {
                
                    [self.delegate praseM3U8Failed:self];
                
            }
            return;
        }
        
        //解析TS文件
        NSRange segmentRange = [m3u8Str rangeOfString:@"#EXTINF:"];
        if (segmentRange.location == NSNotFound) {
            //M3U8里没有TS文件
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(praseM3U8Failed:)]) {
                
                    [self.delegate praseM3U8Failed:self];
                
            }
            return;
        }
    
    if (self.segmentArray.count > 0) {
        [self.segmentArray removeAllObjects];
    }
    
        //逐个解析TS文件，并存储
        while (segmentRange.location != NSNotFound) {
            //声明一个model存储TS文件链接和时长的model
            M3U8SegmentModel *model = [[M3U8SegmentModel alloc] init];
            //读取TS片段时长
            NSRange commaRange = [m3u8Str rangeOfString:@","];
            NSString* value = [m3u8Str substringWithRange:NSMakeRange(segmentRange.location + [@"#EXTINF:" length], commaRange.location -(segmentRange.location + [@"#EXTINF:" length]))];
            model.duration = [value integerValue];
            //截取M3U8
            m3u8Str = [m3u8Str substringFromIndex:commaRange.location];
            //获取TS下载链接,这需要根据具体的M3U8获取链接，可以更具自己公司的需求
            NSRange linkRangeBegin = [m3u8Str rangeOfString:@","];
            NSRange linkRangeEnd = [m3u8Str rangeOfString:@".ts"];
            NSString* linkUrl = [m3u8Str substringWithRange:NSMakeRange(linkRangeBegin.location + 2, (linkRangeEnd.location + 3) - (linkRangeBegin.location + 2))];
            model.locationUrl = linkUrl;
            [self.segmentArray addObject:model];
            m3u8Str = [m3u8Str substringFromIndex:(linkRangeEnd.location + 3)];
            segmentRange = [m3u8Str rangeOfString:@"#EXTINF:"];
        }
        
        //已经获取了所有TS片段，继续打包数据
        [self.playList initWithSegmentArray:self.segmentArray];
        self.playList.uuid = @"moive1";
        
        //到此数据TS解析成功，通过代理发送成功消息
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(praseM3U8Finished:)]) {
            
                [self.delegate praseM3U8Finished:self];
            
        }
}

#pragma mark - getter
- (NSMutableArray *)segmentArray {
    if (_segmentArray == nil) {
        _segmentArray = [[NSMutableArray alloc] init];
    }
    return _segmentArray;
}

- (M3U8Playlist *)playList {
    if (_playList == nil) {
        _playList = [[M3U8Playlist alloc] init];
    }
    return _playList;
}

@end
