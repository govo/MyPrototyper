//
//  MPWebViewController.h
//  MyPrototyper
//
//  Created by govo on 14-1-8.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPSettingViewController.h"

@interface MPWebViewController : UIViewController<UIActionSheetDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webview;


-(void)loadHtmlAtPath:(NSString *)path;

@end
