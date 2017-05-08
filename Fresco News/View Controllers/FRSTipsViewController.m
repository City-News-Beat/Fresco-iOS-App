//
//  FRSTipsViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 5/5/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSTipsViewController.h"

@interface FRSTipsViewController ()

@end

@implementation FRSTipsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"TIPS";
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self configureBackButtonAnimated:YES];
}


@end
