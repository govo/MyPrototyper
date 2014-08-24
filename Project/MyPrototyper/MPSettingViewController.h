//
//  MPSettingViewController.h
//  MyPrototyper
//
//  Created by govo on 14-1-8.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPLandespaceSettingViewController.h"

@interface MPSettingViewController : UITableViewController <MPLandespaceSettingDelegate>



@property (weak, nonatomic) IBOutlet UISwitch *switchScrollBar;
@property (weak, nonatomic) IBOutlet UISwitch *switchStatusBar;


@property (strong,nonatomic) NSString *path;

- (IBAction)doSwitch:(id)sender;

//-(void)setSettingForPath:(NSString *)path;

@end
