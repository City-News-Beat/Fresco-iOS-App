//
//  AppDelegate.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/2/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import CoreLocation;
@import FBSDKCoreKit;
@import FBSDKLoginKit;
@import Parse;
@import AVFoundation;
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <AFNetworking.h>
#import "AppDelegate.h"
#import "AFNetworkActivityLogger.h"
#import "FRSUser.h"
#import "FRSDataManager.h"
#import "FRSLocationManager.h"
#import "GalleryViewController.h"
#import "AssignmentsViewController.h"
#import "HomeViewController.h"
#import "SwitchingRootViewController.h"

static NSString *assignmentIdentifier = @"ASSIGNMENT_CATEGORY"; // Notification Categories
static NSString *navigateIdentifier = @"NAVIGATE_IDENTIFIER"; // Notification Actions

@interface AppDelegate () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager; // TODO: -> Singleton
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[AFNetworkActivityLogger sharedLogger] startLogging];

    // Prevent conflict between background music and camera
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                     withOptions:AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionDefaultToSpeaker
                                           error:nil];
    [[AVAudioSession sharedInstance] setActive:YES
                                         error:nil];

    [self configureParseWithLaunchOptions:launchOptions];

    //Refresh the existing user, if exists, then run location monitoring
    [[FRSDataManager sharedManager] refreshUser:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            
            NSLog(@"successful login on launch");
            
            [[FRSLocationManager sharedManager] setupLocationMonitoring];
            
        }
        else {
           if(error) NSLog(@"Error on login %@", error);
        }
    }];
    
    [self setupAppearances];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasLaunchedBefore"]) {
        [self registerForPushNotifications];
        [self setRootViewControllerToTabBar];
    }
    else {
        [self setRootViewControllerToOnboard];
    }

    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [self handlePush:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
        

    return YES;
}

#pragma mark - Root View Controllers


- (void)setRootViewControllerToTabBar
{
    SwitchingRootViewController *rootViewController = (SwitchingRootViewController *)self.window.rootViewController;
    [rootViewController setRootViewControllerToTabBar];
}

- (void)setRootViewControllerToOnboard
{
    SwitchingRootViewController *rootViewController = (SwitchingRootViewController *)self.window.rootViewController;
    [rootViewController setRootViewControllerToOnboard];
}

- (void)setRootViewControllerToFirstRun
{
    SwitchingRootViewController *rootViewController = (SwitchingRootViewController *)self.window.rootViewController;
    [rootViewController setRootViewControllerToFirstRun];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
}

#pragma mark - Apperance Delegate Methods

- (void)setupAppearances
{
    [self setupNavigationBarAppearance];
    [self setupToolbarAppearance];
    [self setupBarButtonItemAppearance];
}

- (void)setupNavigationBarAppearance
{
    NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    [UINavigationBar appearance].titleTextAttributes = attributes;
}

- (void)setupToolbarAppearance
{
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0], NSForegroundColorAttributeName : [UIColor whiteColor]};
    [[UIBarButtonItem appearanceWhenContainedIn:[UIToolbar class], nil] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [UIToolbar appearance].barTintColor = [UIColor colorWithHex:@"39D673"];
}

- (void)setupBarButtonItemAppearance
{
    [UIBarButtonItem appearance].tintColor = [UIColor colorWithHex:@"76541E"];
}

#pragma mark - Miscellaneous Configuration

- (void)configureParseWithLaunchOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:[VariableStore sharedInstance].parseAppId clientKey:[VariableStore sharedInstance].parseClientKey];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    [PFTwitterUtils initializeWithConsumerKey:[VariableStore sharedInstance].twitterConsumerKey
                               consumerSecret:[VariableStore sharedInstance].twitterConsumerSecret];
}

- (void)registerForPushNotifications
{
    //Navigate Action
    UIMutableUserNotificationAction *navigateAction = [[UIMutableUserNotificationAction alloc] init]; // Set up action for navigate
    navigateAction.identifier = navigateIdentifier; // Define an ID string to be passed back to your app when you handle the action
    navigateAction.title = @"Navigate";
    navigateAction.activationMode = UIUserNotificationActivationModeBackground; // If you need to show UI, choose foreground
    navigateAction.destructive = NO; // Destructive actions display in red
    navigateAction.authenticationRequired = NO;

    //Assignments Actions Category
    UIMutableUserNotificationCategory *assignmentCategory = [[UIMutableUserNotificationCategory alloc] init];
    assignmentCategory.identifier = assignmentIdentifier; // Identifier to include in your push payload and local notification
    [assignmentCategory setActions:@[navigateAction] forContext:UIUserNotificationActionContextDefault];
    
    //Notification Types
    UIUserNotificationType userNotificationTypes = UIUserNotificationTypeBadge |
    UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    //Notification Settings
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:[NSSet setWithObjects:assignmentCategory, nil]];

    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
}


#pragma mark - Notification Delegate Methods

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    PFUser *user = [PFUser currentUser];
    
    if (user) {
        [currentInstallation setObject:user forKey:@"owner"];
    }
    
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)handlePush:(NSDictionary *)userInfo
{

    [PFPush handlePush:userInfo];
    
    [self setRootViewControllerToTabBar];
    
    // Check the type of the notifications
    
    //Breaking News
    if ([userInfo[@"type"] isEqualToString:@"breaking"] || [userInfo[@"type"] isEqualToString:@"use"]) {
        //Check to make sure the payload has a gallery ID
        if (userInfo[@"gallery"]) {
            
            [[FRSDataManager sharedManager] getGallery:userInfo[@"gallery"] WithResponseBlock:^(id responseObject, NSError *error) {
                if (!error) {
                    
                    //Retreieve Gallery View Controller from storyboard
                    UITabBarController *tabBarController = ((UITabBarController *)((SwitchingRootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController).viewController);
                    
                    HomeViewController *homeVC = (HomeViewController *) ([[tabBarController viewControllers][0] viewControllers][0]);
                    
                    //Retreieve Notifications View Controller from storyboard
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                    
                    GalleryViewController *galleryView = [storyboard instantiateViewControllerWithIdentifier:@"GalleryViewController"];
                    
                    [galleryView setGallery:responseObject];
                    
                    [homeVC.navigationController pushViewController:galleryView animated:YES];
                }
            }];
            
        }
    }

    // Assignments
    if ([userInfo[@"type"] isEqualToString:@"assignment"]) {
        // Check to make sure the payload has an assignment ID
        if (userInfo[@"assignment"]) {
            [[FRSDataManager sharedManager] getAssignment:userInfo[@"assignment"] withResponseBlock:^(id responseObject, NSError *error) {
                if (!error) {
                    UITabBarController *tabBarController = ((UITabBarController *)((SwitchingRootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController).viewController);
                    AssignmentsViewController *assignmentVC = (AssignmentsViewController *) ([[tabBarController viewControllers][3] viewControllers][0]);
                    [tabBarController setSelectedIndex:3];
                    [assignmentVC setCurrentAssignment:responseObject navigateTo:NO];
                }
            }];
        }
    }
    //Use
    //Social
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
    
    if(application.applicationState == UIApplicationStateInactive) {
        
        //Handle the push notification
        [self handlePush:userInfo];
    
        handler(UIBackgroundFetchResultNewData);
        
    }

}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)notification completionHandler:(void (^)())completionHandler
{
    // Check the identifier for the type of notification
    
    //Assignment Action
    if ([identifier isEqualToString: navigateIdentifier]) {
        // Check to make sure the payload has an assignment ID
        if (notification[@"assignment"]) {
            [[FRSDataManager sharedManager] getAssignment:notification[@"assignment"] withResponseBlock:^(id responseObject, NSError *error) {
                if (!error) {
                    UITabBarController *tabBarController = ((UITabBarController *)((SwitchingRootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController).viewController);
                    AssignmentsViewController *assignmentVC = (AssignmentsViewController *)([[tabBarController viewControllers][3] viewControllers][0]);
                    [assignmentVC setCurrentAssignment:responseObject navigateTo:YES];
                    [tabBarController setSelectedIndex:3];
                }
            }];
        }
    }

    // Must be called when finished
    completionHandler(UIBackgroundFetchResultNewData);
}

@end
