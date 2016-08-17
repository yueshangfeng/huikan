//
//  ZYLDecodeTool.h
//  回看
//
//  Created by zyl on 16/8/9.
//  Copyright © 2016年 . All rights reserved.
// 

#import <Foundation/Foundation.h>

@protocol ZYLDecodeToolDelegate <NSObject>

- (void)decodeSuccess;

- (void)decodeFail;

@end

@interface ZYLDecodeTool : NSObject

- (void)handleM3U8Url:(NSString *)url;

@property (weak, nonatomic) id <ZYLDecodeToolDelegate> delegate;

@end
