//
//  AppDelegate.m
//  回看
//
//  Created by zyl on 16/7/25.
//  Copyright © 2016年 . All rights reserved.
//

#import "AppDelegate.h"

#import <HTTPServer.h>
#import <DDTTYLogger.h>

@interface AppDelegate ()

@property (strong, nonatomic) HTTPServer *httpServer;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //开启本地服务器
    [self openServer];
    
    return YES;
    

    
}

- (void)openServer {
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    self.httpServer=[[HTTPServer alloc]init];
    [self.httpServer setType:@"_http._tcp."];
    [self.httpServer setPort:9479];
    NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *webPath = [pathPrefix stringByAppendingPathComponent:@"Downloads"];
    [self.httpServer setDocumentRoot:webPath];
    NSLog(@"服务器路径：%@", webPath);
    NSError *error;
    if ([self.httpServer start:&error]) {
        NSLog(@"开启HTTP服务器 端口:%hu",[self.httpServer listeningPort]);
    }
    else{
        NSLog(@"服务器启动失败错误为:%@",error);
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //[self.httpServer stop];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    //[self.httpServer start:nil];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
