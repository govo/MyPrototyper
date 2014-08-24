//
//  MPLandespaceSettingViewController.h
//  MyPrototyper
//
//  Created by govo on 14-1-18.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MPLandespaceSettingDelegate <NSObject>

-(void)didSelected:(NSInteger) orientation;

@end

@interface MPLandespaceSettingViewController : UITableViewController
@property(assign,nonatomic) id<MPLandespaceSettingDelegate> delegate;
@property(assign,nonatomic) NSInteger orientation;

@end
