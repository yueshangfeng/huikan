//
//  M3U8Playlist.h
//  回看
//
//  Created by zyl on 16/8/10.
//  Copyright © 2016年. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface M3U8Playlist : NSObject

@property (strong, nonatomic) NSArray *segmentArray;

@property (copy, nonatomic) NSString *uuid;

@property (assign, nonatomic) NSInteger length;

/**
 * 设置
 */
- (void)initWithSegmentArray:(NSArray *)array;

@end
