//
//  MPStorage.h
//  MyPrototyper
//
//  Created by govo on 14-1-6.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
@class MPProject;

#define TABLE_NAME @"projects"
#define FIELD_ID @"id"
#define FIELD_NAME @"name"
#define FIELD_PATH @"path"
#define FIELD_URL @"url"
#define FIELD_ZIP @"zip"
#define FIELD_ADD_TIME @"add_time"
#define FIELD_MODIFIED_TIME @"modified_time"

@interface MPStorage : NSObject


-(FMDatabase *)db;
-(BOOL)autoPrepareDocument;
-(NSArray *)getDatasWithLimit:(NSUInteger) limit;
-(NSInteger)insertData:(id)data;
-(NSInteger)updateData:(id)data;
-(NSInteger)deleteData:(id)data;

@end
