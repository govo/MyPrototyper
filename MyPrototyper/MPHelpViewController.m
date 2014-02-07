//
//  MPHelpViewController.m
//  MyPrototyper
//
//  Created by govo on 14-2-5.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import "MPHelpViewController.h"
#import "MBProgressHUD.h"


@interface MPHelpViewController (){
    NSInteger _shakePhoneCount;
    MBProgressHUD *HUD;
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

    self.pageControl.numberOfPages = 4;
    

    self.mainScrollView.translatesAutoresizingMaskIntoConstraints  = NO;
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Set the constraints for the scroll view and the image view.
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_mainScrollView, _contentView);
    NSLog(@"dictionary:%@",viewsDictionary);

//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mainScrollView]|" options:0 metrics: 0 views:viewsDictionary]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mainScrollView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.mainScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.mainScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_contentView]-0-|" options:0 metrics: 0 views:viewsDictionary]];

//    NSLog(@"size:%@,%@",NSStringFromCGRect(self.contentView.frame),NSStringFromCGSize(self.mainScrollView.bounds.size));




//    NSLog(@"child:%d",[[self.mainScrollView subviews] count]);
}
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}
-(void)viewDidLayoutSubviews
{
    self.mainScrollView.contentSize = CGSizeMake(320*4, self.view.frame.size.height - 70);
    [self.view layoutSubviews];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.isFirstUse) {
        //TODO:对首次使用，应该进行更细致的规划
        [HUD hide:NO];
        HUD = [self whiteHUD];
        HUD.mode = MBProgressHUDModeText;
        HUD.labelText = @"欢迎！";
//        HUD.detailsLabelText = @"首次使用请先花十来秒看一下帮助哦！";
        HUD.detailsLabelColor = [UIColor blackColor];
        [HUD show:YES];
        [HUD hide:YES afterDelay:3];
    }
//    
//    NSLog(@"viewDidAppear:%@,%@",NSStringFromCGRect(self.mainScrollView.frame),NSStringFromCGSize(self.mainScrollView.contentSize));

}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"scrollViewDidScroll:%@,%@,%@",NSStringFromCGPoint(scrollView.contentOffset),NSStringFromCGSize(scrollView.contentSize),NSStringFromCGRect(scrollView.frame));
    
    NSInteger pageWidth = self.mainScrollView.bounds.size.width;
    
    int page = floor((self.mainScrollView.contentOffset.x + pageWidth / 2) / pageWidth);
    self.pageControl.currentPage = page;
    if (page==3) {
        [self animateShakePhone];
    }
}

-(void)animateShakePhone
{
    UIView *view = [self.view viewWithTag:4];
    UIImageView *imageView = (UIImageView *)[view viewWithTag:20];
    UILabel *desLabel = (UILabel *)[view viewWithTag:30];
    

    imageView.transform = CGAffineTransformMakeRotation(0);
    [imageView stopAnimating];

    [UIView animateWithDuration:.25f delay:.8f options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{
        [UIView setAnimationRepeatCount:2];
        imageView.transform = CGAffineTransformMakeRotation(.28f);

    } completion:^(BOOL finished) {
    }];
    [NSTimer scheduledTimerWithTimeInterval:1.8f target:self selector:@selector(stopShakePhone:) userInfo:imageView repeats:NO];


    
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
    [imageView stopAnimating];
    [UIView animateWithDuration:.2f delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveLinear animations:^{
        imageView.transform =CGAffineTransformMakeRotation(0);

    } completion:nil];
    [timer invalidate];
    timer = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
