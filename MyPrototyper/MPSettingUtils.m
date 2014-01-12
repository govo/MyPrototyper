//
//  MPSettingUtils.m
//  MyPrototyper
//
//  Created by govo on 14-1-9.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import "MPSettingUtils.h"

@implementation MPSettingUtils

+(NSDictionary *)settings
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:kSettingFileOut];
    if (dict==nil) {
        dict = @{kSettingScrollBar: [NSNumber numberWithBool:YES],kSettingStatusBar:[NSNumber numberWithBool:NO],kSettingLandSpace:[NSNumber numberWithBool:NO],kSettingAppVersion:kAppVersion};
        [dict writeToFile:kSettingFileOut atomically:YES];
    }
    return dict;
}
+(void)setSettings:(NSDictionary *)dict
{
    if (dict!=nil) {
        [dict writeToFile:kSettingFileOut atomically:YES];
    }
}

@end
