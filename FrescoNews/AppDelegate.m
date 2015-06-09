//
//  AppDelegate.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/2/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "AppDelegate.h"
#import "AFNetworkActivityLogger.h"
#import "CameraViewController.h"
#import "FRSUser.h"
#import "FRSDataManager.h"
#import <AFNetworking.h>
#import "FRSDataManager.h"
#import "AssignmentsViewController.h"
#import "SwitchingRootViewController.h"

static NSString *assignmentIdentifier = @"ASSIGNMENT_CATEGORY"; // Notification Categories
static NSString *navigateIdentifier = @"NAVIGATE_IDENTIFIER"; // Notification Actions

@interface AppDelegate () <UITabBarControllerDelegate, CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager; // TODO: -> Singleton
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self setupLocationManager];

    
    // Register for Push Notitications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    
    
    //Set up action for navigate
    UIMutableUserNotificationAction *navigateAction = [[UIMutableUserNotificationAction alloc] init];
    
    // Define an ID string to be passed back to your app when you handle the action
    navigateAction.identifier = navigateIdentifier;
    // Localized string displayed in the action button
    navigateAction.title = @"Navigate";
    // If you need to show UI, choose foreground
    navigateAction.activationMode = UIUserNotificationActivationModeBackground;
    // Destructive actions display in red
    navigateAction.destructive = NO;
    // Set whether the action requires the user to authenticate
    navigateAction.authenticationRequired = NO;
    
    
    // First create the category
    UIMutableUserNotificationCategory *assignmentCategory = [[UIMutableUserNotificationCategory alloc] init];
    // Identifier to include in your push payload and local notification
    assignmentCategory.identifier = assignmentIdentifier;
    // Add the actions to the category and set the action context
    [assignmentCategory setActions:@[navigateAction] forContext:UIUserNotificationActionContextDefault];
    // Set the actions to present in a minimal context
    [assignmentCategory setActions:@[navigateAction] forContext:UIUserNotificationActionContextMinimal];
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:[NSSet setWithObjects:assignmentCategory, nil]];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    
    
    //[self setupFacebookAndParse];
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    
    // Parse Initialization
    [Parse setApplicationId:@"ttJBFHzdOoPrnwp8IjrZ8cD9d1kog01jiSDAK8Fc"
                  clientKey:@"KyUgpyFKxNWg2WmdUOhasAtttr33jPLpgRc63uc4"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Facebook
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    // Twitter
    [PFTwitterUtils initializeWithConsumerKey:@"uCNLr9NBpjzamTiDCgp5t5KPP"
                               consumerSecret:@"Qb78pKABSTUKUZEZYXwNqf7oJ8jCWLoMlDuEadC8wclHD9A05J"];
    
    [self setupAppearances];
    
    // this is where we determine whether to run the firstRun sequence
    [self loadInitialViewController];
    
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [self application:application didReceiveRemoteNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    
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
//
//    [self setRootViewControllerWithIdentifier:@"tabBarController" underNavigationController:NO];
//    [self setupTabBarAppearances];
}

- (void)setRootViewControllerToFirstRun
{
    SwitchingRootViewController *rootViewController = (SwitchingRootViewController *)self.window.rootViewController;
    [rootViewController setRootViewControllerToFirstRun];
//    [self setRootViewControllerWithIdentifier:@"firstRunViewController" underNavigationController:YES];
}

- (void)setRootViewControllerWithIdentifierOLD:(NSString *)identifier underNavigationController:(BOOL)underNavigationController
{
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    
    UIViewController *viewController;

    if (underNavigationController) {
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:identifier];
        viewController = [[UINavigationController alloc] initWithRootViewController:vc];
        vc.navigationController.navigationBar.hidden = YES;
    }
    else
        viewController = [storyboard instantiateViewControllerWithIdentifier:identifier];

    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
}

- (void)setRootViewControllerWithIdentifier:(NSString *)identifier underNavigationController:(BOOL)underNavigationController
{
   // self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    
    UIViewController *viewController;
    
    if (underNavigationController) {
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:identifier];
        viewController = [[UINavigationController alloc] initWithRootViewController:vc];
        vc.navigationController.navigationBar.hidden = YES;
    }
    else
        viewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
    
    [self.window.rootViewController.view viewWithTag:1000];
    
    //[self.window makeKeyAndVisible];
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
    //[self setupTabBarAppearances];
    [self setupNavigationBarAppearance];
    [self setupToolbarAppearance];
    [self setupBarButtonItemAppearance];
}

- (void)setupTabBarAppearances
{

    [[UITabBar appearance] setTintColor:[UIColor colorWithHex:[VariableStore sharedInstance].colorBrandDark]];
    
    NSArray *highlightedTabNames = @[@"tab-home-highlighted",
                                     @"tab-stories-highlighted",
                                     @"tab-camera-highlighted",
                                     @"tab-assignments-highlighted",
                                     @"tab-profile-highlighted"];
    
    
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    
    tabBarController.delegate = self;
    
    UITabBar *tabBar = tabBarController.tabBar;
    
    int i = 0;
    
    for (UITabBarItem *item in tabBar.items) {
       if (i == 2) {
            item.image = [[UIImage imageNamed:@"tab-camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            item.selectedImage = [[UIImage imageNamed:@"tab-camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            item.imageInsets = UIEdgeInsetsMake(5.5, 0, -6, 0);
        }
        else {
            item.selectedImage = [UIImage imageNamed:highlightedTabNames[i]];
        }
        ++i;
    }
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

#pragma mark - UITabBarControllerDelegate methods

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    return ![viewController isKindOfClass:[CameraViewController class]];
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
    
    //Breaking News
    if([userInfo[@"type"] isEqualToString:@"breaking"]){
        
        //Check to make sure the payload has an id
        if(userInfo[@"gallery_id"] != nil){
            
            [[FRSDataManager sharedManager] getGallery:userInfo[@"gallery_id"] WithResponseBlock:^(id responseObject, NSError *error) {
                if (!error) {
                    
                    #warning Nothing will happen yet, need to figure out how to handle gallery views
                    
                }
                
            }];
            
        }

        
    
    }
    
    // Assignments
    if ([userInfo[@"type"] isEqualToString:@"assignment"]) {
        
        // Check to make sure the payload has an id
        if (userInfo[@"assignment_id"]) {
            
            [[FRSDataManager sharedManager] getAssignment:userInfo[@"assignment_id"] withResponseBlock:^(id responseObject, NSError *error) {
                if (!error) {
                    
                    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;

                    AssignmentsViewController *assignmentVC = (AssignmentsViewController *) ([[tabBarController viewControllers][3] viewControllers][0]);
                    
                    [assignmentVC setCurrentAssignment:responseObject navigateTo:NO];
                    
                    [tabBarController setSelectedIndex:3];
                    
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
        // Check to make sure the payload has an id
        if (notification[@"assignment_id"]) {
            [[FRSDataManager sharedManager] getAssignment:notification[@"assignment_id"] withResponseBlock:^(id responseObject, NSError *error) {
                if (!error) {
                    
                    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;

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
