//
//  MPSettingUtils.h
//  MyPrototyper
//
//  Created by govo on 14-1-9.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSettingFileName @"setting.out"
#define kSettingGlobalDirectory [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define kAppVersion @"1.0.0"
#define kSettingScrollBar @"scrollBar"
#define kSettingStatusBar @"statusBar"
#define kSettingLandSpace @"landSpace"
#define kSettingAppVersion @"appVersion"

@interface MPSettingUtils : NSObject

+(NSDictionary *)settings;
+(void)saveSettings:(NSDictionary *)dict;
+(NSDictionary *)settingsFromDirectory:(NSString *)path;
+(void)saveSettings:(NSDictionary *)dict toDirectory:(NSString *)path;
@end
