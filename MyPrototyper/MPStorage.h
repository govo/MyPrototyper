//
//  MPStorage.h
//  MyPrototyper
//
//  Created by govo on 14-1-6.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MPProject;

#define TABLE_NAME @"projects"
#define FIELD_ID @"id"
#define FIELD_NAME @"name"
#define FIELD_PATH @"path"
#define FIELD_ADD_TIME @"add_time"

@interface MPStorage : NSObject

-(BOOL)autoPrepareDocument;
-(NSArray *)getDatasWithLimit:(NSUInteger) limit;
-(NSInteger)storeData:(id)data;

@end
