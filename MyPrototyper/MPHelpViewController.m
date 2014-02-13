//
//  MPHelpViewController.m
//  MyPrototyper
//
//  Created by govo on 14-2-5.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import "MPHelpViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MBProgressHUD.h"
#import "MPSettingUtils.h"

@interface MPHelpViewController (){
    NSInteger _shakePhoneCount;
    MBProgressHUD *HUD;
    BOOL _isShaking;
}
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;


@property (weak, nonatomic) IBOutlet UIView *contentView;

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

    self.pageControl.numberOfPages = _isFirstUse ? 5 :4;
    
    if (_isFirstUse) {
        [self setupFirstUse];
    }

    self.mainScrollView.translatesAutoresizingMaskIntoConstraints  = NO;
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Set the constraints for the scroll view and the image view.
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_mainScrollView, _contentView);


//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mainScrollView]|" options:0 metrics: 0 views:viewsDictionary]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mainScrollView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.mainScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.mainScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentView]|" options:0 metrics: 0 views:viewsDictionary]];

//    NSLog(@"size:%@,%@",NSStringFromCGRect(self.contentView.frame),NSStringFromCGSize(self.mainScrollView.bounds.size));

    
    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:YES];

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
    self.mainScrollView.contentSize = CGSizeMake(320*( _isFirstUse ? 5:4 ), self.view.frame.size.height - 70);
    [self.view layoutSubviews];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self becomeFirstResponder];

//    NSLog(@"viewDidAppear:%@,%@",NSStringFromCGRect(self.mainScrollView.frame),NSStringFromCGSize(self.mainScrollView.contentSize));

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
    if (self.pageControl.currentPage==(_isFirstUse?4:3)) {
        [self animateShakePhone];
    }
}
-(void)animateShakePhone
{
    if (_isShaking) {
        return;
    }
    UIView *view = [self.view viewWithTag:4];
    UIImageView *imageView = (UIImageView *)[view viewWithTag:20];
//    UILabel *desLabel = (UILabel *)[view viewWithTag:30];
    

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
-(BOOL)canBecomeFirstResponder
{
    return YES;
}
#pragma mark - handshake event
-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"motionBegan:%@",event);
}
-(void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"motionCancelled:%@",event);
}
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"motionEnded:%@",event);
    if (motion==UIEventSubtypeMotionShake) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        SystemSoundID soundID;
        
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"Tock" ofType:@"aiff"];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"xiaohuangrenxiasheng_02" ofType:@"mp3"];
//        NSLog(@"sound path :%@ ",path);
        if (path) {
            SystemSoundID theSoundID;
            OSStatus error =  AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &theSoundID);
            if (error == kAudioServicesNoError) {
                soundID = theSoundID;
                AudioServicesPlaySystemSound(soundID);
//                AudioServicesDisposeSystemSoundID(soundID);
            }else {
                NSLog(@"Failed to create sound ");
            }
        }
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"返回" otherButtonTitles: nil];
        [actionSheet showInView:self.view];
    }
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            if (self.navigationController) {
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            NSDictionary *globalSetting = [MPSettingUtils globalSetting];
            [globalSetting setValue:[NSNumber numberWithBool:NO] forKey:kSettingIsFirstUse];
            [MPSettingUtils saveGlobalSetting:globalSetting];
            break;
        }
        case 1:
        {
            
        }
            
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

@end
