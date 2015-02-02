//
//  MPAppDelegate.m
//  MyPrototyper
//
//  Created by govo on 14-1-6.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import "MPAppDelegate.h"
#import <AVOSCloud/AVOSCloud.h>
#import "iRate.h"
#import "MPDevice.h"
#import "MobClick.h"
#import "GCDWebUploader.h"


#define appID @"yxjbxbhr0erk12pp42ldwtdjvt821s9ymuolx4zi6tyqtajt"
#define appKey @"eorarbsk3043lzqsrpxde8p1nfkcorhd09hamnygysco6468"

#define UMENG_APPKEY @"53216e5a56240bbd1c002033"

@interface MPAppDelegate(){
     GCDWebUploader* _webUploader;
}

@end

@implementation MPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //AVOSCloud
    [AVOSCloud setApplicationId:appID clientKey:appKey];
    
    //友盟
    NSString *channelId = nil;// @"tongbu";//渠道：tongbu 同步推
    [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:SEND_INTERVAL channelId:channelId];
    [MobClick setAppVersion:XcodeAppVersion];
    [MobClick checkUpdate];
    
//    [MobClick updateOnlineConfig];  //在线参数配置
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    _webUploader = [[GCDWebUploader alloc] initWithUploadDirectory:documentsPath];
    [_webUploader start];
    NSLog(@"Visit %@ in your web browser", _webUploader.serverURL);

    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+(void)initialize
{
    //configure iRate
    [iRate sharedInstance].appStoreID = 822214463;
    [iRate sharedInstance].daysUntilPrompt = 2;
    [iRate sharedInstance].usesUntilPrompt = 8;
//    [iRate sharedInstance].previewMode = YES;
}

@end
