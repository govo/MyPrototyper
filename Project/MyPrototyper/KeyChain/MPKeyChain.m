//
//  MPKeyChain.m
//  MyPrototyper
//
//  Created by govo on 14-3-4.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import "MPKeyChain.h"
#import <AdSupport/AdSupport.h>

@implementation MPKeyChain

+(NSString *)uuid
{
    CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *cfuuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
    CFRelease(cfuuid);
    return cfuuidString;
}
+(NSString *)advertiserIdentifier
{
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

@end
