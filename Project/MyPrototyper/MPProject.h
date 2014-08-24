//
//  MPProject.h
//  MyPrototyper
//
//  Created by govo on 14-1-6.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPProject : NSObject
@property(nonatomic) NSInteger idx;
@property(strong,nonatomic) NSString *name;
@property(strong,nonatomic) NSString *path;
@property(strong,nonatomic) NSString *zip;
@property(nonatomic) NSInteger addTime;
@property(nonatomic) NSInteger modifiedTime;

@end
