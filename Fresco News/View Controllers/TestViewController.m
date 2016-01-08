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
#import "UIFont+Fresco.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 300, self.view.frame.size.width, 50)];
    containerView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:containerView];
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/2, 50)];
    button1.backgroundColor = [UIColor blueColor];
    [button1 setTitle:@"Hello" forState:UIControlStateNormal];
    [button1.titleLabel setFont:[UIFont notaBoldWithSize:16]];
    [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:button1];
    
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, 0, self.view.frame.size.width/2, 50)];
    button2.backgroundColor = [UIColor orangeColor];
    [button2 setTitle:@"Hello" forState:UIControlStateNormal];
    [button2.titleLabel setFont:[UIFont notaBoldWithSize:16]];
    [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(tapped2) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:button2];

}

-(void)tapped{
    NSLog(@"Hello");
}

-(void)tapped2{
    NSLog(@"Hello");
}


-(void)alert{
    
    FRSAlertView *alertView = [[FRSAlertView alloc] initWithTitle:@"ANONYMITY" message:@"When you post a gallery anonymously, it will be invisible to the public on Fresco. News outlets can still purchase your photos and videos, but they will not credit you by name in their reporting." actionTitle:@"CANCEL" cancelTitle:@"POST ANONYMOUSLY" delegate:self];
    
    [alertView show];
//    [self.view addSubview:alertView];
    
    NSLog(@"alert");
    
}

@end
