//
//  MPHelpViewController.m
//  MyPrototyper
//
//  Created by govo on 14-2-5.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import "MPHelpViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <CoreMotion/CoreMotion.h>
#import "MPAppDelegate.h"
#import "MBProgressHUD.h"
#import "MPSettingUtils.h"
#import "MPNavigationController.h"
#import "iRate.h"
#import "MPAVObject.h"



@interface MPHelpViewController (){
    NSInteger _shakePhoneCount;
    MBProgressHUD *HUD;
    BOOL _isShaking;
    BOOL _motionEnabled;
    int _maxPageIndex;
    NSString *_viewName;
}

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (strong,nonatomic) CMMotionManager *motionManager;

@property (weak,nonatomic) UIActionSheet *globalActionSheet;

@end

@implementation MPHelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(MBProgressHUD *)whiteHUD
{
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
    hud.color = [UIColor colorWithWhite:.95 alpha:1];
    hud.labelColor = [UIColor colorWithWhite:.1 alpha:1];
    
    return hud;
}
-(MBProgressHUD *)whiteHUDWithIndeterminate
{
    MBProgressHUD *hud=[self whiteHUD];
    hud.mode = MBProgressHUDModeCustomView;
    UIActivityIndicatorView *indView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indView.color = [UIColor blackColor];
    [indView startAnimating];
    hud.customView = indView;
    return hud;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Help", @"help");
    
	// Do any additional setup after loading the view.
    self.mainScrollView.pagingEnabled = YES;
    self.mainScrollView.delegate = self;
    self.mainScrollView.scrollEnabled = YES;

    self.mainScrollView.frame = self.view.frame;
    
    
    CGRect frame = self.contentView.frame;
    frame.size.height = self.mainScrollView.frame.size.height;
    self.contentView.frame = frame;

    
    self.mainScrollView.showsVerticalScrollIndicator = NO;
    self.mainScrollView.showsHorizontalScrollIndicator = NO;
    self.mainScrollView.bounces = NO;

    self.pageControl.numberOfPages = 5;
    
    [self setupFirstUse];
    if (_isFirstUse) {
        _viewName = @"FirstUseHelp";
    }else{
        _viewName = @"Help";
    }

    self.mainScrollView.translatesAutoresizingMaskIntoConstraints  = NO;
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (self.navigationController) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"More",@"more") style:UIBarButtonItemStylePlain target:self action:@selector(showMore:)];
    }
    
    // Set the constraints for the scroll view and the image view.
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_mainScrollView, _contentView);


//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mainScrollView]|" options:0 metrics: 0 views:viewsDictionary]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mainScrollView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.mainScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.mainScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentView]|" options:0 metrics: 0 views:viewsDictionary]];
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .1;


    
}
-(void)showFeedback
{
    UIViewController *cv = [self.storyboard instantiateViewControllerWithIdentifier:@"Feedback"];
    [self.navigationController pushViewController:cv animated:YES];
}
-(void)showMore:(id)sender
{
    [self handShaked];
}
/*
-(void)prepareSubViews
{
    [self.contentView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *view = (UIView *)obj;
        UIImageView *imageView = (UIImageView *)[view viewWithTag:10];
        UIView *textView = (UIView *)[view viewWithTag:20];
        
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(view, imageView,textView);
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|" options:0 metrics:0 views:viewsDictionary]];
    }];
}
*/
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}
-(void)viewDidLayoutSubviews
{
    self.mainScrollView.contentSize = CGSizeMake(320*( 5 ), self.view.frame.size.height - 70);
    [self.view layoutSubviews];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if (_isFirstUse && NSFoundationVersionNumber<=NSFoundationVersionNumber_iOS_6_1) {
//        [[UIApplication sharedApplication] setStatusBarHidden:YES];
//    }
    
    [MPAVObject beginLogPageView:_viewName];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MPAVObject endLogPageView:_viewName];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.motionManager stopAccelerometerUpdates];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification object:nil];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"scrollViewDidScroll:%@,%@,%@",NSStringFromCGPoint(scrollView.contentOffset),NSStringFromCGSize(scrollView.contentSize),NSStringFromCGRect(scrollView.frame));
    
    NSInteger pageWidth = self.mainScrollView.bounds.size.width;
    
    int page = floor((self.mainScrollView.contentOffset.x + pageWidth / 2) / pageWidth);
    self.pageControl.currentPage = page;
    
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.pageControl.currentPage==(4)) {
        [self animateShakePhone];
    }
    _maxPageIndex = MAX(_maxPageIndex, self.pageControl.currentPage);
}
-(void)animateShakePhone
{
    if (_isShaking) {
        return;
    }
    UIView *view = [self.view viewWithTag:4];
    UIImageView *imageView = (UIImageView *)[view viewWithTag:20];

    imageView.transform = CGAffineTransformMakeRotation(0);

    _isShaking = YES;
    [UIView animateWithDuration:.25f delay:.8f options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{
        [UIView setAnimationRepeatCount:2];
        imageView.transform = CGAffineTransformMakeRotation(.28f);

    } completion:^(BOOL finished) {
    }];
    [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(stopShakePhone:) userInfo:imageView repeats:NO];
    
}
/*
CGAffineTransform CGAffineTransformMakeRotationAt(CGFloat angle, CGPoint pt){
    const CGFloat fx = pt.x;
    const CGFloat fy = pt.y;
    const CGFloat fcos = cos(angle);
    const CGFloat fsin = sin(angle);
    return CGAffineTransformMake(fcos, fsin, -fsin, fcos, fx - fx * fcos + fy * fsin, fy - fx * fsin - fy * fcos);
}
 */
-(void)stopShakePhone:(NSTimer *)timer
{
    UIImageView *imageView = (UIImageView *)timer.userInfo;

    [UIView animateWithDuration:.25f delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveLinear animations:^{
        imageView.transform =CGAffineTransformMakeRotation(0);

        
    } completion:^(BOOL finished){
        if (finished) {
            _isShaking = NO;
        }
    }];
    [timer invalidate];
    timer = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - handshake event

-(void)handShaked
{
    [self setMotionEnabled:NO];
    
    if (self.globalActionSheet) {
        [self.globalActionSheet dismissWithClickedButtonIndex:100 animated:NO];
    }
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    SystemSoundID soundID;
    
    //        NSString *path = [[NSBundle mainBundle] pathForResource:@"Tock" ofType:@"aiff"];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"mytick" ofType:@"mp3"];
    //        NSLog(@"sound path :%@ ",path);
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
    UIActionSheet *actionSheet = nil;
    if(_isFirstUse){
        
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Operation", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Back", nil) otherButtonTitles:nil];
        
    }else if (YES || [[iRate sharedInstance] shouldPromptForRating]) {
        
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Operation", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Back", nil) otherButtonTitles:NSLocalizedString(@"Feedback", nil),NSLocalizedString(@"Email me", nil),NSLocalizedString(@"rateMe", nil), nil];
        actionSheet.tag = kReadyToRateTag;
        
    }else{
        
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Operation", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Back", nil) otherButtonTitles:NSLocalizedString(@"Feedback", nil),NSLocalizedString(@"Email me", nil), nil];
        
    }
    self.globalActionSheet = actionSheet;
//    NSLog(@"self.view:%@\n======\nscollview:%@\n=====\nsubviews:%@",self.view,self.mainScrollView,self.view.subviews);
    if ([UIApplication sharedApplication].windows.firstObject) {
        [actionSheet showInView:[UIApplication sharedApplication].windows.firstObject];
    }else{
        [actionSheet showInView:self.view];
    }

}

-(void)dismissMe
{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    if (_isFirstUse) {
        
        NSDictionary *globalSetting = [MPSettingUtils globalSetting];
        [globalSetting setValue:[NSNumber numberWithBool:NO] forKey:kSettingIsFirstUse];
        [MPSettingUtils saveGlobalSetting:globalSetting];
        _isFirstUse = NO;
        
    }
    
}



#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_isFirstUse) {
        switch (buttonIndex) {
            case 0:
                [self dismissMe];
                
                //AVOCloud
                [MPAVObject onTapedWithEvent:KEY_AV_HELP_FIRST_COUNTER data:[NSString stringWithFormat:@"%d",_maxPageIndex]];
                
                break;
            default:
                [self setMotionEnabled:YES];
                [self motionStart];
                break;
        }
        return;
    }
    switch (buttonIndex) {
        case 0:
        {
            [self dismissMe];
            break;
        }
        case 1:
        {
            [self showFeedback];
            break;
        }
        case -1:
        {
            return;
            NSString *twitterURL = NSLocalizedString(@"twitterUrl", nil);
            
            NSURL *URL = [NSURL URLWithString:NSLocalizedString(@"twitterScheme", nil)];
            
            NSString *copyString = nil;
            
            BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:URL];
            if (canOpen) {
                copyString = NSLocalizedString(@"Copy Username and Go", nil);
            }else{
                copyString = NSLocalizedString(@"Copy Username", nil);
            }
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"twitterMessage", nil),twitterURL,NSLocalizedString(@"twitterName", nil)];
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"twitter", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Copy Link", nil),copyString, nil];
            if (canOpen) {
                alert.tag = 11;
            }

            [alert show];
            break;
        }
        case 2:
        {
            if (![MFMailComposeViewController canSendMail]) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"emailErrorTitle", nil) message:NSLocalizedString(@"emailErrorMessage", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles: nil];
                [alertView show];
                return;
            }
            MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
            mailController.mailComposeDelegate = self;
            [mailController setSubject:NSLocalizedString(@"emailSubject", nil)];
            [mailController setToRecipients:@[@"govomusic@gmail.com"]];
            
            [self presentViewController:mailController animated:YES completion:nil];

            break;
        }
        case 3:
        {
            [self setMotionEnabled:YES];
            [self motionStart];
            if (actionSheet.tag == kReadyToRateTag) {
                [[iRate sharedInstance] openRatingsPageInAppStore];
            }
            break;
        }
        default:
            [self setMotionEnabled:YES];
            [self motionStart];
            
    }
}


#pragma mark - FirstUse
-(void)setupFirstUse
{
    int count = (int)self.contentView.subviews.count;
    [self.contentView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        UIView *view = (UIView *)obj;
        view.hidden = NO;
        CGRect frame = view.frame;
        frame.origin.x=(count-idx-1)*frame.size.width;
        view.frame = frame;
        UIView *contentView = self.contentView;
//        NSLog(@"setupFirstUse:%f,%@",frame.origin.x,view);
        
        
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(view,contentView);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%f-[view]",frame.origin.x ] options:0 metrics:0 views:viewsDictionary]];
    }];
//    CGRect frame = self.contentView.frame;
//    frame.size.width = self.contentView.subviews.count*320;
//    self.contentView.frame = frame;
}
#pragma mark - rotation
-(BOOL)shouldAutorotate
{
    return NO;
}
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark - statusbar
-(BOOL)prefersStatusBarHidden
{
    return _isFirstUse;
}

#pragma mark - AlertView
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self setMotionEnabled:YES];
    [self motionStart];
    switch (buttonIndex) {
        case 1:
            [UIPasteboard generalPasteboard].string = NSLocalizedString(@"twitterUrl", nil);
            break;
        case 2:
            
            [UIPasteboard generalPasteboard].string = NSLocalizedString(@"twitterName", nil);
            if (alertView.tag==11) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"twitterScheme", nil)]];
            }
            break;
            
        default:
            break;
    }
}
#pragma mark - MFMail Delegate
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSLog(@" mailComposeController didfinish");
    [self dismissViewControllerAnimated:YES completion:nil];
    switch (result) {
        case MFMailComposeResultSent:
        {
            MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:hud];
            hud.color = [UIColor colorWithWhite:.95 alpha:1];
            hud.labelColor = [UIColor colorWithWhite:.1 alpha:1];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = NSLocalizedString(@"Thanks for feedback", nil);
            [hud show:YES];
            [hud hide:YES afterDelay:3];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Motions
-(void)motionStart{
    if (!_motionEnabled) {
        return;
    }
    NSLog(@"start it");
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
    double accelerameter =sqrt( pow( acceleration.x , 2 ) + pow( acceleration.y , 2 ) + pow( acceleration.z , 2) );
//    NSLog(@"acceleration:%f",accelerameter);
    if (accelerameter>2.3f && _motionEnabled) {
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
