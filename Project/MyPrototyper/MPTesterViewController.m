//
//  MPTesterViewController.m
//  MyPrototyper
//
//  Created by govo on 14-2-16.
//  Copyright (c) 2014年 me.govo. All rights reserved.
//

#import "MPTesterViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface MPTesterViewController (){
    NSInteger x,y;
}

@property(strong,nonatomic) CMMotionManager *motionManager;
@property(strong,nonatomic) NSTimer *timer;

@end

@implementation MPTesterViewController

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
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .2;
    self.motionManager.gyroUpdateInterval = .2;
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 [self outputAccelertionData:accelerometerData.acceleration];
                                                 if(error){
                                                     
                                                     NSLog(@"%@", error);
                                                 }
                                             }];
    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
                                    withHandler:^(CMGyroData *gyroData, NSError *error) {
                                        [self outputRotationData:gyroData.rotationRate];
                                    }];

    
    

}
-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    
}
-(void)outputRotationData:(CMRotationRate)rotation
{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
