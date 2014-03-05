//
//  MPAVObject.h
//  MyPrototyper
//
//  Created by govo on 14-3-5.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>

#define KEY_AV_PREVIEW_COUNTER      @"PreviewCounter"
#define KEY_AV_UNZIP_COUNTER        @"UnzipCounter"

#define KEY_AV_EVENT                @"event"
#define KEY_AV_COUNT                @"count"
#define KEY_AV_RESULT               @"result"
#define KEY_AV_HASPWD               @"hasPwd"

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


@end
