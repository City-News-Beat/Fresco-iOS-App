//
//  SwitchingRootViewController.m
//  FrescoNews
//
//  Created by Fresco News on 6/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import AVFoundation;

#import "FRSRootViewController.h"
#import "VariableStore.h"
#import "FRSDataManager.h"
#import "FRSTabBarController.h"
#import "NotificationsViewController.h"
#import "CameraViewController.h"
#import "FRSOnboardPageViewController.h"
#import "BaseNavigationController.h"
#import <BTBadgeView.h>

@interface FRSRootViewController () <UITabBarControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NotificationsViewController *notificationsView;

@property (weak, nonatomic) IBOutlet UIView *viewContainer;

@end

@implementation FRSRootViewController

#pragma mark - Orientation Delegate

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - View Controller swapping

- (void)hideTabBar{
    
    [UIView animateWithDuration:0.3f animations:^{
        self.tbc.tabBar.frame = CGRectOffset(self.tbc.tabBar.frame, 0, 80);
    }];
    
}

- (void)showTabBar{
    
    [UIView animateWithDuration:0.3f animations:^{
        
        float y = [UIScreen mainScreen].bounds.size.height - self.tbc.tabBar.frame.size.height ;
        
        self.tbc.tabBar.frame = CGRectMake(self.tbc.tabBar.frame.origin.x, y, self.tbc.tabBar.frame.size.width, self.tbc.tabBar.frame.size.height);
        
    }];}


- (void)setRootViewControllerToTabBar
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [[UITabBar appearance] setTintColor:[UIColor brandDarkColor]]; // setTintColor:
    
    if(!self.tbc){
        self.tbc = (FRSTabBarController *)[self rootViewControllerWithIdentifier:@"tabBarController" underNavigationController:NO];
    }
    
    [self switchRootViewController:self.tbc];
    
    NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:UD_PREVIOUSLY_SELECTED_TAB];
   
    self.tbc.selectedIndex = (index == 4 ? 0 : index);
    
}

- (void)setRootViewControllerToCamera{
    
    [self.tbc presentCamera];
}

- (void)setRootViewControllerToHighlights{
    
    [self.tbc setSelectedIndex:0];
}

/*
** Actually present the first run modally
*/

- (void)presentFirstRunViewController:(UIViewController *)controller
{
    [controller presentViewController:[self rootViewControllerWithIdentifier:@"firstRunViewController" underNavigationController:YES] animated:YES completion:nil];
}

/*
** Sets the root view controller completely to the first run
*/

- (void)setRootViewControllerToFirstRun{

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
        viewController = [[BaseNavigationController alloc] initWithRootViewController:vc];
        vc.navigationController.navigationBar.hidden = YES;
    }
    else
        viewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
    
    return viewController;
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

@end