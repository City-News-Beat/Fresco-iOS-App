//
//  FRSBaseViewController.m
//  Fresco
//
//  Created by Daniel Sun on 1/6/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSBaseViewController.h"
#import "FRSNavigationController.h"
#import "FRSGalleryExpandedViewController.h"
#import "FRSProfileViewController.h"
#import "FRSStoryDetailViewController.h"
#import "FRSAssignmentsViewController.h"
#import "FRSCameraViewController.h"
#import "FRSDebitCardViewController.h"
#import "FRSIdentityViewController.h"
#import "FRSTabBarController.h"
#import "FRSAuthManager.h"
#import "FRSUserManager.h"
#import "FRSIndicatorDot.h"
#import "FRSPermissionAlertView.h"
#import "FRSConnectivityAlertView.h"

@interface FRSBaseViewController ()

@property BOOL isSegueingToGallery;
@property BOOL isSegueingToStory;

@end

@implementation FRSBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

- (void)removeNavigationBarLine {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)configureBackButtonAnimated:(BOOL)animated {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow-light"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController)];
    backItem.imageInsets = UIEdgeInsetsMake(2, -4.5, 0, 0);
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    [self.navigationItem setLeftBarButtonItem:backItem animated:animated];
}

- (void)popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)hideTabBarAnimated:(BOOL)animated {
    if (!self.tabBarController.tabBar)
        return;

    NSInteger yOrigin = [UIScreen mainScreen].bounds.size.height;

    if (self.tabBarController.tabBar.frame.origin.y == yOrigin)
        return;

    self.hiddenTabBar = YES;

    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                       self.tabBarController.tabBar.frame = CGRectMake(0, yOrigin, self.tabBarController.tabBar.frame.size.width, self.tabBarController.tabBar.frame.size.height);
                     }
                     completion:nil];
}

- (void)showTabBarAnimated:(BOOL)animated {
    if (!self.tabBarController.tabBar)
        return;

    NSInteger yOrigin = [UIScreen mainScreen].bounds.size.height - self.tabBarController.tabBar.frame.size.height;

    if (self.tabBarController.tabBar.frame.origin.y == yOrigin)
        return;

    self.hiddenTabBar = NO;

    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                       self.tabBarController.tabBar.frame = CGRectMake(0, yOrigin, self.tabBarController.tabBar.frame.size.width, self.tabBarController.tabBar.frame.size.height);
                     }
                     completion:nil];
}

#pragma mark - Status Bar

- (void)shouldShowStatusBar:(BOOL)statusBar animated:(BOOL)animated {

    UIWindow *statusBarApplicationWindow = (UIWindow *)[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"];

    int alpha;
    if (statusBar) {
        alpha = 1;
    } else {
        alpha = 0;
    }

    if (animated) {
        [UIView beginAnimations:@"fade-statusbar" context:nil];
        [UIView setAnimationDuration:0.3];
        statusBarApplicationWindow.alpha = alpha;
        [UIView commitAnimations];
    } else {
        statusBarApplicationWindow.alpha = alpha;
    }
}

#pragma mark - FRSAlertView

- (void)presentGenericError {
    FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"OOPS" message:@"Something’s wrong on our end. Sorry about that!" actionTitle:@"CANCEL" cancelTitle:@"TRY AGAIN" cancelTitleColor:[UIColor frescoBlueColor] delegate:nil];
    [alert show];
}

- (void)presentNoConnectionError {
    FRSConnectivityAlertView *alert = [[FRSConnectivityAlertView alloc] initNoConnectionAlert];
    [alert show];
}

- (void)checkStatusAndPresentPermissionsAlert {
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]) {
        UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) || grantedSettings.types == UIUserNotificationTypeNone) {

            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:userHasSeenPermissionsAlert]; //Used for super edge case, see viewDidLoad in HomeVC for more details.
            FRSPermissionAlertView *alert = [[FRSPermissionAlertView alloc] initPermissionsAlert];
            [alert show];
            FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
            delegate.didPresentPermissionsRequest = YES;
        }
    }
}

#pragma mark - Keyboard

- (void)configureDismissKeyboardGestureRecognizer {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardFromView)];
    [self.view addGestureRecognizer:tap];
}

- (void)dismissKeyboardFromView {
    [self.view endEditing:YES];
}

#pragma mark - Logout

- (void)logoutWithPop:(BOOL)pop {
    FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[delegate managedObjectContext] save:nil];

    if ([[FRSUserManager sharedInstance] authenticatedUser]) {
        //fixes a crash when logging out from migration alert and signed in with email and password
        [[[FRSUserManager sharedInstance] managedObjectContext] deleteObject:[[FRSUserManager sharedInstance] authenticatedUser]];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      [(FRSAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
    });
    
    [[FRSAuthManager sharedInstance] logout];
    [delegate stopNotificationTimer];
    
    [self.tabBarController setSelectedViewController:[self.tabBarController.viewControllers firstObject]];
    [(FRSTabBarController *)self.tabBarController showBell:NO];
    [(FRSTabBarController *)self.tabBarController setIrisItemColor:[UIColor frescoOrangeColor]];
    
    [self popViewController];
}

@end
