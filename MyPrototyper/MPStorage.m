//
//  MPStorage.m
//  MyPrototyper
//
//  Created by govo on 14-1-6.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import "MPStorage.h"
#import "FMDatabase.h"
#import "MPProject.h"


@implementation MPStorage{
    FMDatabase *_db;
}

-(BOOL)autoPrepareDocument{
/*    NSNumber *boolNumber = [NSNumber numberWithBool:YES];

    if (ADDRESS_KEYS_DICT==nil) {
        ADDRESS_KEYS_DICT = [NSDictionary dictionaryWithObjectsAndKeys:boolNumber,@"City",boolNumber,@"Country",boolNumber,@"CountryCode",boolNumber,@"FormattedAddressLines",boolNumber,@"Name",boolNumber,@"SubLocality",boolNumber,@"Thoroughfare",boolNumber,@"Street",boolNumber,@"add_time",boolNumber,@"last_modify",nil];
    }
    */
    
    if (_db==nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"storage.db"];
        NSLog(@"path: %@",dbPath);
        
        _db = [FMDatabase databaseWithPath:dbPath] ;
    }
    
    if (![_db open]) {
        NSLog(@"Could not open db.");
        return NO;
    }
    NSString *query = [NSString stringWithFormat:@"create table if not exists %@ (%@ integer primary key, %@,%@,%@)",TABLE_NAME,FIELD_ID,FIELD_NAME,FIELD_PATH,FIELD_ADD_TIME];
    BOOL isTableCreated = [_db executeUpdate:query];
    if (!isTableCreated) {
        NSLog(@"isTableCreated error");
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
    if (![self autoPrepareDocument]) {
        return nil;
    }
    NSString *query = [NSString stringWithFormat:@"select %@,%@,%@,%@ from %@ order by add_time desc limit ?",FIELD_ID,FIELD_NAME,FIELD_PATH,FIELD_ADD_TIME,TABLE_NAME];
    FMResultSet *rs = [_db executeQuery:query,[NSNumber numberWithInteger:limit]];
    
    NSMutableArray *array = [NSMutableArray array];
    
    while ([rs next]) {
        MPProject *project = [[MPProject alloc] init];
        project.idx = [rs longForColumn:@"id"];
        project.name = [rs stringForColumn:@"name"];
        project.path = [rs stringForColumn:@"path"];
        project.addTime = [rs longForColumn:@"add_time"];
        [array addObject:project];
    }
    
    return array;
    
}

-(NSInteger)storeData:(id)data
{
    if (![self autoPrepareDocument]) {
        return 0;
    }
    if ([data isKindOfClass:[MPProject class]]) {
        MPProject *project = (MPProject *)data;
        NSArray *fields = @[FIELD_NAME,FIELD_PATH,FIELD_ADD_TIME];
        NSString *query = [NSString stringWithFormat:@"insert into %@ (%@) values(?,?,?,?)",TABLE_NAME,[fields componentsJoinedByString:@","]];
        BOOL isUpdated = [_db executeUpdate:query,project.name,project.path,[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]]];
        
        if (isUpdated) {
            NSInteger lastRowId=0;
            FMResultSet *lastRowRs = [_db executeQuery:@"select last_insert_rowid();"];
            if ([lastRowRs next]) {
                lastRowId = [lastRowRs longForColumnIndex:0];
            }
            return lastRowId;
        }else{
            return 0;
        }
    }
    return 0;
}
@end
