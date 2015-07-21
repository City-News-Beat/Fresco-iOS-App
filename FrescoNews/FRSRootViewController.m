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
#import <BTBadgeView.h>

@interface FRSRootViewController () <UITabBarControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NotificationsViewController *notificationsView;

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

#pragma mark - Notification Bar Button Item

- (void)setRightBarButtonItem:(BOOL)withBadge{
    
    UIImage *bell = [UIImage imageNamed:@"notifications"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.alpha = .54;
    
    button.bounds = CGRectMake( 0, 0, bell.size.width, bell.size.height );
    
    button.clipsToBounds = NO;
    
    [button setImage:bell forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(toggleNotifications:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *notificationIcon = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    [self.navigationItem setRightBarButtonItem:notificationIcon];
    
    if(withBadge && [FRSDataManager sharedManager].updatedNotifications == false){
        
        [[self presentedViewController].navigationItem.rightBarButtonItem.customView addSubview:[self getBadgeView]];
        
        //        [self.navigationItem.rightBarButtonItem.customView addSubview:[self getBadgeView]];
        
    }
    
}

- (BTBadgeView *)getBadgeView
{
    
    BTBadgeView *badgeView = [[BTBadgeView alloc] initWithFrame:CGRectMake(4,-8, 30, 20)];
    
    badgeView.layer.cornerRadius = 10;
    
    badgeView.shadow = NO;
    
    badgeView.clipsToBounds = NO;
    
    badgeView.strokeColor = [UIColor whiteColor];
    
    badgeView.fillColor = [UIColor whiteColor];
    
    badgeView.textColor = [UIColor blackColor];
    
    badgeView.strokeWidth = 0;
    
    badgeView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
    
    [[FRSDataManager sharedManager] getNotificationsForUser:^(id responseObject, NSError *error) {
        if (!error) {
            
            if(responseObject != nil){
                
                NSInteger count = 0;
                
                for(FRSNotification *notif in responseObject){
                    
                    if(!notif.seen) count ++;
                }
                
                if(count > 0)
                    badgeView.value =[NSString stringWithFormat:@"%li",  (long)count];
                
            }
        }
        
    }];
    
    return  badgeView;
    
}


#pragma mark - Notifications View Controller

-(void)toggleNotifications:(UIBarButtonItem *)sender
{
    
    if([[FRSDataManager sharedManager] isLoggedIn]){
        
        //If the current view controller is already the Notificatins View Controller
        if([self.navigationController.topViewController isKindOfClass:[NotificationsViewController class]])
            [self hideNotifications];
        else
            [self showNotifications];
        
    }
    
}

-(void)showNotifications{
    
    //Remove the badge from the notifications bell
    [self setRightBarButtonItem:NO];
    
    //Retreieve Notifications View Controller from storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    NotificationsViewController *notificationsController = [storyboard instantiateViewControllerWithIdentifier:@"Notifications"];
    
    
    /*
     ** Perform annoying and complicated transition/animation
     */
    
    //Set the high up to prepare for slide down
    [notificationsController.view setFrame:CGRectMake(0, -(notificationsController.view.frame.size.height) + 100, notificationsController.view.frame.size.width,notificationsController.view.frame.size.height)];
    
    //Instantiate a CATransition
    CATransition* transition = [CATransition animation];
    transition.duration = 0.75;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromBottom;
    
    //Set the frame back to normal so it slides back into place
    [notificationsController.view setFrame:CGRectMake(0, 0, notificationsController.view.frame.size.width,notificationsController.view.frame.size.height)];
    
    //Add animation layer
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    
    //Perform push, with animation *animation is set to NO because the CATransitition will be operating*
    [self.navigationController pushViewController:notificationsController animated:NO];
    
    //Hide the back button as it's not relevant in this flow context
    self.navigationItem.leftBarButtonItem = nil;
    [self.navigationItem setHidesBackButton:YES];
    
    
}

-(void)hideNotifications{
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.4f;
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromTop;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.navigationController.view.layer addAnimation:transition
                                                forKey:kCATransition];
    [self.navigationController popViewControllerAnimated:NO];
    
}

#pragma mark - NSNotificationCenter Notification handling

- (void)handleAPIKeyAvailable:(NSNotification *)notification
{
    [self setRightBarButtonItem:YES];
}


@end
