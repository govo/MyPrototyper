//
//  MPAVObject.h
//  MyPrototyper
//
//  Created by govo on 14-3-5.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>
#import "MobClick.h"

#define KEY_AV_PREVIEW_COUNTER      @"PreviewCounter"
#define KEY_AV_UNZIP_COUNTER        @"UnzipCounter"
#define KEY_AV_TAPED_COUNTER        @"TapedCounter"
#define KEY_AV_FEEDBACK_OBJECT      @"Feedback"
#define KEY_AV_HELP_FIRST_COUNTER   @"HelpFirstCounter"
#define KEY_AV_SET                  @"SettingCounter"
#define KEY_AV_SEGMENTED            @"segmented"

#define KEY_AV_EVENT                @"event"
#define KEY_AV_COUNT                @"count"
#define KEY_AV_RESULT               @"result"
#define KEY_AV_HASPWD               @"hasPwd"
#define KEY_AV_DATA                 @"data"
#define KEY_AV_HELP                 @"help"
#define KEY_AV_EDIT                 @"edit"

#define KEY_AV_CONTACT              @"contact"
#define KEY_AV_FEEDBACK_CONTENT     @"feedback"


extern NSString * const kAVObjectPreviewCounterEventFromRow;
extern NSString * const kAVObjectPreviewCounterEventFromZip;
extern NSString * const kAVObjectPreviewCounterEventFromUnZip;

extern NSString * const kAVObjectUnzip;
extern NSString * const kAVObjectReUnzip;
extern NSString * const kAVObjectResultSuccessed;
extern NSString * const kAVObjectResultFailed;

@interface MPAVObject : NSObject

+(void)previewCounterWithEvent:(NSString *)event;
+(void)unzipCounterWithEvent:(NSString *)event result:(NSString *)result hasPwd:(BOOL)hasPwd;
+(void)onTapedWithEvent:(NSString *)event data:(NSString *)data;
+(void)userAutoLogin;
+(void)sentFeedback:(NSString *)feedback contact:(NSString *)contact resultBlock:(AVBooleanResultBlock)block;
+(void)beginLogPageView:(NSString *)pageName;
+(void)endLogPageView:(NSString *)pageName;

@end
