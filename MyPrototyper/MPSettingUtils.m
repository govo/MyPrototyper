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
    return [MPSettingUtils settingsFromDirectory:kGlobalMetaDirectory];
}
+(void)saveSettings:(NSDictionary *)dict
{
    [MPSettingUtils saveSettings:dict toDirectory:kGlobalMetaDirectory];
}
+(NSDictionary *)settingsFromDirectory:(NSString *)path
{
    NSString *fullPath =[path stringByAppendingPathComponent:kSettingFileName];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:fullPath];
    if (dict==nil) {
        dict = @{kSettingScrollBar: [NSNumber numberWithBool:YES],kSettingStatusBar:[NSNumber numberWithBool:NO],kSettingLandSpace:[NSNumber numberWithInteger:UIInterfaceOrientationMaskPortrait],kSettingAppVersion:kAppVersion };
        [self createDirectory:path];
        [dict writeToFile:fullPath atomically:YES];
    }
    return dict;
}
+(void)saveSettings:(NSDictionary *)dict toDirectory:(NSString *)path
{
    NSString *fullPath =[path stringByAppendingPathComponent:kSettingFileName];
    if (dict!=nil) {
        [self createDirectory:path];
        [dict writeToFile:fullPath atomically:YES];
    }else{
        NSFileManager *fileManager = [[NSFileManager alloc]init];
        if ([fileManager fileExistsAtPath:fullPath]) {
            [fileManager removeItemAtPath:fullPath error:nil];
        }
    }
}
+(NSDictionary *)globalSetting
{
    NSString *baseSettingPath = [kGlobalMetaDirectory stringByAppendingPathComponent:kSettingGlobalSettingFileName];
    NSDictionary *baseSetting = [NSDictionary dictionaryWithContentsOfFile:baseSettingPath];
    if (baseSetting==nil) {
        baseSetting = @{kSettingIsFirstUse: [NSNumber numberWithBool:YES],kSettingAppVersion:kAppVersion};
        
        [self createDirectory:kGlobalMetaDirectory];
        if([baseSetting writeToFile:baseSettingPath atomically:YES]){
            NSLog(@"saved globalSetting");
        }else{
            NSLog(@"save globalSetting error");
        }
    }

    return baseSetting;
}
+(void)saveGlobalSetting:(NSDictionary *)dict
{
    NSString *baseSettingPath = [kGlobalMetaDirectory stringByAppendingPathComponent:kSettingGlobalSettingFileName];

    if (dict!=nil) {
        [self createDirectory:kGlobalMetaDirectory];
        [dict writeToFile:baseSettingPath atomically:YES];
    }else{
        NSFileManager *fileManager = [[NSFileManager alloc]init];
        if ([fileManager fileExistsAtPath:baseSettingPath]) {
            [fileManager removeItemAtPath:baseSettingPath error:nil];
        }
    }
}
+(void)createDirectory:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
    }else{
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    }
}
@end
