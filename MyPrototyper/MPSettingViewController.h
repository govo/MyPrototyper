//
//  MPSettingViewController.h
//  MyPrototyper
//
//  Created by govo on 14-1-8.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MPSettingViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UISwitch *switchScrollBar;
@property (weak, nonatomic) IBOutlet UISwitch *switchStatusBar;
@property (weak, nonatomic) IBOutlet UISwitch *switchLanceSpace;
- (IBAction)doSwitch:(id)sender;

@end
