//
//  FRSBaseViewController.m
//  FrescoNews
//
//  Created by Zachary Mayberry on 4/7/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSRootViewController.h"
#import "FRSBaseViewController.h"
#import "FRSGallery.h"
#import "GalleryHeader.h"
#import "AppDelegate.h"

@implementation FRSBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
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
    [rvc setRootViewControllerToFirstRun];
}

@end
