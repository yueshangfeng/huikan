//
//  M3U8SegmentModel.h
//  回看
//
//  Created by zyl on 16/8/9.
//  Copyright © 2016年 . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface M3U8SegmentModel : NSObject

@property (assign, nonatomic) NSInteger duration;

@property (copy, nonatomic) NSString *locationUrl;

@property (assign, nonatomic) NSInteger index;

@end
