//
//  MPAVObject.m
//  MyPrototyper
//
//  Created by govo on 14-3-5.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import "MPAVObject.h"


@implementation MPAVObject

+(AVObject *)previewCounter
{
    AVQuery *query = [AVQuery queryWithClassName:KEY_AV_PREVIEW_COUNTER];
    AVObject *obj = [query getFirstObject];
    NSLog(@"query:%@",[query getFirstObject]);
    if (obj==nil) {
        obj = [AVObject objectWithClassName:KEY_AV_PREVIEW_COUNTER];
        [obj setObject:[NSNumber numberWithInteger:0] forKey:KEY_AV_COUNT];
    }
    return obj;
}

@end
