//
//  FRSAboutFrescoViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 5/13/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSAboutFrescoViewController.h"

@interface FRSAboutFrescoViewController ()

@end

@implementation FRSAboutFrescoViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
}


-(void)configureUI {
    self.view.backgroundColor = [UIColor frescoBackgroundColorLight];
    [self configureNavigationBar];
}


-(void)configureNavigationBar {
    
    [self configureBackButtonAnimated:YES];
    self.navigationItem.title = @"ABOUT FRESCO";
}



@end
