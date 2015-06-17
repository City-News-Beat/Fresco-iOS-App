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
#import "SwitchingRootViewController.h"

static NSString *assignmentIdentifier = @"ASSIGNMENT_CATEGORY"; // Notification Categories
static NSString *navigateIdentifier = @"NAVIGATE_IDENTIFIER"; // Notification Actions

@interface AppDelegate () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager; // TODO: -> Singleton
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
    
    // try to bootstrap the user
    [[FRSDataManager sharedManager] login];
    
    return YES;
}

#pragma mark - Root View Controllers
// because the app might launch into First Run mode
// or regular (tab interface) we need to dynamically swap
// root view controllers
- (void)loadInitialViewController
{
    SwitchingRootViewController *rootViewController = (SwitchingRootViewController *)self.window.rootViewController;
    if ([[FRSDataManager sharedManager] login])
        [rootViewController setRootViewControllerToTabBar];
    else {
        [rootViewController setRootViewControllerToFirstRun];
    }
}

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

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)configureParseWithLaunchOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"ttJBFHzdOoPrnwp8IjrZ8cD9d1kog01jiSDAK8Fc"
                  clientKey:@"KyUgpyFKxNWg2WmdUOhasAtttr33jPLpgRc63uc4"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    [PFTwitterUtils initializeWithConsumerKey:@"o6y4zv5yq0AfCU4HKUHQYJMXE"
                               consumerSecret:@"PqPWPJRAp37ZE3vLn6Uxu29BGXAaMvi0ooaiqsPQxAn0PSG0Vz"];
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
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    
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
    CLLocation *location = [locations lastObject];

    if (![FRSDataManager sharedManager].currentUser.userID) {
        [self.locationManager stopMonitoringSignificantLocationChanges];
        return;
    }

    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"id" : [FRSDataManager sharedManager].currentUser.userID,
                                 @"lat" : @(location.coordinate.latitude),
                                 @"lon" : @(location.coordinate.longitude)};
    [operationManager POST:[VariableStore endpointForPath:@"user/locate"]
                parameters:parameters
                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

#pragma mark - Notification Delegate Methods

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler{
    
    [PFPush handlePush:userInfo];
    
    /*
    ** Check the type of the notifications
    */
    
    //Breaking News
    if([userInfo[@"type"] isEqualToString:@"breaking"] || [userInfo[@"type"] isEqualToString:@"use"]){
        
        //Check to make sure the payload has a galelry ID
        if(userInfo[@"gallery"] != nil){
            
            [[FRSDataManager sharedManager] getGallery:userInfo[@"gallery"] WithResponseBlock:^(id responseObject, NSError *error) {
                if (!error) {
                    
                    //Retreieve Gallery View Controller from storyboard
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                    
                    GalleryViewController *galleryView = [storyboard instantiateViewControllerWithIdentifier:@"GalleryViewController"];
                    
                    [galleryView setGallery:responseObject];
                    
                    [self.window.rootViewController.navigationController pushViewController:galleryView animated:YES];

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
                    
                    [assignmentVC setCurrentAssignment:responseObject navigateTo:YES];
                    
                    
                }
            }];
        }
    }
    
    //Use
    
    //Social
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)notification completionHandler: (void (^)()) completionHandler
{
    
    /*
    ** Check the identifier for the type of notification
    */
    
    //Assignment Action
    if ([identifier isEqualToString: navigateIdentifier]) {
        
        // Check to make sure the payload has an assignment ID
        if (notification[@"assignment"]) {
            
            [[FRSDataManager sharedManager] getAssignment:notification[@"assignment"] withResponseBlock:^(id responseObject, NSError *error) {
                if (!error) {
                    
                    UITabBarController *tabBarController = ((UITabBarController *)((SwitchingRootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController).viewController);

                    AssignmentsViewController *assignmentVC = (AssignmentsViewController *) ([[tabBarController viewControllers][3] viewControllers][0]);

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
