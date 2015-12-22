//
//  TestViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "TestViewController.h"
#import "FRSAlertView.h"
#import "UIColor+Fresco.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 100, 600, 50);
    button.backgroundColor = [UIColor frescoOrangeColor];
    [button setTitle:@"" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(alert) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    
}


-(void)alert{
    
    FRSAlertView *alertView = [[FRSAlertView alloc] initWithTitle:@"ANONYMITY" message:@"Short titleShort titleShort titleShort titleShort titleShort titleShort titleShort titleShort titleShort titleShort titleShort titleShort titleShort titleShort titleShort titleShort titleShort titleShort title77" actionTitle:@"CANCEL" cancelTitle:@"POST ANONYMOUSLY" delegate:self];
    
    [alertView show];
//    [self.view addSubview:alertView];
    
    NSLog(@"alert");
    
}

@end
