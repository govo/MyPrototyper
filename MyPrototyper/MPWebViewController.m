//
//  MPWebViewController.m
//  MyPrototyper
//
//  Created by govo on 14-1-8.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import "MPWebViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <CoreMotion/CoreMotion.h>
#import "MPSettingUtils.h"
#import "MPNavigationController.h"
#import "MPAVObject.h"

@interface MPWebViewController (){
    NSString *_filePath;
    BOOL _statusBar;
    BOOL _scrollBar;
    NSInteger _landSpace;
    BOOL _motionEnabled;
    NSString *_viewName;
}

@property(strong,nonatomic) CMMotionManager *motionManager;
@property(weak,nonatomic) UIActionSheet *globalActionSheet;

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
    
    _viewName = @"Preview";
    
    // Request to turn on accelerometer and begin receiving accelerometer events
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [self loadWebView:_filePath];
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .1;
}
-(void)viewDidAppear:(BOOL)animated
{
    [self setMotionEnabled:YES];
    [self motionStart];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];

#if TARGET_IPHONE_SIMULATOR
    [self becomeFirstResponder];
#endif

}
-(void)viewDidDisappear:(BOOL)animated{
    
    [self.motionManager stopAccelerometerUpdates];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification object:nil];
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
                }else{
                    
                    html = nil;
                }
            }
        }];
    }
    
    if (html==nil) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"No index.html found", nil) message:NSLocalizedString(@"Make sure the root folder contains index.html", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:html]]];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    
    [MPAVObject beginLogPageView:_viewName];

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MPAVObject endLogPageView:_viewName];
}
#pragma mark - handshake event
-(void)handShaked
{
    [self setMotionEnabled:NO];
    if (self.globalActionSheet!=nil) {
        [self.globalActionSheet dismissWithClickedButtonIndex:100 animated:NO];
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Operation", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Back", nil) otherButtonTitles:NSLocalizedString(@"Settings", nil), nil];
    self.globalActionSheet = actionSheet;
    
    if (NO && [UIApplication sharedApplication].windows.firstObject) {//AutoLayout 才需要
        [actionSheet showInView:[UIApplication sharedApplication].windows.firstObject];
    }else{
        [actionSheet showInView:self.view];
    }
    
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


#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:{
                [self dismissViewControllerAnimated:YES completion:nil];
                break;
            }
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
            
            
            //AVOCloud
            [MPAVObject onTapedWithEvent:KEY_AV_SET data:@"in"];

        }
            break;
        default:
            [self setMotionEnabled:YES];
            [self motionStart];

    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (self.globalActionSheet) {
        self.globalActionSheet = nil;
    }
}
#pragma mark - Rotations
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
                navC.orientationSupport = UIInterfaceOrientationMaskLandscape;
                break;
            case UIInterfaceOrientationMaskAllButUpsideDown:
            case UIInterfaceOrientationMaskAll:
                navC.isRotateable = YES;
                navC.orientationSupport =(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)?
                    UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskAllButUpsideDown;
                
                break;
        }
        
    }
}

-(BOOL)shouldAutorotate
{
    NSDictionary *settings = [MPSettingUtils settingsFromDirectory:_filePath];
    _landSpace = [[settings objectForKey:kSettingLandSpace] integerValue];
    return _landSpace==UIInterfaceOrientationMaskLandscape || _landSpace == UIInterfaceOrientationMaskAllButUpsideDown || _landSpace == UIInterfaceOrientationMaskAll;
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
            support = UIInterfaceOrientationMaskLandscape;

            break;
            
        case UIInterfaceOrientationMaskAll:
        case UIInterfaceOrientationMaskAllButUpsideDown:
            support = (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)?
            UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskAllButUpsideDown;
;

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
            shouldRotate = toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
            break;
        case UIInterfaceOrientationMaskAll:
        case UIInterfaceOrientationMaskAllButUpsideDown:
            shouldRotate = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }

    return shouldRotate;
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Motions
-(void)motionStart{
    if (!_motionEnabled) {
        return;
    }
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc]init] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        [self outputAccelertionData:accelerometerData.acceleration];
        if (error) {
            NSLog(@"motion error:%@",error);
            return;
        }
        
    }];
}
-(void)setMotionEnabled:(BOOL)enable
{
    _motionEnabled = enable;
    if (!enable) {
        [self.motionManager stopAccelerometerUpdates];
    }
}
-(void)receiveNotification:(NSNotification *)notification
{
    if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        [self.motionManager stopAccelerometerUpdates];
    }else{
        [self motionStart];
    }
}
-(void)outputAccelertionData:(CMAcceleration)acceleration
{
//    NSLog(@"x:%f,y:%f,z:%f",acceleration.x,acceleration.y,acceleration.z);
    double accelerameter =sqrt( pow( acceleration.x , 2 ) + pow( acceleration.y , 2 ) + pow( acceleration.z , 2) );
    if (accelerameter>2.7f && _motionEnabled) {
        [self setMotionEnabled:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handShaked];
        });
    }
}


#if TARGET_IPHONE_SIMULATOR
-(BOOL)canBecomeFirstResponder
{
    return YES;
}
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.subtype==UIEventSubtypeMotionShake) {
        [self handShaked];
    }
}
#endif

@end
