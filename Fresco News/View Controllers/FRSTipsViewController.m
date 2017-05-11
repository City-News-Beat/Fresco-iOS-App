//
//  FRSTipsViewController.m
//  Fresco
//
//  Created by Omar Elfanek on 5/5/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSTipsViewController.h"
#import "FRSTipsHeaderView.h"
#import <Smooch/Smooch.h>

@implementation FRSTipsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
}



#pragma mark - UI Configuration

- (void)configureUI {
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self configureNavigationBar];
    [self configureHeader];
}

- (void)configureNavigationBar {
    [self configureBackButtonAnimated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.titleView.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"TIPS";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{ NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont notaBoldWithSize:17] }];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *chatBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chat-bubbles"] style:UIBarButtonItemStylePlain target:self action:@selector(presentSmooch)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItems = @[ chatBarButtonItem ];
}

- (void)configureHeader {
    FRSTipsHeaderView *tipsHeaderView = [[FRSTipsHeaderView alloc] init];
    [self.view addSubview:tipsHeaderView];
}



#pragma mark - Support

/**
 Presents the in-app support chat via Smooch.
 */
- (void)presentSmooch {
    [Smooch show];
}



@end
