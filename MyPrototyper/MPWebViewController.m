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
#import "MPSettingWrapperViewController.h"

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
    
//    NSDictionary *settings = MPSettingUtils.settings;
//    return ![[settings objectForKey:kSettingStatusBar] boolValue];
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
    if (_statusBar) {
        CGRect frame = self.webview.frame;
        frame.size.height = self.view.frame.size.height-20;
        frame.origin.y = 20;
        self.webview.frame = frame;

    }else{
        
    }
    
    self.webview.scrollView.showsHorizontalScrollIndicator = _scrollBar;
    self.webview.scrollView.showsVerticalScrollIndicator = _scrollBar;
    [self becomeFirstResponder];

    //TODO: 是否每次重新显示都要加载一次？
//    [self loadWebView:_filePath];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}
#pragma mark - handshake event;
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion==UIEventSubtypeMotionShake) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出原型" otherButtonTitles:@"设置", nil];
        [actionSheet showInView:self.view];
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        SystemSoundID soundID;
        
        NSString *path = [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] pathForResource:@"Tock" ofType:@"aiff"];
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

//    NSLog(@"load html:%@",[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[path stringByAppendingPathComponent:@"index.html"]]]);
    
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[path stringByAppendingPathComponent:@"index.html"]]]];
    
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
            //TODO:使用setting,使用 container 形式，有等研究。。。。
            MPSettingWrapperViewController *controller = (MPSettingWrapperViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"settingContainer"];

            controller.path = _filePath;
            [self presentViewController:controller animated:YES completion:nil];
//            [self presentViewController:controller animated:YES completion:^{
//                UIViewController *firstChild = [controller.childViewControllers firstObject];
//                if ([firstChild isKindOfClass:[UINavigationController class]]) {
//                    UINavigationController *navC = (UINavigationController *)firstChild;
//                    UIViewController *navRootView = [navC.viewControllers firstObject];
////                    NSLog(@"presented:%@",navRootView);
//                    if ([navRootView isKindOfClass:[MPSettingViewController class]]) {
//                        MPSettingViewController *settingController = (MPSettingViewController *)navRootView;
//                        settingController.path = _filePath;
//                    }
//                }
//            }];
        }

    }
}

-(BOOL)shouldAutorotate
{
    NSDictionary *settings = [MPSettingUtils settingsFromDirectory:_filePath];
    _landSpace = [[settings objectForKey:kSettingLandSpace] integerValue];
    NSLog(@"shouldAutorotate:%@",(_landSpace==UIInterfaceOrientationMaskLandscapeLeft || _landSpace == UIInterfaceOrientationMaskAllButUpsideDown || _landSpace == UIInterfaceOrientationMaskAll)?@"yes":@"no");
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
            NSLog(@"supportedInterfaceOrientations:UIInterfaceOrientationMaskPortrait");
            break;
        case UIInterfaceOrientationMaskLandscape:
        case UIInterfaceOrientationMaskLandscapeLeft:
        case UIInterfaceOrientationMaskLandscapeRight:
            support = UIInterfaceOrientationMaskLandscapeLeft;
            NSLog(@"supportedInterfaceOrientations:UIInterfaceOrientationMaskLandscape");
            break;
            
        case UIInterfaceOrientationMaskAll:
        case UIInterfaceOrientationMaskAllButUpsideDown:
            support = UIInterfaceOrientationMaskAllButUpsideDown;
            NSLog(@"supportedInterfaceOrientations:UIInterfaceOrientationMaskAll");
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
    NSLog(@"shouldAutorotateToInterfaceOrientation:%@",shouldRotate?@"yes":@"no");
    return shouldRotate;
}

@end
