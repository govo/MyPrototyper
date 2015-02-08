//
//  MPWifiUplader.h
//  MyPrototyper
//
//  Created by govo on 15/2/8.
//  Copyright (c) 2015年 me.govo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPWifiUplader : NSObject

+ (MPWifiUplader *)sharedInstance;

/**
 *  Run Uploader
 *
 *  @param runing run it if YES, else stop it
 */
+ (void) runUplader:(BOOL)runing;
/**
 *  return if upolader is running
 *
 *  @return is running or not
 */
+ (BOOL) isRunning;

+ (NSURL *) serverURL;

@end
