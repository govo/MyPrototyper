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
    return [MPSettingUtils settingsFromDirectory:kSettingGlobalDirectory];
}
+(void)saveSettings:(NSDictionary *)dict
{
    [MPSettingUtils saveSettings:dict toDirectory:kSettingGlobalDirectory];
}
+(NSDictionary *)settingsFromDirectory:(NSString *)path
{
    NSString *fullPath =[path stringByAppendingPathComponent:kSettingFileName];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:fullPath];
    if (dict==nil) {
        dict = @{kSettingScrollBar: [NSNumber numberWithBool:YES],kSettingStatusBar:[NSNumber numberWithBool:YES],kSettingLandSpace:[NSNumber numberWithInteger:UIInterfaceOrientationMaskPortrait],kSettingAppVersion:kAppVersion};
        [dict writeToFile:fullPath atomically:YES];
    }
    return dict;
}
+(void)saveSettings:(NSDictionary *)dict toDirectory:(NSString *)path
{
    NSString *fullPath =[path stringByAppendingPathComponent:kSettingFileName];
    if (dict!=nil) {
        [dict writeToFile:fullPath atomically:YES];
    }else{
        NSFileManager *fileManager = [[NSFileManager alloc]init];
        if ([fileManager fileExistsAtPath:fullPath]) {
            [fileManager removeItemAtPath:fullPath error:nil];
        }
    }
}
@end
