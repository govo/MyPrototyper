//
//  MPSettingUtils.h
//  MyPrototyper
//
//  Created by govo on 14-1-9.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSettingFileOut [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:@"setting.out"]
#define kAppVersion @"1.0.0"
#define kSettingScrollBar @"scrollBar"
#define kSettingStatusBar @"statusBar"
#define kSettingLandSpace @"landSpace"
#define kSettingAppVersion @"appVersion"

@interface MPSettingUtils : NSObject

+(NSDictionary *)settings;
+(void)setSettings:(NSDictionary *)dict;
@end
