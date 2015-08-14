//
//  FRSBaseViewController.m
//  FrescoNews
//
//  Created by Fresco News on 4/7/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSRootViewController.h"
#import "UIViewController+Additions.h"
#import "FRSBaseViewController.h"
#import "FRSGallery.h"
#import "GalleryHeader.h"
#import "AppDelegate.h"

@implementation FRSBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    
}

// good for wholesale resetting of the app
- (void)navigateToMainApp
{
    FRSRootViewController *rvc = (FRSRootViewController *)[[UIApplication sharedApplication] delegate].window.rootViewController;
    [rvc setRootViewControllerToTabBar];
}


- (void)navigateToCamera{
    FRSRootViewController *rvc = (FRSRootViewController *)[[UIApplication sharedApplication] delegate].window.rootViewController;
    [rvc setRootViewControllerToCamera];
}

- (void)navigateToFirstRun
{
    FRSRootViewController *rvc = (FRSRootViewController *)[[UIApplication sharedApplication] delegate].window.rootViewController;
    [rvc presentFirstRunViewController:self];
}

@end
