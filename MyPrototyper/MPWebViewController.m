//
//  MPWebViewController.m
//  MyPrototyper
//
//  Created by govo on 14-1-8.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import "MPWebViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MPSettingUtils.h"
#import "MPNavigationController.h"

@interface MPWebViewController (){
    NSString *_filePath;
    BOOL _statusBar;
    BOOL _scrollBar;
    NSInteger _landSpace;
}

@end

@implementation MPWebViewController

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
    
    NSDictionary *settings = [MPSettingUtils settingsFromDirectory:_filePath];
    _statusBar = [[settings objectForKey:kSettingStatusBar] boolValue];
    return !_statusBar;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleBlackOpaque;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    [self loadWebView:_filePath];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    NSDictionary *settings = [MPSettingUtils settingsFromDirectory:_filePath];
    _statusBar = [[settings objectForKey:kSettingStatusBar] boolValue];
    _scrollBar = [[settings objectForKey:kSettingScrollBar] boolValue];
    _landSpace = [[settings objectForKey:kSettingLandSpace] integerValue];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }else{
        [[UIApplication sharedApplication] setStatusBarHidden:!_statusBar withAnimation:UIStatusBarAnimationNone];
    }

    
    self.webview.scrollView.showsHorizontalScrollIndicator = _scrollBar;
    self.webview.scrollView.showsVerticalScrollIndicator = _scrollBar;


}
-(void)viewDidAppear:(BOOL)animated
{
    
    [self becomeFirstResponder];
}
-(BOOL)canBecomeFirstResponder
{
    return YES;
}
#pragma mark - handshake event;
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion==UIEventSubtypeMotionShake) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"返回" otherButtonTitles:@"设置", nil];
        [actionSheet showInView:self.view];
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        SystemSoundID soundID;
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Tock" ofType:@"aiff"];

        if (path) {
            SystemSoundID theSoundID;
            OSStatus error =  AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &theSoundID);
            if (error == kAudioServicesNoError) {
                soundID = theSoundID;
                AudioServicesPlaySystemSound(soundID);
            }else {
                NSLog(@"Failed to create sound ");
            }
        }
    }
}

-(void)loadHtmlAtPath:(NSString *)path
{
    _filePath = path;
}
-(void)loadWebView:(NSString *)path
{

    NSFileManager *fileManager = [NSFileManager defaultManager];
    __block NSString *html = [path stringByAppendingPathComponent:@"index.html"];
    if (![fileManager fileExistsAtPath:html]) {
        html = nil;
        NSArray *array = [fileManager contentsOfDirectoryAtPath:path error:nil];
        //判断index.html是否不在第一层文件夹，最多只多做一层文件夹搜索
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *innerPath =[path stringByAppendingPathComponent:(NSString *)obj];
            BOOL isDirectory = NO;
            [fileManager fileExistsAtPath:innerPath isDirectory:&isDirectory];
            if (isDirectory) {
                html = [innerPath stringByAppendingPathComponent:@"index.html"];

                if ([fileManager fileExistsAtPath:html]) {
                    *stop = YES;
                }
            }
        }];
    }

    if (html==nil) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"找不到index.html" message:@"请确保第一层文件夹中包含index.html" delegate:self cancelButtonTitle:@"好" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:html]]];
    
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case 1:
        {
            UINavigationController *controller = (UINavigationController*)[self.storyboard instantiateViewControllerWithIdentifier:@"SettingNavigation"];
            [self shouldSettingControllerRotateBySetting:[MPSettingUtils settingsFromDirectory:_filePath] withNav:controller];

            UIViewController *vc = controller.viewControllers.firstObject;
            if ([vc isKindOfClass:[MPSettingViewController class]]) {
                MPSettingViewController *settingController = (MPSettingViewController *) vc;
                settingController.path = _filePath;
            }
            [self presentViewController:controller animated:YES completion:nil];

        }

    }
}

-(void)shouldSettingControllerRotateBySetting:(NSDictionary *)settings withNav:(UINavigationController *)nav
{
    
    if ([nav isKindOfClass:[MPNavigationController class]]) {
        MPNavigationController * navC = (MPNavigationController *)nav;
        
        NSInteger orientation = [[settings objectForKey:kSettingLandSpace] integerValue];
        
        switch (orientation) {
            case UIInterfaceOrientationMaskPortrait:
                navC.isRotateable = NO;
                break;
            case UIInterfaceOrientationMaskLandscape:
            case UIInterfaceOrientationMaskLandscapeLeft:
            case UIInterfaceOrientationMaskLandscapeRight:
                navC.isRotateable = YES;
                navC.orientationSupport = UIInterfaceOrientationMaskLandscapeLeft;
                break;
            case UIInterfaceOrientationMaskAllButUpsideDown:
            case UIInterfaceOrientationMaskAll:
                navC.isRotateable = YES;
                navC.orientationSupport = UIInterfaceOrientationMaskAllButUpsideDown;
                
                break;
        }
        
    }
}

-(BOOL)shouldAutorotate
{
    NSDictionary *settings = [MPSettingUtils settingsFromDirectory:_filePath];
    _landSpace = [[settings objectForKey:kSettingLandSpace] integerValue];
    return _landSpace==UIInterfaceOrientationMaskLandscapeLeft || _landSpace == UIInterfaceOrientationMaskAllButUpsideDown || _landSpace == UIInterfaceOrientationMaskAll;
}
- (NSUInteger)supportedInterfaceOrientations
{
    NSDictionary *settings = [MPSettingUtils settingsFromDirectory:_filePath];
    _landSpace = [[settings objectForKey:kSettingLandSpace] integerValue];
    NSInteger support = UIInterfaceOrientationMaskPortrait;
    switch (_landSpace) {
        case UIInterfaceOrientationMaskPortrait:
            support = UIInterfaceOrientationMaskPortrait;

            break;
        case UIInterfaceOrientationMaskLandscape:
        case UIInterfaceOrientationMaskLandscapeLeft:
        case UIInterfaceOrientationMaskLandscapeRight:
            support = UIInterfaceOrientationMaskLandscapeLeft;

            break;
            
        case UIInterfaceOrientationMaskAll:
        case UIInterfaceOrientationMaskAllButUpsideDown:
            support = UIInterfaceOrientationMaskAllButUpsideDown;

            break;
    }
    return support;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    NSDictionary *settings = [MPSettingUtils settingsFromDirectory:_filePath];
    _landSpace = [[settings objectForKey:kSettingLandSpace] integerValue];
    BOOL shouldRotate = NO;
    switch (_landSpace) {
        case UIInterfaceOrientationMaskPortrait:
            shouldRotate = toInterfaceOrientation == UIInterfaceOrientationPortrait;
            break;
        case UIInterfaceOrientationMaskLandscape:
        case UIInterfaceOrientationMaskLandscapeLeft:
        case UIInterfaceOrientationMaskLandscapeRight:
            shouldRotate = toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationMaskAll:
        case UIInterfaceOrientationMaskAllButUpsideDown:
            shouldRotate = toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }

    return shouldRotate;
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
