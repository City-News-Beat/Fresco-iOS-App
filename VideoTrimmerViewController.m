//
//  VideoTrimmerViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 4/5/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "VideoTrimmerViewController.h"
#import "UIFont+Fresco.h"
#import "UIColor+Fresco.h"

@interface VideoTrimmerViewController ()

@end

@implementation VideoTrimmerViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
}

-(void)configureUI {
    self.view.backgroundColor = [UIColor blackColor];

    [self configureTopContainer];
}

-(void)configureTopContainer {
    UIView *topContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    [self.view addSubview:topContainer];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, self.view.frame.size.width, 19)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"TRIM VIDEO TO 1:00";
    titleLabel.font = [UIFont notaBoldWithSize:17];
    [topContainer addSubview:titleLabel];
    
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    dismissButton.frame = CGRectMake(12, 30, 24, 24);
    dismissButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 0, 0);
    [dismissButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchDown];
    [dismissButton setTintColor:[UIColor whiteColor]];
    [topContainer addSubview:dismissButton];
    
    
    /* DEBUG */
//    topContainer.backgroundColor = [UIColor redColor];
//    titleLabel.backgroundColor = [UIColor greenColor];
}

-(void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
