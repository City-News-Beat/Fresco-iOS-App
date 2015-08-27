//
//  AppDelegate.m
//  FrescoNews
//
//  Created by Fresco News on 3/2/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import CoreLocation;
@import FBSDKLoginKit;
@import FBSDKCoreKit;
@import Parse;
@import AVFoundation;
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <AFNetworkActivityLogger.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "AppDelegate.h"
#import "FRSUser.h"
#import "FRSDataManager.h"
#import "FRSLocationManager.h"
#import "GalleryViewController.h"
#import "AssignmentsViewController.h"
#import "HighlightsViewController.h"
#import "FRSRootViewController.h"
#import "UIColor+Additions.h"
#import "FRSDisabledViewController.h"

//static NSString *assignmentIdentifier = @"ASSIGNMENT_CATEGORY"; // Notification Categories
//static NSString *navigateIdentifier = @"NAVIGATE_IDENTIFIER"; // Notification Actions

@interface AppDelegate () <CLLocationManagerDelegate>

@property (strong, nonatomic) FRSRootViewController *frsRootViewController;

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Prevent conflict between background music and camera
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                     withOptions:AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionDefaultToSpeaker
                                           error:nil];
    [[AVAudioSession sharedInstance] setActive:YES
                                         error:nil];
    
    [self configureAppWithLaunchOptions:launchOptions];
    
    [self setupAppearances];
    
    self.frsRootViewController = [[FRSRootViewController alloc] init];
    
    self.window.rootViewController = self.frsRootViewController;
    
    //Check if we are launching through a push notification
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [self handlePush:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    
    //Reset the previously selected tab on launch
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:UD_PREVIOUSLY_SELECTED_TAB];
    
    //Check if the user has agreed to the TOS, otherwise log them out
    if(![[NSUserDefaults standardUserDefaults] boolForKey:UD_TOS_AGREED])
        [[FRSDataManager sharedManager] logout];
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:UD_HAS_LAUNCHED_BEFORE] || IS_IPHONE_4S){
        [self registerForPushNotifications];
        [self.frsRootViewController setRootViewControllerToTabBar];
    }
    else {
        [self.frsRootViewController setRootViewControllerToOnboard];
        self.frsRootViewController.onboardVisited = YES;
    }
    
    return YES;
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

-(void)applicationDidEnterBackground:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Apperance Delegate Methods

- (void)setupAppearances
{
    [[UITextField appearance] setTextColor:[UIColor textInputBlackColor]];
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
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:HELVETICA_NEUE_MEDIUM size:17.0], NSForegroundColorAttributeName : [UIColor whiteColor]};
    [[UIBarButtonItem appearanceWhenContainedIn:[UIToolbar class], nil] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [UIToolbar appearance].barTintColor = [UIColor greenToolbarColor];
}

- (void)setupBarButtonItemAppearance
{
    [UIBarButtonItem appearance].tintColor = [UIColor darkGoldBarButtonColor];
}

#pragma mark - Delegate Setup

- (void)configureAppWithLaunchOptions:(NSDictionary *)launchOptions
{
    
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    [Fabric with:@[CrashlyticsKit]];

//    //Taplytics Setup
//    [Taplytics startTaplyticsAPIKey:@"a7e5161cf95cac5427bb5dae0552f8256af5bf1f"];
//
    [Parse setApplicationId:PARSE_APP_ID clientKey:PARSE_CLIENT_KEY];
    
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    [PFTwitterUtils initializeWithConsumerKey:TWITTER_CONSUMER_KEY
                               consumerSecret:TWITTER_CONSUMER_SECRET];
}

- (void)registerForPushNotifications
{
    //Navigate Action
    UIMutableUserNotificationAction *navigateAction = [[UIMutableUserNotificationAction alloc] init]; // Set up action for navigate
    navigateAction.identifier = NAVIGATE_IDENTIFIER; // Define an ID string to be passed back to your app when you handle the action
   
    navigateAction.title = NAVIGATE_STR;
    navigateAction.activationMode = UIUserNotificationActivationModeBackground; // If you need to show UI, choose foreground
    navigateAction.destructive = NO; // Destructive actions display in red
    navigateAction.authenticationRequired = NO;

    //Assignments Actions Category
    UIMutableUserNotificationCategory *assignmentCategory = [[UIMutableUserNotificationCategory alloc] init];
    assignmentCategory.identifier = ASSIGNMENT_CATEGORY; // Identifier to include in your push payload and local notification
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
    
    // Check the type of the notifications
    
    //Breaking News
    if ([userInfo[@"type"] isEqualToString:@"breaking"] || [userInfo[@"type"] isEqualToString:@"use"]) {
        //Check to make sure the payload has a gallery ID
        if (userInfo[@"gallery"]) {
            
            [[FRSDataManager sharedManager] getGallery:userInfo[@"gallery"] WithResponseBlock:^(id responseObject, NSError *error) {
                if (!error) {
                    
                    //Retreieve Gallery View Controller from storyboard
                    UITabBarController *tabBarController = ((UITabBarController *)((FRSRootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController).viewController);
                    
                    HighlightsViewController *homeVC = (HighlightsViewController *) ([[tabBarController viewControllers][0] viewControllers][0]);
                    
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
                    UITabBarController *tabBarController = ((UITabBarController *)((FRSRootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController).viewController);
                    AssignmentsViewController *assignmentVC = (AssignmentsViewController *) ([[tabBarController viewControllers][3] viewControllers][0]);
                    [tabBarController setSelectedIndex:3];
                    [assignmentVC setCurrentAssignment:responseObject navigateTo:NO present:NO];
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
    if ([identifier isEqualToString: NAVIGATE_IDENTIFIER]) {
        // Check to make sure the payload has an assignment ID
        if (notification[@"assignment"]) {
            [[FRSDataManager sharedManager] getAssignment:notification[@"assignment"] withResponseBlock:^(id responseObject, NSError *error) {
                if (!error) {
                    UITabBarController *tabBarController = ((UITabBarController *)((FRSRootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController).viewController);
                    AssignmentsViewController *assignmentVC = (AssignmentsViewController *)([[tabBarController viewControllers][3] viewControllers][0]);
                    [assignmentVC setCurrentAssignment:responseObject navigateTo:YES present:NO];
                    [tabBarController setSelectedIndex:3];
                }
            }];
        }
    }

    // Must be called when finished
    completionHandler(UIBackgroundFetchResultNewData);
}

@end
