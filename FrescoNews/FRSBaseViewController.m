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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    GalleryHeader *storyCellHeader = [tableView dequeueReusableCellWithIdentifier:[GalleryHeader identifier]];
    
    // remember, one story per section
    FRSGallery *gallery = [self.galleries objectAtIndex:section];
    [storyCellHeader setGallery:gallery];
    
    return storyCellHeader;
}

// good for wholesale resetting of the app
- (void)navigateToMainApp
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate setRootViewControllerToTabBar];
}

- (void)navigateToFirstRun
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate setRootViewControllerToFirstRun];
}

@end
