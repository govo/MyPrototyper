//
//  MPWifiUplader.m
//  MyPrototyper
//
//  Created by govo on 15/2/8.
//  Copyright (c) 2015年 me.govo. All rights reserved.
//

#import "MPWifiUplader.h"
#import "GCDWebUploader.h"

@interface MPWifiUplader(){
    GCDWebUploader* _webUploader;
}

@end

@implementation MPWifiUplader

+ (MPWifiUplader *)sharedInstance {
    static MPWifiUplader *singleton;
    static dispatch_once_t token;
    dispatch_once(&token,^{
        singleton = [[super allocWithZone:NULL] init];
        [singleton setupUploader];
    });
    return singleton;
}

- (void)setupUploader{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    _webUploader = [[GCDWebUploader alloc] initWithUploadDirectory:documentsPath];
}
- (void)runUplader:(BOOL)runing{
    if (runing){
        [_webUploader start];
    }else{
        [_webUploader stop];
    }

}
- (BOOL)isRunning{
    return [_webUploader isRunning];
}
- (NSURL *)serverURL{
    return [_webUploader serverURL];
}

+ (void)runUplader:(BOOL)runing{
    [[self sharedInstance] runUplader:runing];
}
+ (BOOL)isRunning
{
    return [[self sharedInstance] isRunning];
}
+ (NSURL *)serverURL{
    return [[self sharedInstance] serverURL];
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

@end
