//
//  MPFeedbackViewController.m
//  MyPrototyper
//
//  Created by govo on 14-3-6.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import "MPFeedbackViewController.h"
#import "MBProgressHUD.h"
#import "MPAVObject.h"

@interface MPFeedbackViewController (){
    UIView *_activeField;
    UIEdgeInsets _defaultInset;
    CGRect _defaultScrollViewFrame;
    CGSize _kbSize;
    BOOL _isKbShowing;
    MBProgressHUD *_hud;
    
    NSString *_feedbackContent;
    NSString *_feedbackContact;
}

@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UITextField *contactInput;
@property (weak, nonatomic) IBOutlet UITextField *backgroundTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;


@end

@implementation MPFeedbackViewController

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
    self.title = NSLocalizedString(@"Feedback", @"feedback");
    if (self.navigationController) {
        self.submitButton.hidden = YES;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Sent",@"Sent") style:UIBarButtonItemStylePlain target:self action:@selector(submit:)];
    
    
    //修改输入框颜色
    self.contactInput.layer.cornerRadius = .0f;
    self.contactInput.layer.masksToBounds=YES;
    self.contactInput.layer.borderColor=[[UIColor lightGrayColor]CGColor];
    self.contactInput.layer.borderWidth= 1.0f;
    self.backgroundTextField.layer.cornerRadius = .0f;
    self.backgroundTextField.layer.masksToBounds=YES;
    self.backgroundTextField.layer.borderColor=[[UIColor lightGrayColor]CGColor];
    self.backgroundTextField.layer.borderWidth= 1.0f;

}
-(void)viewDidAppear:(BOOL)animated
{
    [self registerForKeyboardNotifications];
    _defaultInset = self.scrollView.contentInset;
    CGSize contentSize = self.view.frame.size;
    contentSize.height -= _defaultInset.top;
    self.scrollView.contentSize = self.contentView.frame.size;
    _defaultScrollViewFrame = self.scrollView.frame;

}
-(void)viewDidDisappear:(BOOL)animated
{
    [self unRegisterForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(MBProgressHUD *)whiteHUD
{
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:self.navigationController.view];
    if (self.navigationController) {
        [self.navigationController.view addSubview:hud];
    }else{
        [self.view addSubview:hud];
    }
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


- (IBAction)submit:(id)sender {
    NSString *contact = [self.contactInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (contact.length==0) {
        self.contactInput.text = nil;
        [self.contactInput becomeFirstResponder];
        return;
    }
    NSString *content = [self.contentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (content.length==0) {
        self.contentTextView.text = nil;
        [self.contentTextView becomeFirstResponder];
    }
    [self.contentTextView resignFirstResponder];
    [self.contactInput resignFirstResponder];
    
    
    //禁止重复提交
    if ([content isEqualToString:_feedbackContent]) {
        
        _hud = [self whiteHUD];
        _hud.mode = MBProgressHUDModeText;
        _hud.labelText = NSLocalizedString(@"errorContentResend", @"the same content");;
        [_hud show:YES];
        [_hud hide:YES afterDelay:2];
        return;
        
    }
    
    _hud = [self whiteHUDWithIndeterminate];
    _hud.labelText = NSLocalizedString(@"sending", @"sending");
    [_hud show:YES];
    [_hud hide:YES afterDelay:30];

    [MPAVObject sentFeedback:content contact:contact resultBlock:^(BOOL succeeded, NSError *error) {
        [_hud hide:NO];
        if (succeeded) {
            _feedbackContact = contact;
            _feedbackContent = content;
            _hud = [self whiteHUD];
            _hud.mode = MBProgressHUDModeText;
            _hud.labelText = NSLocalizedString(@"feedbackSendSuccessed", @"got the feedback");
            [_hud show:YES];
            [_hud hide:YES afterDelay:2];
        }else{
            NSLog(@"feedback error:%@",[error localizedDescription]);
            NSString *errorString = [error localizedDescription];
            if ([errorString rangeOfString:@"offline"].location!=NSNotFound) {
                errorString = NSLocalizedString(@"offlineAndLater", @"internet offline");
            }
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"feedbackSendFailed", @"failed sending feedback") message:errorString delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"ok") otherButtonTitles: nil];
            [alert show];
        }
    }];
    
}
- (IBAction)bgButton:(id)sender {
    [self.contactInput resignFirstResponder];
    [self.contentTextView resignFirstResponder];
}

#pragma mark - delegates

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeField = textField;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==self.contactInput) {
        [self.contentTextView becomeFirstResponder];
        if (_isKbShowing) {
            [self keyboardWasShown:nil];
        }
    }
    return NO;
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    _activeField = textView;
    if (_isKbShowing) {
        [self keyboardWasShown:nil];
    }
}
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChanged:)
                                                 name:UIKeyboardDidChangeFrameNotification object:nil];
    
}

- (void)unRegisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                    name:UIKeyboardDidShowNotification object:nil];

    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidChangeFrameNotification object:nil];
}


- (void)keyboardDidChanged:(NSNotification*)aNotification
{
    if (_isKbShowing) {
        [self keyboardWasShown:aNotification];
    }
}
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    _isKbShowing = YES;
    if (aNotification) {
        NSDictionary* info = [aNotification userInfo];
        _kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    }

    
    CGRect aRect = self.view.frame;
    aRect.size.height -= _kbSize.height;
    int height = _kbSize.height;
    CGRect frame = self.view.frame;
    frame.size.height-=(height+_defaultInset.bottom);
    self.scrollView.frame = frame;
    self.scrollView.contentSize = self.contentView.frame.size;
    [self.scrollView scrollRectToVisible:_activeField.frame animated:YES];
    
//    NSLog(@"frame:%@,%@",NSStringFromCGRect(self.contentView.frame),NSStringFromCGRect(self.scrollView.frame));
}



// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    _isKbShowing = NO;
    self.scrollView.frame = _defaultScrollViewFrame;
}

@end
