//
//  MPAVObject.m
//  MyPrototyper
//
//  Created by govo on 14-3-5.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import "MPAVObject.h"

NSString * const kAVObjectPreviewCounterEventFromRow = @"R";
NSString * const kAVObjectPreviewCounterEventFromZip = @"Z";
NSString * const kAVObjectPreviewCounterEventFromUnZip = @"U";


NSString * const kAVObjectUnzip = @"Un";
NSString * const kAVObjectReUnzip = @"Re";
NSString * const kAVObjectResultSuccessed = @"1";
NSString * const kAVObjectResultFailed = @"0";

@implementation MPAVObject

+(void)previewCounterWithEvent:(NSString *)event
{
    if (event==nil) {
        return;
    }
    
    AVObject *obj =  [AVObject objectWithClassName:KEY_AV_PREVIEW_COUNTER];
    [obj setObject:event forKey:KEY_AV_EVENT];
    [obj saveEventually];
    return;
    
    //使用上面的方式可以分时
    /*
    AVQuery *query = [AVQuery queryWithClassName:KEY_AV_PREVIEW_COUNTER];
    query.cachePolicy =[query hasCachedResult]? kPFCachePolicyCacheElseNetwork : kPFCachePolicyNetworkElseCache;
    query.maxCacheAge = 3600;
    [query whereKey:KEY_AV_EVENT equalTo:event];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error!=nil) {
            return;
        }
        AVObject *obj = [objects firstObject];
        
        if (obj==nil) {

            obj = [AVObject objectWithClassName:KEY_AV_PREVIEW_COUNTER];
            [obj setObject:event forKey:KEY_AV_EVENT];
            [obj setObject:[NSNumber numberWithInteger:0] forKey:KEY_AV_COUNT];
        }
        [obj incrementKey:KEY_AV_COUNT];
        [obj saveEventually];
    }];
     */
}
+(void)unzipCounterWithEvent:(NSString *)event result:(NSString *)result hasPwd:(BOOL)hasPwd
{
    if (event==nil) {
        return;
    }
    
    AVObject *obj = [AVObject objectWithClassName:KEY_AV_UNZIP_COUNTER];
    [obj setObject:event forKey:KEY_AV_EVENT];
    if (result) {
        [obj setObject:result forKey:KEY_AV_RESULT];
    }
    [obj setObject:[NSNumber numberWithBool:hasPwd] forKey:KEY_AV_HASPWD];
    [obj saveEventually];
    
    return;
    
    //使用上面的方式可以分时
    /*
    AVQuery *query = [AVQuery queryWithClassName:KEY_AV_UNZIP_COUNTER];
    query.cachePolicy =[query hasCachedResult]? kPFCachePolicyCacheElseNetwork : kPFCachePolicyNetworkElseCache;
    query.maxCacheAge = 3600;
    [query whereKey:KEY_AV_EVENT equalTo:event];
    [query whereKey:KEY_AV_HASPWD equalTo:[NSNumber numberWithBool:hasPwd]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error!=nil) {
            NSLog(@"error:%@",error);
            return;
        }
        AVObject *obj = [objects firstObject];
        
        if (obj==nil) {
            obj = [AVObject objectWithClassName:KEY_AV_UNZIP_COUNTER];
            [obj setObject:event forKey:KEY_AV_EVENT];
            [obj setObject:[NSNumber numberWithBool:hasPwd] forKey:KEY_AV_HASPWD];
            [obj setObject:[NSNumber numberWithInteger:0] forKey:KEY_AV_COUNT];
        }
        [obj incrementKey:KEY_AV_COUNT];
        [obj saveEventually];
        NSLog(@"objects:%@",obj);
    }];
     */
}

@end
