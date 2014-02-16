//
//  MPHelpViewController.h
//  MyPrototyper
//
//  Created by govo on 14-2-5.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#define kReadyToRateTag  888
#define kFirstUseTag     102

@interface MPHelpViewController : UIViewController<UIScrollViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate,MFMailComposeViewControllerDelegate,UINavigationControllerDelegate>

@property (assign,nonatomic) BOOL isFirstUse;

@end
