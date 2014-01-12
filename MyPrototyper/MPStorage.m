//
//  MPStorage.m
//  MyPrototyper
//
//  Created by govo on 14-1-6.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import "MPStorage.h"
#import "MPProject.h"


@implementation MPStorage{
    FMDatabase *_db;
}

-(id)init{
    self = [super init];
    if (self) {
        if([self autoPrepareDocument]) return self;
    }
    return nil;
}

-(FMDatabase *)db
{
//    [self autoPrepareDocument];
    return _db;
}

-(BOOL)autoPrepareDocument{
/*    NSNumber *boolNumber = [NSNumber numberWithBool:YES];

    if (ADDRESS_KEYS_DICT==nil) {
        ADDRESS_KEYS_DICT = [NSDictionary dictionaryWithObjectsAndKeys:boolNumber,@"City",boolNumber,@"Country",boolNumber,@"CountryCode",boolNumber,@"FormattedAddressLines",boolNumber,@"Name",boolNumber,@"SubLocality",boolNumber,@"Thoroughfare",boolNumber,@"Street",boolNumber,@"add_time",boolNumber,@"last_modify",nil];
    }
    */
    
    if (_db==nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"storage.db"];
//        NSLog(@"path: %@",dbPath);
        
        _db = [FMDatabase databaseWithPath:dbPath] ;
    }
    
    if (![_db open]) {
        NSLog(@"Could not open db error:%d,%@",[_db lastErrorCode],[_db lastErrorMessage]);
        return NO;
    }
    NSString *query = [NSString stringWithFormat:@"create table if not exists %@ (%@ integer primary key, %@,%@,%@,%@,%@);",TABLE_NAME,FIELD_ID,FIELD_NAME,FIELD_PATH,FIELD_ZIP,FIELD_ADD_TIME,FIELD_MODIFIED_TIME];
    BOOL isTableCreated = [_db executeUpdate:query];
    if (!isTableCreated) {
        NSLog(@"isTableCreated error:%d,%@",_db.lastErrorCode,_db.lastErrorMessage);
        return NO;
    }
    
    /*
    //create to storage placemark Address
    NSString *addressSQL = [NSString stringWithFormat:@"create table if not exists address (id integer primary key, %@)",[[ADDRESS_KEYS_DICT allKeys] componentsJoinedByString:@","]];
    BOOL isAddressTableCreated = [db executeUpdate:addressSQL];
    if (!isAddressTableCreated) {
        NSLog(@"isAddressTableCreated error");
        return NO;
    }
     */
    NSLog(@"autoPrepareDocument ok");
    return YES;
    
}

-(NSArray *)getDatasWithLimit:(NSUInteger)limit
{
//    if (![self autoPrepareDocument]) {
//        return nil;
//    }
    NSString *query = [NSString stringWithFormat:@"select * from %@ order by %@ desc limit ?;",TABLE_NAME,FIELD_ADD_TIME];
    FMResultSet *rs = [_db executeQuery:query,[NSNumber numberWithInteger:limit]];
    
    NSMutableArray *array = [NSMutableArray array];
    
    while ([rs next]) {
        MPProject *project = [[MPProject alloc] init];
        project.idx = [rs longForColumn:FIELD_ID];
        project.name = [rs stringForColumn:FIELD_NAME];
        project.path = [rs stringForColumn:FIELD_PATH];
        project.zip = [rs stringForColumn:FIELD_ZIP];
        project.addTime = [rs longForColumn:FIELD_ADD_TIME];
        project.modifiedTime = [rs longForColumn:FIELD_MODIFIED_TIME];
        [array addObject:project];
    }
    [rs close];
    [_db closeOpenResultSets];
    return array;
    
}

-(NSInteger)insertData:(id)data
{
//    if (![self autoPrepareDocument]) {
//        return 0;
//    }
    NSArray *fields;
    NSString *query;
    if ([data isKindOfClass:[MPProject class]]) {
        MPProject *project = (MPProject *)data;
        
        fields = @[FIELD_NAME,FIELD_PATH,FIELD_ZIP,FIELD_ADD_TIME];
        query = [NSString stringWithFormat:@"insert into %@ (%@) values(?,?,?,?);",TABLE_NAME,[fields componentsJoinedByString:@","]];
        BOOL isUpdated = [_db executeUpdate:query,project.name,project.path,project.zip,[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]]];
        
        NSInteger lastInsertRowId = (NSInteger) [_db  lastInsertRowId];
        [_db  closeOpenResultSets];
        if (isUpdated) {
            NSLog(@"inserted");
//            NSInteger lastRowId=0;
//            FMResultSet *lastRowRs = [_db executeQuery:@"select last_insert_rowid();"];
//            if ([lastRowRs next]) {
//                lastRowId = [lastRowRs longForColumnIndex:0];
//            }
            return lastInsertRowId;
        }else{
            NSLog(@"save failed:%@",query);
            return 0;
        }
    }
    return 0;
}
-(NSInteger)updateData:(id)data
{
//    if (![self autoPrepareDocument]) {
//        return 0;
//    }
    if ([data isKindOfClass:[MPProject class]]) {
        
        MPProject *project = (MPProject *)data;
        NSString *query;
        BOOL isUpdated = NO;
        if (project.idx) {
            NSLog(@"update:%d，%@",project.idx,_db);
            query = [NSString stringWithFormat:@"update %@ set %@ = ?, %@=? where %@ = ?;",TABLE_NAME,FIELD_NAME,FIELD_MODIFIED_TIME,FIELD_ID];
            isUpdated = [_db executeUpdate:query,
                         project.name,
                         [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]],
                         nil];
            [_db closeOpenResultSets];
            if (isUpdated) {
                return project.idx;
            }
        }
    }
    return 0;
}

-(NSInteger)deleteData:(id)data
{
    
//    if (![self autoPrepareDocument]) {
//        return 0;
//    }
    if ([data isKindOfClass:[MPProject class]]) {
        MPProject *project = (MPProject *)data;
        if (!project.idx) {
            return 0;
        }
        NSString *query = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?;",TABLE_NAME,FIELD_ID];
        BOOL isDeleted = [_db executeUpdate:query,[NSNumber numberWithInteger:project.idx]];
        [_db  closeOpenResultSets];
        if (isDeleted) {
            NSLog(@"delete :%@",[NSNumber numberWithLong:project.idx]);
            return project.idx;
        }
    }
    
    return 0;
}
@end
