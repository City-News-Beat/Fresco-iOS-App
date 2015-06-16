//
//  SwitchingRootViewController.m
//  FrescoNews
//
//  Created by Jason Gresh on 6/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "SwitchingRootViewController.h"
#import "TabBarController.h"
#import "CameraViewController.h"

@interface SwitchingRootViewController () <UITabBarControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (nonatomic) BOOL returnToGalleryPost;
@end

@implementation SwitchingRootViewController

#pragma mark - View Controller swapping

- (void)setRootViewControllerToTabBar
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [[UITabBar appearance] setTintColor:[UIColor colorWithHex:[VariableStore sharedInstance].colorBrandDark]]; // setTintColor: before instantiating?

    self.tbc = (TabBarController *)[self setRootViewControllerWithIdentifier:@"tabBarController" underNavigationController:NO];
    [self setupTabBarAppearances:self.tbc];

    if (self.returnToGalleryPost) {
        self.returnToGalleryPost = NO;
        [self.tbc returnToGalleryPost];
    }
    else {
        self.tbc.selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"previouslySelectedTab"];
    }
}

- (void)setRootViewControllerToFirstRun
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [self setRootViewControllerWithIdentifier:@"firstRunViewController" underNavigationController:YES];
}

- (UIViewController *)setRootViewControllerWithIdentifier:(NSString *)identifier underNavigationController:(BOOL)underNavigationController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    
    UIViewController *viewController;
    if (underNavigationController) {
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:identifier];
        viewController = [[UINavigationController alloc] initWithRootViewController:vc];
        vc.navigationController.navigationBar.hidden = YES;
    }
    else
        viewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
    
    // swap the view controllers
    UIViewController *source = self.viewController;
    UIViewController *destination = viewController;
    UIViewController *container = self;
    
    [container addChildViewController:destination];
    
    // we'll always be replacing our whole view
    destination.view.frame = self.view.bounds;
    
    NSTimeInterval duration = 0.0; // default

    // Kind of gross
    if ([self.presentedViewController isKindOfClass:[CameraViewController class]]) {
        [[self.presentedViewController presentedViewController] dismissViewControllerAnimated:NO completion:^{
            [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        }];
        duration = 0.0; // TODO: Address the need for 0.0 duration special case
        self.returnToGalleryPost = YES;
    }

    if (source) {
        [source willMoveToParentViewController:nil];
        [container transitionFromViewController:source
                               toViewController:destination
                                       duration:duration
                                        options:UIViewAnimationOptionTransitionCrossDissolve
                                     animations:^{
                                     }
                                     completion:^(BOOL finished) {
                                         [source removeFromParentViewController];
                                         [destination didMoveToParentViewController:container];
                                     }];
    }
    else {
        [self.view addSubview:destination.view];
        [destination didMoveToParentViewController:container];
    }
    
    // store the new view controller
    self.viewController = viewController;
    
    return viewController;
}

- (void)setupTabBarAppearances:(UITabBarController *)tabBarController
{
    NSArray *highlightedTabNames = @[@"tab-home-highlighted",
                                     @"tab-stories-highlighted",
                                     @"tab-camera-highlighted",
                                     @"tab-assignments-highlighted",
                                     @"tab-profile-highlighted"];
    
    tabBarController.delegate = self;
    
    UITabBar *tabBar = tabBarController.tabBar;
    
    int i = 0;
    
    for (UITabBarItem *item in tabBar.items) {
        if (i == 2) {
            item.image = [[UIImage imageNamed:@"tab-camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            item.selectedImage = [[UIImage imageNamed:@"tab-camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            item.imageInsets = UIEdgeInsetsMake(5.5, 0, -5.5, 0);
        }
        else {
            item.selectedImage = [UIImage imageNamed:highlightedTabNames[i]];
        }
        ++i;
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UITabBarControllerDelegate methods

// Probably no longer needed, but doesn't hurt
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    return ![viewController isKindOfClass:[CameraViewController class]];
}

@end
