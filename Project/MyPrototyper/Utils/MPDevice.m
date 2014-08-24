//
//  MPDevice.m
//  MyPrototyper
//
//  Created by govo on 14-3-4.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import "MPDevice.h"
#import <AdSupport/AdSupport.h>

@implementation MPDevice

+(NSString *)uuid
{
    CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *cfuuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
    CFBridgingRelease(cfuuid);
    return cfuuidString;
}
+(NSString *)advertiserIdentifier
{
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}
@end
