//
//  MPProject.m
//  MyPrototyper
//
//  Created by govo on 14-1-6.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import "MPProject.h"

@implementation MPProject

-(NSString *)description{
    return [NSString stringWithFormat:@"id:%ld,name:%@,path:%@,zip:%@,addTime:%@,modifiedTime:%@",(long)self.idx,self.name,self.path,self.zip,[NSDate dateWithTimeIntervalSince1970:self.addTime],[NSDate dateWithTimeIntervalSince1970:self.modifiedTime]];
}
@end