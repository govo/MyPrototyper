//
//  MPSettingWrapperViewController.m
//  MyPrototyper
//
//  Created by govo on 14-1-15.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import "MPSettingWrapperViewController.h"
#import "MPSettingViewController.h"

@interface MPSettingWrapperViewController (){

}

@end

@implementation MPSettingWrapperViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if (self.path) {
        MPSettingViewController *settingController=nil;
        UIViewController *firstChild = segue.destinationViewController;

        if ([firstChild isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navC = (UINavigationController *)firstChild;
            UIViewController *navRootView = [navC.viewControllers firstObject];
            if ([navRootView isKindOfClass:[MPSettingViewController class]]) {
                settingController = (MPSettingViewController *)navRootView;
            }
        }else if ([firstChild isKindOfClass:[MPSettingViewController class]]) {
            settingController = (MPSettingViewController *)firstChild;
        }
        settingController.path = self.path;
    }
}



@end
