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
#import "AppDelegate.h"
#import "AFNetworkActivityLogger.h"
#import "FRSUser.h"
#import "FRSDataManager.h"
#import <AFNetworking.h>
#import "FRSDataManager.h"
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

    // try to bootstrap the user
    [[FRSDataManager sharedManager] loginWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error on login %@", error);
        }
        else {
            NSLog(@"successful login on launch");
            if (launchOptions[UIApplicationLaunchOptionsLocationKey]) {
                /* How to debug background location updates, in the simulator
                 1. Pause at beginning of didFinishLaunchingWithOptions (if necessary for steps 2 and/or 3 below)
                 2. Xcode/scheme location simulation should be disabled, i.e. Select "Don't Simulate Location" from the pulldown
                 2b. Better: Edit Scheme > Run > Options > Core Location > Default Location > Set to "None"
                 3. Simulate location via iOS Simulator > Debug > Location > Freeway Drive
                 4. Unpause
                 5. Terminate the app
                 6. Monitor background launches via iOS Simulator > Debug > Open System Log...
                 6b. Also you may be able to debug background launches using scheme launch option "Wait for executable to be launched"
                 */
                // NSLog(@"Background launch via UIApplicationLaunchOptionsLocationKey");
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                [self.locationManager startMonitoringSignificantLocationChanges];
            }
        }
    }];

    [self setupAppearances];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasLaunchedBefore"]) {
        [self setupLocationManager];
        [self registerForPushNotifications];
        [self setRootViewControllerToTabBar];
    }
    else {
        [self setRootViewControllerToOnboard];
    }

    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [self application:application didReceiveRemoteNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] fetchCompletionHandler:nil];
    }
    else if (!launchOptions[UIApplicationLaunchOptionsLocationKey]) {
        // Ordinary app launch
        [self setupLocationMonitoring];
    }

    return YES;
}

#pragma mark - Root View Controllers
// because the app might launch into First Run mode
// or regular (tab interface) we need to dynamically swap
// root view controllers
/*
- (void)loadInitialViewController
{
    SwitchingRootViewController *rootViewController = (SwitchingRootViewController *)self.window.rootViewController;
    [[FRSDataManager sharedManager] loginWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded) {
            [rootViewController setRootViewControllerToTabBar];
        }
        else
            [rootViewController setRootViewControllerToFirstRun];
    }];
}*/

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

- (void)setupLocationManager
{
    if (![CLLocationManager locationServicesEnabled]) {
        // User has disabled location services on this device
        return;
    }

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    });
}

- (void)setupLocationMonitoring
{
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;

    // TODO: Stop monitoring significant location changes on logout
    [self.locationManager startUpdatingLocation];
    [self.locationManager startMonitoringSignificantLocationChanges];
}

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

#pragma mark - Location Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (![[FRSDataManager sharedManager] isLoggedIn]) {
        // NSLog(@"User not logged in, calling -stopMonitoringSignificantLocationChanges");
        [self.locationManager stopMonitoringSignificantLocationChanges];
    }

    if (!self.location || [self.location distanceFromLocation:[locations lastObject]] > 0) {
        // NSLog(@"Found a new location");
        self.location = [locations lastObject];

        NSDictionary *params = @{@"lat" : @(self.location.coordinate.latitude),
                                 @"lon" : @(self.location.coordinate.longitude)};

        [[FRSDataManager sharedManager] updateUserLocation:params block:nil];
    }
    else {
        // NSLog(@"not a new location");
    }

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // NSLog(@"Starting timer...");
        [NSTimer scheduledTimerWithTimeInterval:[VariableStore sharedInstance].locationUpdateInterval target:self selector:@selector(restartLocationUpdates) userInfo:nil repeats:YES];
    });
    [self.locationManager stopUpdatingLocation];

    // Set to YES to test monitoring of significant location changes even when the app is not running
    if (/* DISABLES CODE */ (NO)) {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = [self.location description];
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
        notification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] setScheduledLocalNotifications:@[notification]];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // NSLog(@"-locationManager:didFailWithError:");
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self.locationManager stopUpdatingLocation];
}

- (void)restartLocationUpdates
{
    [self.locationManager startUpdatingLocation];
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
        
        [self handlePush:userInfo];
    
        //Show the view with the content of the push

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
