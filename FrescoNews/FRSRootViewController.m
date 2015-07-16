//
//  SwitchingRootViewController.m
//  FrescoNews
//
//  Created by Fresco News on 6/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import AVFoundation;

#import "FRSRootViewController.h"
#import "FRSTabBarController.h"
#import "CameraViewController.h"
#import "FRSOnboardPageViewController.h"

@interface FRSRootViewController () <UITabBarControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewContainer;

@property (nonatomic) BOOL returnToGalleryPost;

@end

@implementation FRSRootViewController

#pragma mark - View Controller swapping

- (void)setRootViewControllerToTabBar
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithHex:[VariableStore sharedInstance].colorBrandDark]]; // setTintColor:

    self.tbc = (FRSTabBarController *)[self rootViewControllerWithIdentifier:@"tabBarController" underNavigationController:NO];
    
    [self switchRootViewController:self.tbc];
    
    if (self.returnToGalleryPost) {
        self.returnToGalleryPost = NO;
        [self.tbc returnToGalleryPost];
    }
    else {
        NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"previouslySelectedTab"];
        self.tbc.selectedIndex = (index == 4 ? 0 : index);
    }
}

- (void)setRootViewControllerToCamera{
    [self.tbc presentCamera];
}

- (void)setRootViewControllerToFirstRun
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    [self switchRootViewController:[self rootViewControllerWithIdentifier:@"firstRunViewController" underNavigationController:YES]];
}

- (void)setRootViewControllerToOnboard{
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    FRSOnboardPageViewController *onboardController = [[FRSOnboardPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    [self switchRootViewController:onboardController];
    
}

- (void)switchRootViewController:(UIViewController *)controller{
    
    // swap the view controllers
    UIViewController *source = self.viewController;
    UIViewController *destination = controller;
    UIViewController *container = self;
    
    [container addChildViewController:destination];
    
    // we'll always be replacing our whole view
    destination.view.frame = self.view.bounds;
    
    NSTimeInterval duration = 0.0;
    
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
    self.viewController = controller;
    
}


- (UIViewController *)rootViewControllerWithIdentifier:(NSString *)identifier underNavigationController:(BOOL)underNavigationController
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
    
    return viewController;
}


- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

@end
