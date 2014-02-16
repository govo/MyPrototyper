//
//  MPSimpleWebViewController.m
//  MyPrototyper
//
//  Created by govo on 14-2-15.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import "MPSimpleWebViewController.h"


@interface MPSimpleWebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end

@implementation MPSimpleWebViewController

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
    UIViewController *parentController = self.presentingViewController;
    if (parentController!=nil) {
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(done:)];
        
        self.navigationItem.leftBarButtonItem = leftButton;
    }
    if (self.urlString) {
        [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
    }
}
-(void)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
