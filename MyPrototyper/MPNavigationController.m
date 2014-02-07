//
//  MPSettingNavigationController.m
//  MyPrototyper
//
//  Created by govo on 14-2-4.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import "MPNavigationController.h"

@interface MPNavigationController ()

@end

@implementation MPNavigationController

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
    self.orientationSupport = UIInterfaceOrientationMaskPortrait;
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) {
        self.navigationBar.barStyle = UIBarStyleBlack;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - rotation
-(BOOL)shouldAutorotate
{
    return self.isRotateable;
}
-(NSUInteger)supportedInterfaceOrientations
{
    return self.isRotateable? self.orientationSupport : UIInterfaceOrientationMaskPortrait;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (self.isRotateable) {
        switch (self.orientationSupport) {
            case UIInterfaceOrientationMaskPortrait:
                return (interfaceOrientation == UIInterfaceOrientationPortrait);
                break;
            case UIInterfaceOrientationMaskLandscape:
            case UIInterfaceOrientationMaskLandscapeLeft:
            case UIInterfaceOrientationMaskLandscapeRight:
                return interfaceOrientation == UIInterfaceOrientationLandscapeLeft;
                break;
            case UIInterfaceOrientationMaskAllButUpsideDown:
            case UIInterfaceOrientationMaskAll:
                return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
                break;
        }
    }
    return self.isRotateable ? interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown : (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
