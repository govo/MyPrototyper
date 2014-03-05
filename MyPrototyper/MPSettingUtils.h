//
//  MPSettingUtils.h
//  MyPrototyper
//
//  Created by govo on 14-1-9.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MPSettingUtils : NSObject

+(NSDictionary *)settings;
+(void)saveSettings:(NSDictionary *)dict;
+(NSDictionary *)settingsFromDirectory:(NSString *)path;
+(void)saveSettings:(NSDictionary *)dict toDirectory:(NSString *)path;
+(NSDictionary *)globalSetting;
+(void)saveGlobalSetting:(NSDictionary *)dict;
@end
