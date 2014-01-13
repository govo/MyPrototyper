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

@interface MPWebViewController (){
    NSString *_filePath;
    BOOL _statusBar;
    BOOL _scrollBar;
    BOOL _landSpace;
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
    
    NSDictionary *settings = MPSettingUtils.settings;
    _statusBar = [[settings objectForKey:kSettingStatusBar] boolValue];
    _scrollBar = [[settings objectForKey:kSettingScrollBar] boolValue];
    _landSpace = [[settings objectForKey:kSettingLandSpace] boolValue];
    if (_statusBar) {
        CGRect frame = self.webview.frame;
        frame.size.height = self.view.frame.size.height-20;
        frame.origin.y = 20;
        self.webview.frame = frame;
        NSLog(@"statubar:%@",self.webview);
    }else{
        
    }

    self.webview.scrollView.showsHorizontalScrollIndicator = _scrollBar;
    self.webview.scrollView.showsVerticalScrollIndicator = _scrollBar;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [self becomeFirstResponder];
    [self loadWebView:_filePath];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}
#pragma mark - handshake event;
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion==UIEventSubtypeMotionShake) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出" otherButtonTitles:@"设置", nil];
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
    NSLog(@"path:%@",path);
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
            //TODO:使用setting
            MPSettingViewController *setting = (MPSettingViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"setting"];
            [self presentViewController:setting animated:YES completion:nil];
        }
        default:
            break;
    }
}

@end
