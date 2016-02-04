//
//  AppDelegate.m
//  FrescoNews
//
//  Created by Fresco News on 3/2/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import CoreLocation;
@import FBSDKCoreKit;
@import FBSDKLoginKit;
@import Parse;
@import AVFoundation;
@import Fabric;
@import Crashlytics;

#import "AppDelegate.h"
#import "AFNetworkActivityLogger.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "FRSUser.h"
#import "FRSDataManager.h"
#import "FRSLocationManager.h"
#import "FRSUploadManager.h"

#import "FRSOnboardViewConroller.h"
#import "FRSRootViewController.h"
#import "AppDelegate+Additions.h"
#import "UIColor+Additions.h"
#import "Stripe.h"

#import "Adjust.h"

#import "FRSCameraViewController.h"

#import "FRSTabBarController.h"


@interface AppDelegate ()

@property (strong, nonatomic) FRSRootViewController *frsRootViewController;

@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) UIMutableApplicationShortcutItem *assignmentAction;

@property NSNumber *numAssignments;

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
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        
        [[FRSLocationManager sharedManager] setupLocationMonitoringForState:LocationManagerStateBackground];
        
    }
    
    //Check if we've launched the app before or if the app is the iPhone 4s/4
    if ([[NSUserDefaults standardUserDefaults] boolForKey:UD_HAS_LAUNCHED_BEFORE] || IS_IPHONE_4S){
        [self registerForPushNotifications];
        [self.frsRootViewController setRootViewControllerToTabBar];
    }
    else {
        [self.frsRootViewController setRootViewControllerToOnboard];
        self.frsRootViewController.onboardVisited = YES;
    }
    
//    [self createItemsWithIcons];
    
    return YES;
}

-(void)applicationDidEnterBackground:(UIApplication *)application{
    
    NSLog(@"DID ENTER BACKGROUND");
    
    
    if (([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied) || ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined)) {
        NSLog(@"location denied");
    } else if (([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedAlways) || ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse)){
        NSLog(@"location accepted");
        [[FRSLocationManager sharedManager] setupLocationMonitoringForState:LocationManagerStateBackground];
        
        [[FRSLocationManager sharedManager] setupLocationMonitoringForState:LocationManagerStateBackground];
        
        if([FRSUploadManager sharedManager].isUploadingGallery){
            [self fireFailedUploadLocalNotification];
        }
    }
}

-(void)applicationWillTerminate:(UIApplication *)application{
    
    NSLog(@"WILL TERMINATE");
    
    [[FRSLocationManager sharedManager] setupLocationMonitoringForState:LocationManagerStateBackground];
}


- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
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
    
    NSLog( @"### running FB sdk version: %@", [FBSDKSettings sdkVersion] );
    
    NSLog(@"APPLICATION DID BECOME ACTIVE");
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse){
        [[FRSLocationManager sharedManager] setupLocationMonitoringForState:LocationManagerStateForeground];
    }
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
}

- (void)setupBarButtonItemAppearance
{
    [UIBarButtonItem appearance].tintColor = [UIColor darkGoldBarButtonColor];
}

#pragma mark - Delegate Setup

- (void)configureAppWithLaunchOptions:(NSDictionary *)launchOptions
{
    //AFNetworking Logging
//    [[AFNetworkActivityLogger sharedLogger] startLogging];
    
    //Fabric
    [Fabric with:@[CrashlyticsKit]];
    
    //Stripe
    [Stripe setDefaultPublishableKey:STRIPE_PUBLISHABLE_KEY];

    //Parse
    [Parse setApplicationId:PARSE_APP_ID clientKey:PARSE_CLIENT_KEY];
    
    //Facebook Utilities
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    //Twitter Utilities
    [PFTwitterUtils initializeWithConsumerKey:TWITTER_CONSUMER_KEY
                               consumerSecret:TWITTER_CONSUMER_SECRET];
    
    NSString *appToken = @"43lq9tvcgnwg";
    NSString *environment = ADJEnvironmentSandbox; //CHECK FOR RELEASE
    ADJConfig *adjustConfig = [ADJConfig configWithAppToken:appToken environment:environment];
    [Adjust appDidLaunch:adjustConfig];

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
    else if ([userInfo[@"type"] isEqualToString:NOTIF_ASSIGNMENT] && userInfo[@"assignment"]) {
        
        [self openAssignmentFromPush:userInfo[@"assignment"] withNavigation:NO];
        
    }
    //Story
    else if ([userInfo[@"type"] isEqualToString:NOTIF_LIST] && userInfo[@"galleries"]) {
        
        NSArray *galleryList = userInfo[@"galleries"];
        
        [self openGalleryListFromPush:galleryList withTitle:userInfo[@"title"]];
        
    }
    //List of galleries
    else if ([userInfo[@"type"] isEqualToString:NOTIF_STORY] && userInfo[@"story"]) {

        [self openStoryFromPush:userInfo[@"story"]];
        
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

-(BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier
{
    
    if (extensionPointIdentifier == UIApplicationKeyboardExtensionPointIdentifier)
    {
        return NO;
    }
    
    return YES;
}


- (void)createItemsWithIcons {
    
    // create icon with custom images
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0){
        
        UIApplicationShortcutIcon *camera = [UIApplicationShortcutIcon iconWithTemplateImageName:@"quick-action-camera"];
        UIApplicationShortcutIcon *video = [UIApplicationShortcutIcon iconWithTemplateImageName:@"quick-action-video"];
        UIApplicationShortcutIcon *map = [UIApplicationShortcutIcon iconWithTemplateImageName:@"quick-action-map"];
        
        // create dynamic shortcut items
        UIMutableApplicationShortcutItem *item1 = [[UIMutableApplicationShortcutItem alloc]initWithType:@"quick-action-camera" localizedTitle:@"Take photo" localizedSubtitle:@"" icon:camera userInfo:nil];
        
        UIMutableApplicationShortcutItem *item2 = [[UIMutableApplicationShortcutItem alloc]initWithType:@"quick-action-video" localizedTitle:@"Take video" localizedSubtitle:@"" icon:video userInfo:nil];
        
        UIMutableApplicationShortcutItem *item3 = [[UIMutableApplicationShortcutItem alloc]initWithType:@"quick-action-map" localizedTitle:@"Assignments" localizedSubtitle:@"" icon:map userInfo:nil];
        
        // add all items to an array
        NSArray *items = @[item1, item2, item3];
        
        // add the array to our app
        [UIApplication sharedApplication].shortcutItems = items;
    }
}



/* Called from FRSLocationManager */
- (void)updateAssignmentCount:(NSNotification *)notification {
    
    self.numAssignments = (NSNumber *)notification.object;
    
}


- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler{
    
    //Which index of the tabbar are we trying to present?
    NSInteger indexToPresent;
    FRSCaptureMode captureMode;
    
    if ([shortcutItem.localizedTitle isEqual: @"Take photo"]) {
        indexToPresent = 2;
        captureMode = FRSCaptureModePhoto;
        //        [self.frsRootViewController setRootViewControllerToCamera];
    } else if ([shortcutItem.localizedTitle isEqual: @"Assignments"]) {
        //        [self.frsRootViewController setRootViewControllerToAssignments];
        indexToPresent = 3;
    } else if ([shortcutItem.localizedTitle isEqual: @"Take video"]) {
        captureMode = FRSCaptureModeVideo;
        //        [self.frsRootViewController setRootViewControllerToCameraForVideo];
        indexToPresent = 2;
    }
    
    
    UIViewController *vc = self.frsRootViewController.viewController;
    
    if (!vc)  return;
    
    else{
        FRSTabBarController *tbvc = (FRSTabBarController *)vc;
        
        if (tbvc.selectedIndex == indexToPresent){ //we were already on the view controller
            if (indexToPresent == 2 && [tbvc.presentedViewController isKindOfClass:[FRSCameraViewController class]]){
                FRSCameraViewController *camVC = (FRSCameraViewController *)tbvc.presentedViewController;
                
                if (camVC.isPresented && camVC.captureMode != captureMode){ //The camera was the last visible viewcontroller and the user has not gone to assetpicker or gallerypost but the desired capture mode is different than current capture mode
                    [camVC toggleCaptureMode];
                }
                else if (!camVC.isPresented){ //The tabbar did present the camera vc, but the user moved to the assetpicker or gallery post
                    [camVC dismissAndReturnToPreviousTab];
                    captureMode == FRSCaptureModePhoto ? [self.frsRootViewController setRootViewControllerToCamera] : [self.frsRootViewController setRootViewControllerToCameraForVideo];
                }
            }
        }
        else{ //We were NOT on the correct view controller
            if (indexToPresent == 2){
                [[NSUserDefaults standardUserDefaults] setInteger:tbvc.selectedIndex forKey:UD_PREVIOUSLY_SELECTED_TAB];
                captureMode == FRSCaptureModePhoto ? [self.frsRootViewController setRootViewControllerToCamera] : [self.frsRootViewController setRootViewControllerToCameraForVideo];
                
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (tbvc.presentedViewController && [tbvc.presentedViewController isKindOfClass:[FRSCameraViewController class]]){
                        FRSCameraViewController *camVC = (FRSCameraViewController *)tbvc.presentedViewController;
                        [camVC dismissViewControllerAnimated:NO completion:^{
                            [self.frsRootViewController setRootViewControllerToAssignments];
                        }];
                    }
                    else {
                        [self.frsRootViewController setRootViewControllerToAssignments];
                    }
                });
                
            }
        }
        return;
    }
}


@end