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
@property (weak, nonatomic) IBOutlet UILabel *landspaceType;

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
    
    
    UIViewController *parentController = self.presentingViewController;
    if (parentController!=nil) {
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(done:)];
        
        self.navigationItem.leftBarButtonItem = leftButton;
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
//    NSLog(@"mypath:%@",self.path);
    [self setSettingForPath:self.path];
}



#pragma mark - Table view  source



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
    
    NSMutableDictionary *setting =[NSMutableDictionary dictionaryWithDictionary:self.path?[MPSettingUtils settingsFromDirectory:self.path]: MPSettingUtils.settings] ;
    switch (tag) {
        case 1:
            [setting setValue:[NSNumber numberWithBool:sw.on] forKey:kSettingScrollBar];
            break;
        case 2:
            [setting setValue:[NSNumber numberWithBool:sw.on] forKey:kSettingStatusBar];
            break;
    }
    if (self.path) {
        [MPSettingUtils saveSettings:setting toDirectory:self.path];
    }else{
        [MPSettingUtils saveSettings:setting];
    }
}

-(void)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)setSettingForPath:(NSString *)path
{
    NSDictionary *settings = path?[MPSettingUtils settingsFromDirectory:path]: MPSettingUtils.settings;

    self.switchScrollBar.on = [[settings objectForKey:kSettingScrollBar] boolValue];
    self.switchStatusBar.on = [[settings objectForKey:kSettingStatusBar] boolValue];
    
    [self setLandspaceTypeForOrientation:[[settings objectForKey:kSettingLandSpace] integerValue]];
    
    
}
-(void)setLandspaceTypeForOrientation:(NSInteger)orientation
{
    switch (orientation) {
        case UIInterfaceOrientationMaskPortrait:
            self.landspaceType.text = @"竖屏";
            break;
        case UIInterfaceOrientationMaskLandscape:
        case UIInterfaceOrientationMaskLandscapeLeft:
        case UIInterfaceOrientationMaskLandscapeRight:
            self.landspaceType.text = @"横屏";
            break;
        case UIInterfaceOrientationMaskAllButUpsideDown:
        case UIInterfaceOrientationMaskAll:
            self.landspaceType.text = @"自由";
            break;
    }
}

-(void)didSelected:(NSInteger)orientation{

    NSDictionary *settings = self.path?[MPSettingUtils settingsFromDirectory:self.path]: MPSettingUtils.settings;
    [settings setValue:[NSNumber numberWithInteger:orientation] forKey:kSettingLandSpace];
    if (self.path) {
        
        [MPSettingUtils saveSettings:settings toDirectory:self.path];
    }else{
        [MPSettingUtils saveSettings:settings];
    }
    [self setLandspaceTypeForOrientation:orientation];
}

#pragma mark prepareForSegue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([segue.identifier isEqualToString:@"LandspaceSetting"]) {
        MPLandespaceSettingViewController *landspaceController = (MPLandespaceSettingViewController *)segue.destinationViewController;
        NSDictionary *settings = self.path?[MPSettingUtils settingsFromDirectory:self.path]: MPSettingUtils.settings;
        landspaceController.orientation = [[settings objectForKey:kSettingLandSpace] integerValue];
        landspaceController.delegate = self;

    }
}
@end
