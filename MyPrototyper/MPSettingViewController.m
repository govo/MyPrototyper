//
//  MPSettingViewController.m
//  MyPrototyper
//
//  Created by govo on 14-1-8.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import "MPSettingViewController.h"
#import "MPSettingUtils.h"

@interface MPSettingViewController ()

@end

@implementation MPSettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSDictionary *settings = MPSettingUtils.settings;
    NSLog(@"dict:%@",settings);
    self.switchScrollBar.on = [[settings objectForKey:kSettingScrollBar] boolValue];
    self.switchStatusBar.on = [[settings objectForKey:kSettingStatusBar] boolValue];
    self.switchLanceSpace.on = [[settings objectForKey:kSettingLandSpace] boolValue];
    
    UIViewController *parentController = self.presentingViewController;
    if (![parentController isKindOfClass:[UINavigationController class]]) {
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source



/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (IBAction)doSwitch:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    NSInteger tag = sw.tag;
    
    NSMutableDictionary *setting =[NSMutableDictionary dictionaryWithDictionary:MPSettingUtils.settings] ;
    switch (tag) {
        case 1:
            [setting setValue:[NSNumber numberWithBool:sw.on] forKey:kSettingScrollBar];
            break;
        case 2:
            [setting setValue:[NSNumber numberWithBool:sw.on] forKey:kSettingStatusBar];
            break;
        case 3:
            [setting setValue:[NSNumber numberWithBool:sw.on] forKey:kSettingLandSpace];
            break;
            
        default:
            break;
    }
    
    MPSettingUtils.settings = setting;
}
@end
