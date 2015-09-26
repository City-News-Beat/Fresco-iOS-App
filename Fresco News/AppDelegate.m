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
@import Fabric;
@import Crashlytics;

#import "AppDelegate.h"
#import <AFNetworkActivityLogger.h>
#import <Stripe.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "FRSUser.h"
#import "FRSDataManager.h"
#import "FRSLocationManager.h"
#import "FRSOnboardViewConroller.h"
#import "FRSRootViewController.h"
#import "AppDelegate+Additions.h"
#import "UIColor+Additions.h"

#import "ProfilePaymentSettingsViewController.h"

@interface AppDelegate ()

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
    
    //Check if we've launcahed the app before or if the app is the iPhone 4s/4
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

    //Method will refresh current user and beging background location updates
    [[FRSDataManager sharedManager] refreshUser:nil];
    
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
    
//    [[AFNetworkActivityLogger sharedLogger] startLogging];
    [Fabric with:@[CrashlyticsKit]];

    [Parse setApplicationId:PARSE_APP_ID clientKey:PARSE_CLIENT_KEY];
    
    [Stripe setDefaultPublishableKey:STRIPE_PUBLISHABLE_KEY];
    
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


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
    
    if(application.applicationState == UIApplicationStateInactive) {
        
        //Handle the push notification
        [self handlePush:userInfo];
    
        handler(UIBackgroundFetchResultNewData);
        
    }

}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
    UIApplicationState state = [application applicationState];
    
    //Check if the app is inactive to prevent taking the user away from their view
    if (state == UIApplicationStateInactive) {
        
        [self handlePush:notification.userInfo];
        
    }

}

/*
** Catch all method for handling notification userInfo
*/

- (void)handlePush:(NSDictionary *)userInfo
{
    
    [PFPush handlePush:userInfo];
    
    //Check that the user is not in the onboard screen, otherwise break the method call
    if([self.frsRootViewController.viewController isKindOfClass:[FRSOnboardViewConroller class]]){
        return;
    }
    
    // Check the type of the notifications
    
    //Breaking News /* Check to make sure the payload has a gallery ID */
    if (([userInfo[@"type"] isEqualToString:NOTIF_BREAKING] || [userInfo[@"type"] isEqualToString:NOTIF_USE]) && userInfo[@"gallery"]){
        
        [self openGalleryFromPush:userInfo[@"gallery"]];
        
    }
    
    // Assignments * Check to make sure the payload has an assignment ID
    if ([userInfo[@"type"] isEqualToString:NOTIF_ASSIGNMENT] && userInfo[@"assignment"]) {
        
        [self openAssignmentFromPush:userInfo[@"assignment"] withNavigation:NO];
        
    }
    //Story
    if ([userInfo[@"type"] isEqualToString:NOTIF_LIST] && userInfo[@"galleries"]) {
        
        NSArray *galleryList = userInfo[@"galleries"];
        
        [self openGalleryListFromPush:galleryList withTitle:userInfo[@"title"]];
        
    }
    
    
}


- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)notification completionHandler:(void (^)())completionHandler
{
    // Check the identifier for the type of notification
    
    //Assignment Action /* Check to make sure the payload has an assignment ID */
    if ([identifier isEqualToString: NAVIGATE_IDENTIFIER] && notification[@"assignment"]) {
        
        [self openAssignmentFromPush:notification[@"assignment"] withNavigation:YES];

    }

    // Must be called when finished
    completionHandler(UIBackgroundFetchResultNewData);
}

@end
