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
-(BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        self.orientationSupport = UIInterfaceOrientationMaskAll;
        self.isRotateable = YES;
    }else{
        self.orientationSupport = UIInterfaceOrientationMaskPortrait;
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        return;
    }
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) {
        self.navigationBar.barStyle = UIBarStyleBlack;
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
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
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        return self.isRotateable? self.orientationSupport : UIInterfaceOrientationMaskAll;
    }
    return self.isRotateable? self.orientationSupport : UIInterfaceOrientationMaskPortrait;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        if (self.isRotateable) {
            switch (self.orientationSupport) {
                case UIInterfaceOrientationMaskPortrait:
                    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation==UIInterfaceOrientationMaskPortraitUpsideDown);
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
        return self.isRotateable? YES : (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    if (self.isRotateable) {
        switch (self.orientationSupport) {
            case UIInterfaceOrientationMaskPortrait:
                if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
                    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation==UIInterfaceOrientationMaskPortraitUpsideDown);
                }
                return (interfaceOrientation == UIInterfaceOrientationPortrait);
                break;
            case UIInterfaceOrientationMaskLandscape:
            case UIInterfaceOrientationMaskLandscapeLeft:
            case UIInterfaceOrientationMaskLandscapeRight:
                return interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
                break;
            case UIInterfaceOrientationMaskAllButUpsideDown:
                if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
                    return interfaceOrientation!=UIInterfaceOrientationMaskPortraitUpsideDown;
                }
            case UIInterfaceOrientationMaskAll:
                if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
                    return YES;
                }
                return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
                break;
        }
    }
    return self.isRotateable ? interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown : (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
