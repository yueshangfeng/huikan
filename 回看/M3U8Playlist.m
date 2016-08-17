//
//  M3U8Playlist.m
//  回看
//
//  Created by zyl on 16/8/10.
//  Copyright © 2016年 . All rights reserved.
//

#import "M3U8Playlist.h"

@implementation M3U8Playlist

- (void)initWithSegmentArray:(NSArray *)array {
    self.segmentArray = array;
    self.length = array.count;
}

@end
