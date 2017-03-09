
    //
//  FRSAppDelegate.m
//  Fresco
//
//  Created by Daniel Sun on 12/18/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSAppDelegate.h"
#import "FRSTabBarController.h"
#import "FRSOnboardingViewController.h"
#import "FRSNavigationController.h"
#import "FRSLocationManager.h"
#import "MagicalRecord.h"
#import <CoreLocation/CoreLocation.h>
#import "SAMKeychain.h"
#import "FRSUser.h"
#import "FRSNavigationBar.h"
#import "FRSStoryDetailViewController.h"
#import "FRSNavigationController.h"
#import "FRSUploadManager.h"
#import "FRSNotificationHandler.h"
#import <UserNotifications/UserNotifications.h>
#import "EndpointManager.h"
#import "FRSAuthManager.h"
#import "FRSUserManager.h"
#import "FRSNotificationManager.h"
#import "FRSStripe.h"
#import "Adjust.h"
#import "FRSIndicatorDot.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:(v) options:NSNumericSearch] != NSOrderedAscending)

@implementation FRSAppDelegate

#pragma mark - Startup and Application States

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];

    NSString *yourAppToken = @"bxk48kwhbx8g";
    NSString *environment = ADJEnvironmentSandbox;
    ADJConfig *adjustConfig = [ADJConfig configWithAppToken:yourAppToken
                                                environment:environment];

    [Adjust appDidLaunch:adjustConfig];

    [self startFabric]; // crashlytics first yall
    [self configureSmooch];
    [self configureStartDate];
    [self clearUploadCache];
    [self setCoreDataController:[[FRSCoreDataController alloc] init]]; //Initialize CoreData
    
    EndpointManager *manager = [EndpointManager sharedInstance];
    [Stripe setDefaultPublishableKey:manager.currentEndpoint.stripeKey];

    [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];

    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    if ([self isFirstRun] && !launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [[FRSAuthManager sharedInstance] logout];
    }

    [self configureWindow];
    [self configureThirdPartyApplicationsWithOptions:launchOptions];

    //Migration checks
    if ([[NSUserDefaults standardUserDefaults] valueForKey:userNeedsToMigrate] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:userNeedsToMigrate] boolValue]) {
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:userNeedsToMigrate];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    if ([[FRSAuthManager sharedInstance] isAuthenticated] || launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        self.tabBarController = [[FRSTabBarController alloc] init];
        FRSNavigationController *mainNav = [[FRSNavigationController alloc] initWithNavigationBarClass:[FRSNavigationBar class] toolbarClass:Nil];

        [mainNav pushViewController:self.tabBarController animated:FALSE];
        [mainNav setNavigationBarHidden:YES];

        self.window.rootViewController = mainNav;
        [self createItemsWithIcons];
        [[FRSUserManager sharedInstance] reloadUser];
        [self startNotificationTimer];
    } else {
        [self startAuthentication];

        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }

        return YES; // no other stuff going on (no quick action handling, etc)
    }

    if (launchOptions[UIApplicationLaunchOptionsLocationKey]) {
        [self handleLocationUpdate];
    }
    if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
        [FRSNotificationHandler handleNotification:[launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] userInfo]];
    }
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        // If we don't check for <iOS 10, multiple calls to handleRemotePush will be made.
        // Once here, and once in userNotificationCenter:didReceiveNotificationResponse.
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
            [FRSNotificationHandler handleNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
        }
    }
    if (launchOptions[UIApplicationLaunchOptionsShortcutItemKey]) {
        [self handleColdQuickAction:launchOptions[UIApplicationLaunchOptionsShortcutItemKey]];
    }

    [self registerForPushNotifications];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[FRSUploadManager sharedInstance] checkCachedUploads];

    [FRSTracker startSegmentAnalytics];
    [FRSTracker trackUser];

    return YES;
}

- (void)configureStartDate {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:startDate] == nil) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:startDate];
    }
}

- (void)clearUploadCache {
    BOOL isDir;
    NSString *directory = [NSTemporaryDirectory() stringByAppendingPathComponent:@"frs"]; // temp directory where we store video
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:directory isDirectory:&isDir])
        if (![fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL])
            NSLog(@"Error: Create folder failed %@", directory);

    // purge old un-needed files
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSString *directory = [NSTemporaryDirectory() stringByAppendingPathComponent:@"frs"];
      NSError *error = nil;
      for (NSString *file in [fileManager contentsOfDirectoryAtPath:directory error:&error]) {
          BOOL success = [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@%@", directory, file] error:&error];

          if (!success || error) {
              NSLog(@"Upload cache purge %@ with error: %@", (success) ? @"succeeded" : @"failed", error);
          }
      }
    });
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity
      restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    if ([[userActivity activityType] isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *url = [userActivity webpageURL];

        // url object contains your universal link content

        [Adjust appWillOpenUrl:url];
    }

    // Apply your logic to determine the return value of this method
    return YES;
    // or
    // return NO;
}


- (BOOL)isValue:(id)value {
    if (value != Nil && ![value isEqual:[NSNull null]]) {
        return TRUE;
    }

    return FALSE;
}

- (void)clearKeychain {

    //    SAMKeychainQuery *query = [[SAMKeychainQuery alloc] init];
    //
    //    NSArray *accounts = [query fetchAll:nil];
    //
    //    for (id account in accounts) {
    //
    //        SAMKeychainQuery *query = [[SAMKeychainQuery alloc] init];
    //
    //        query.service = serviceName;
    //        query.account = [account valueForKey:@"acct"];
    //
    //        [query deleteItem:nil];
    //    }
}

- (BOOL)isFirstRun {

    BOOL firstRun = [[[NSUserDefaults standardUserDefaults] stringForKey:@"isFirstRun"] isEqualToString:@"Yeah It Totally Is"];
    [[NSUserDefaults standardUserDefaults] setObject:@"Yeah It Totally Is" forKey:@"isFirstRun"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    return !firstRun;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation {

    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation];
    // Add any custom logic here.
    return handled;
}

- (void)startFabric {

    [[Twitter sharedInstance] startWithConsumerKey:[EndpointManager sharedInstance].currentEndpoint.twitterConsumerKey consumerSecret:[EndpointManager sharedInstance].currentEndpoint.twitterConsumerSecret];
    [Fabric with:@[ [Twitter class], [Crashlytics class] ]];
}

- (void)configureSmooch {
    [Smooch initWithSettings:[SKTSettings settingsWithAppToken:[EndpointManager sharedInstance].currentEndpoint.smoochToken]];
}


- (void)userNotificationCenter:(UNUserNotificationCenter *)center
    didReceiveNotificationResponse:(UNNotificationResponse *)response
             withCompletionHandler:(void (^)())completionHandler {

    NSLog(@"Handle push from background or closed");
    // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
    NSLog(@"%@", response.notification.request.content.userInfo);
    [FRSNotificationHandler handleNotification:response.notification.request.content.userInfo];
}


- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.opentoggle.c" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - Core Data Saving support

- (void)saveContext {
    [[self coreDataController] saveContext];
}

- (UITabBarController *)tabBar {
    return self.tabBarController;
}

- (void)startAuthentication {
    self.tabBarController = [[FRSTabBarController alloc] init];

    FRSNavigationController *mainNav = [[FRSNavigationController alloc] initWithNavigationBarClass:[FRSNavigationBar class] toolbarClass:Nil];
    [mainNav pushViewController:_tabBarController animated:FALSE];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          [mainNav pushViewController:[[FRSOnboardingViewController alloc] init] animated:FALSE];
        });
    }
    [mainNav setNavigationBarHidden:YES];
    self.window.rootViewController = mainNav;
}

// when the app isn't open
- (void)handleColdQuickAction:(UIApplicationShortcutItem *)shortcutItem {

    FRSTabBarController *tab = (FRSTabBarController *)self.window.rootViewController;

    if ([[tab class] isSubclassOfClass:[UITabBarController class]]) {
        [tab respondToQuickAction:shortcutItem.type]; // tab bar can handle change
    } else {
        UINavigationController *nav = (UINavigationController *)tab;
        tab = (FRSTabBarController *)[[nav viewControllers] firstObject];
        if ([[tab class] isSubclassOfClass:[UITabBarController class]]) {
            [tab respondToQuickAction:shortcutItem.type];
        }
    }
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {

    FRSTabBarController *tab = (FRSTabBarController *)self.window.rootViewController;

    if ([[tab class] isSubclassOfClass:[UITabBarController class]]) {
        [tab respondToQuickAction:shortcutItem.type]; // tab bar can handle change
    } else {
        UINavigationController *nav = (UINavigationController *)tab;
        tab = (FRSTabBarController *)[[nav viewControllers] firstObject];
        if ([[tab class] isSubclassOfClass:[UITabBarController class]]) {
            [tab respondToQuickAction:shortcutItem.type];
        }
    }
}

- (void)registerForPushNotifications {
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0") == FALSE) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];

    } else {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge)
                              completionHandler:^(BOOL granted, NSError *_Nullable error) {
                                if (!error) {
                                    [[UIApplication sharedApplication] registerForRemoteNotifications]; // required to get the app to do anything at all about push notifications
                                    NSLog(@"Push registration success.");
                                } else {
                                    NSLog(@"Push registration FAILED");
                                    NSLog(@"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription);
                                    NSLog(@"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion);
                                }
                              }];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // iOS 10 will handle notifications through other methods
    // custom code to handle notification content

    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive) {
        [FRSNotificationHandler handleNotification:userInfo];
    }

    if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        completionHandler(UIBackgroundFetchResultNewData);
    } else if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        [FRSNotificationHandler handleNotification:userInfo];
        completionHandler(UIBackgroundFetchResultNewData);
    } else {
        completionHandler(UIBackgroundFetchResultNewData);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self application:application
        didReceiveRemoteNotification:userInfo
              fetchCompletionHandler:^(UIBackgroundFetchResult result) {
                // nothing
                  [FRSNotificationHandler handleNotification:userInfo];
              }];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    const unsigned *tokenData = [deviceToken bytes];
    NSString *newDeviceToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                                                          ntohl(tokenData[0]), ntohl(tokenData[1]), ntohl(tokenData[2]),
                                                          ntohl(tokenData[3]), ntohl(tokenData[4]), ntohl(tokenData[5]),
                                                          ntohl(tokenData[6]), ntohl(tokenData[7])];

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"] == Nil) {
        [FRSTracker track:notificationsEnabled];
    }

    NSString *oldDeviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];

    [[NSUserDefaults standardUserDefaults] setObject:newDeviceToken forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSMutableDictionary *installationDigest = (NSMutableDictionary *)[[FRSAuthManager sharedInstance] currentInstallation];

    if (oldDeviceToken && [[oldDeviceToken class] isSubclassOfClass:[NSString class]] && ![oldDeviceToken isEqualToString:newDeviceToken]) {
        [installationDigest setObject:oldDeviceToken forKey:@"old_device_token"];
    }

    if ([[FRSAuthManager sharedInstance] isAuthenticated]) {
        [[FRSUserManager sharedInstance] updateUserWithDigestion:@{ @"installation" : installationDigest }
            completion:^(id responseObject, NSError *error) {
              NSLog(@"Updated user installation");
            }];
    }
}

- (void)handleLocationUpdate {
}

- (void)restartUpload {
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(nonnull UILocalNotification *)notification {
    [FRSNotificationHandler handleNotification:notification.userInfo];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [FRSTracker stopUXCam];
    [[FRSLocationManager sharedManager] pauseLocationMonitoring];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

    if ([[FRSAuthManager sharedInstance] isAuthenticated] && !self.didPresentPermissionsRequest) {
        if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)) {
            [[FRSLocationManager sharedManager] startLocationMonitoringForeground];
        }
    }
    
    [FRSTracker startUXCam];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FRSResetUpload" object:nil userInfo:@{ @"type" : @"reset" }];
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

#pragma mark - Push Notifications

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [FRSTracker track:notificationsDisabled];
}

- (void)startNotificationTimer {
    if (!notificationTimer) {
        notificationTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(checkNotifications) userInfo:nil repeats:YES];
    }
}

- (void)stopNotificationTimer {
    if (notificationTimer) {
        [notificationTimer invalidate];
        notificationTimer = nil;
    }
}

- (void)checkNotifications {
    if (![[FRSAuthManager sharedInstance] isAuthenticated]) {
        return;
    }

    [[FRSNotificationManager sharedInstance] getNotificationsWithCompletion:^(id responseObject, NSError *error) {
      if (error) {
          //soft fail
          return;
      }
      if (responseObject) {
          FRSTabBarController *tbc = (FRSTabBarController *)self.tabBarController;
          if ([tbc isKindOfClass:[FRSTabBarController class]]) {
              if ([[responseObject objectForKey:@"unseen_count"] integerValue] > 0) {
                  [(FRSTabBarController *)self.tabBar showBell:YES];
              }
          }
      }
    }];
}

#pragma mark - App Path

- (void)determineAppPath {
    NSString *versionString = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    NSArray *versionComps = [versionString componentsSeparatedByString:@"."];
    NSInteger firstVersionNum = [[versionComps firstObject] integerValue];

    /*
     Focus on this -- pull old persistance (however its managed) into new magical record / core data layer
     */
    if (firstVersionNum < 3) { // This is a legacy user from prior to the redesign and persistance layer


    } else if (firstVersionNum == 3) { // This is the current high level version number we are working with.
        

    } else { //We will eventually need this if our high level verison numbers increment, but for now, it will never get called.
    }
}

#pragma mark - Config

- (void)configureWindow {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor]; // used to be [UIColor whiteBackgroundColor];

    [self.window makeKeyAndVisible];
}

- (void)configureThirdPartyApplicationsWithOptions:(NSDictionary *)options {
}

#pragma mark - Quick Actions

- (void)createItemsWithIcons {
    BOOL isAuthenticated = TRUE; // check keychain

    if (!isAuthenticated) {
        [UIApplication sharedApplication].shortcutItems = @[];
        return;
    }

    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {

        UIApplicationShortcutIcon *camera = [UIApplicationShortcutIcon iconWithTemplateImageName:@"quick-action-camera"];
        UIApplicationShortcutIcon *video = [UIApplicationShortcutIcon iconWithTemplateImageName:@"quick-action-video"];
        UIApplicationShortcutIcon *map = [UIApplicationShortcutIcon iconWithTemplateImageName:@"quick-action-map"];

        // create dynamic shortcut items
        UIMutableApplicationShortcutItem *item1 = [[UIMutableApplicationShortcutItem alloc] initWithType:takePhotoAction localizedTitle:@"Take photo" localizedSubtitle:@"" icon:camera userInfo:nil];

        UIMutableApplicationShortcutItem *item2 = [[UIMutableApplicationShortcutItem alloc] initWithType:takeVideoAction localizedTitle:@"Take video" localizedSubtitle:@"" icon:video userInfo:nil];

        UIMutableApplicationShortcutItem *item3 = [[UIMutableApplicationShortcutItem alloc] initWithType:assignmentsAction localizedTitle:@"Assignments" localizedSubtitle:@"" icon:map userInfo:nil];

        // add all items to an array
        NSArray *items = @[ item1, item2, item3 ];

        // add the array to our app
        [UIApplication sharedApplication].shortcutItems = items;
    }
}

#pragma mark - Status Bar
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    CGPoint location = [[[event allTouches] anyObject] locationInView:[self window]];
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    if (CGRectContainsPoint(statusBarFrame, location)) {
        [self statusBarTouchedAction];
    }
}

- (void)statusBarTouchedAction {
    [[NSNotificationCenter defaultCenter] postNotificationName:kStatusBarTappedNotification
                                                        object:nil];
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(nonnull NSString *)identifier completionHandler:(nonnull void (^)())completionHandler {
    // pass responsibility onto FRSFileUploadManager (will trigger completion handler when done with work needed)
    // [[FRSFileUploadManager sharedUploader] handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
}

- (void)error:(NSError *)error {
    if (!error) {
        FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"GALLERY LOAD ERROR" message:@"Unable to load gallery. Please try again later." actionTitle:@"TRY AGAIN" cancelTitle:@"CANCEL" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
        [alert show];
    } else if (error.code == -1009) {
        FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"CONNECTION ERROR" message:@"Unable to connect to the internet. Please check your connection and try again." actionTitle:@"TRY AGAIN" cancelTitle:@"CANCEL" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
        [alert show];
    } else {
        FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"GALLERY LOAD ERROR" message:@"This gallery could not be found, or does not exist." actionTitle:@"TRY AGAIN" cancelTitle:@"CANCEL" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
        [alert show];
    }
}

- (FRSStoryDetailViewController *)detailViewControllerWithStory:(FRSStory *)story {
    FRSStoryDetailViewController *detailView = [[FRSStoryDetailViewController alloc] initWithNibName:@"FRSStoryDetailViewController" bundle:[NSBundle mainBundle]];
    detailView.story = story;
    [detailView reloadData];
    return detailView;
}

- (void)popViewController {
}

- (void)segueHome {
    UITabBarController *tab = (UITabBarController *)self.tabBarController;
    tab.selectedIndex = 0;
    [tab.navigationController popViewControllerAnimated:TRUE];
}

#pragma mark - Core Data

- (NSManagedObjectContext *)managedObjectContext {
    return [self.coreDataController managedObjectContext];
}

@end
