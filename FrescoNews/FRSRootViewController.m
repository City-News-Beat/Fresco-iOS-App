//
//  SwitchingRootViewController.m
//  FrescoNews
//
//  Created by Jason Gresh on 6/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import AVFoundation;

#import "FRSRootViewController.h"
#import "FRSTabBarController.h"
#import "CameraViewController.h"
#import "FRSOnboardViewController.h"

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

    self.tbc = (FRSTabBarController *)[self setRootViewControllerWithIdentifier:@"tabBarController" underNavigationController:NO];
    
    if (self.returnToGalleryPost) {
        self.returnToGalleryPost = NO;
        [self.tbc returnToGalleryPost];
    }
    else {
        NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"previouslySelectedTab"];
        self.tbc.selectedIndex = (index == 4 ? 0 : index);
    }
}

- (void)setRootViewControllerToFirstRun
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [self setRootViewControllerWithIdentifier:@"firstRunViewController" underNavigationController:YES];
}

- (void)setRootViewControllerToOnboard{
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
    
    NSTimeInterval duration = 0.0;

    // Kind of gross
    if ([self.presentedViewController isKindOfClass:[CameraViewController class]]) {
        [[self.presentedViewController presentedViewController] dismissViewControllerAnimated:NO completion:^{
            [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        }];
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
