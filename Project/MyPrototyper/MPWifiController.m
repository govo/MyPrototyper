//
//  MPWifiController.m
//  MyPrototyper
//
//  Created by govo on 15/2/8.
//  Copyright (c) 2015年 me.govo. All rights reserved.
//

#import "MPWifiController.h"
#import "MPWifiUplader.h"

@interface MPWifiController ()
@property (weak, nonatomic) IBOutlet UISwitch *switcher;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *hostText;
@property (weak, nonatomic) IBOutlet UITextView *desText;


@end

@implementation MPWifiController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title =  NSLocalizedString(@"wifiTitle", nil);
    self.desText.text = NSLocalizedString(@"wifiDescription", nil);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.switcher setOn:[MPWifiUplader isRunning]];
    
    self.hostText.text = [[MPWifiUplader serverURL] absoluteString];
    self.desText.hidden = !self.switcher.isOn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onSwitch:(id)sender {
    [MPWifiUplader runUplader:self.switcher.isOn];
    self.hostText.text = [[MPWifiUplader serverURL] absoluteString];
    self.desText.hidden = !self.switcher.isOn;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
