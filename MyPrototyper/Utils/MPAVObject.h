//
//  MPAVObject.h
//  MyPrototyper
//
//  Created by govo on 14-3-5.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>

#define KEY_AV_PREVIEW_COUNTER   @"PreviewCounter"
#define KEY_AV_COUNT     @"count"

@interface MPAVObject : NSObject

+(AVObject *)previewCounter;


@end
