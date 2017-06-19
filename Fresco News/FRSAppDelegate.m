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
#import "MagicalRecord.h"
#import <CoreLocation/CoreLocation.h>
#import "SAMKeychain.h"
#import "FRSUser.h"
#import "FRSNavigationBar.h"
#import "FRSStoryDetailViewController.h"
#import "EndpointManager.h"
#import "MagicalRecord.h"
#import "Fresco.h"
#import "FRSNavigationBar.h"
#import "FRSNavigationController.h"
#import "FRSUploadManager.h"
#import "FRSNotificationHandler.h"
#import "FRSTabBarController.h"
#import "FRSOnboardingViewController.h"
#import "FRSAuthManager.h"
#import "FRSUserManager.h"
#import "FRSSessionManager.h"
#import "FRSNotificationManager.h"
#import "FRSOnboardingViewController.h"
#import "Adjust.h"
#import <Stripe/Stripe.h>
#import "FRSIndicatorDot.h"
#import "FRSConnectivityAlertView.h"
#import "FRSUploadFailAlertView.h"


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:(v) options:NSNumericSearch] != NSOrderedAscending)

@implementation FRSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    [FRSTracker configureFabric];
    [FRSTracker launchAdjust];
    [FRSTracker configureSmooch];
    [FRSTracker startSegmentAnalytics];
    
    //Check if we 
    if ([self isFirstRun] && ![[FRSAuthManager sharedInstance] isAuthenticated]) {
        [[FRSAuthManager sharedInstance] logout];
    } else {
        [[FRSSessionManager sharedInstance] checkVersion];
    }
    
    [self configureStartDate];
    [self setCoreDataController:[[FRSCoreDataController alloc] init]]; //Initialize CoreData

    [FRSTracker trackUser];

    // Check for cached uploads from core data after core data setup has been completed.
    [[FRSUploadManager sharedInstance] checkCachedUploads];

    EndpointManager *manager = [EndpointManager sharedInstance];
    [Stripe setDefaultPublishableKey:manager.currentEndpoint.stripeKey];

    [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];

    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    [self configureWindow];

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
    
    //Track location in the background
    if(launchOptions[UIApplicationLaunchOptionsLocationKey]) {
        [[FRSLocator sharedLocator] updateLocationManagerForState:UIApplicationStateBackground];
    }
    
    if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
        [FRSNotificationHandler handleNotification:[launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] userInfo] track:YES];
    }else if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        // If we don't check for <iOS 10, multiple calls to handleRemotePush will be made.
        // Once here, and once in userNotificationCenter:didReceiveNotificationResponse.
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
            [FRSNotificationHandler handleNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] track:YES];
        }
    } else if (launchOptions[UIApplicationLaunchOptionsShortcutItemKey]) {
        [self handleColdQuickAction:launchOptions[UIApplicationLaunchOptionsShortcutItemKey]];
    }

    [self registerForPushNotifications];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];

    return YES;
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

#pragma mark - Core Data Saving support

- (void)saveContext {
    [[self coreDataController] saveContext];
}


#pragma mark - App Configuration

- (void)configureStartDate {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:startDate] == nil) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:startDate];
    }
}

- (UITabBarController *)tabBar {
    return self.tabBarController;
}

/**
 Tells us if the user is running the app the first time and also sets it to true from there on out
 
 @return True if the first run, No if not he first run
 */
- (BOOL)isFirstRun {
    BOOL firstRun = [[NSUserDefaults standardUserDefaults] boolForKey:isFirstRun];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:isFirstRun];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return !firstRun;
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


#pragma mark - App Lifecycle

- (void)applicationWillResignActive:(UIApplication *)application {
    [FRSTracker stopUXCam];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FRSTracker startUXCam];
    [[FRSLocator sharedLocator] updateLocationManagerForState:UIApplicationStateActive];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[FRSLocator sharedLocator] updateLocationManagerForState:UIApplicationStateBackground];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[FRSLocator sharedLocator] sendLocationToServerWithCompletionHandler:completionHandler];
}

#pragma mark - Local/Push Notifications

- (void)registerForPushNotifications {
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]){
        // iOS 8 Notifications
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else{
        // iOS < 8 Notifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }

}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler {
    
    NSLog(@"Handle push from background or closed");
    // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
    NSLog(@"%@", response.notification.request.content.userInfo);
    [FRSNotificationHandler handleNotification:response.notification.request.content.userInfo track:YES];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // iOS 10 will handle notifications through other methods
    // custom code to handle notification content
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive) {
        [FRSNotificationHandler handleNotification:userInfo track:YES];
    }
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        completionHandler(UIBackgroundFetchResultNewData);
    } else if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        [FRSNotificationHandler handleNotification:userInfo track:YES];
        completionHandler(UIBackgroundFetchResultNewData);
    } else {
        completionHandler(UIBackgroundFetchResultNewData);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:^(UIBackgroundFetchResult result) {
        // nothing
        [FRSNotificationHandler handleNotification:userInfo track:YES];
    }];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *newDeviceToken = [deviceToken description];
    newDeviceToken = [newDeviceToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newDeviceToken = [newDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if(![NSString isStringValid:newDeviceToken]) return; //No need to send an invalid/null string to server.
    
    //If the user isn't logged in, don't proceed with caching the token. It will be requested later.
    if (![[FRSAuthManager sharedInstance] isAuthenticated]) return;
    
    //Track and send to server.
    if ([[NSUserDefaults standardUserDefaults] objectForKey:userDeviceToken] == Nil) {
        [FRSTracker track:notificationsEnabled];
    }

    [[NSUserDefaults standardUserDefaults] setObject:newDeviceToken forKey:userDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSMutableDictionary *installationDigest = (NSMutableDictionary *)[[FRSAuthManager sharedInstance] currentInstallation];
    
    [[FRSUserManager sharedInstance] updateUserWithDigestion:@{ @"installation" : installationDigest }
                                                  completion:^(id responseObject, NSError *error) {
                                                      NSLog(@"Updated user installation");
                                                  }];

}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(nonnull UILocalNotification *)notification {
    [FRSNotificationHandler handleNotification:notification.userInfo track:NO];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [FRSTracker track:notificationsDisabled];
}

// TODO: Move out of App Delegate and into FRSTabBarController
- (void)startNotificationTimer {
    if (!notificationTimer) {
        [self checkNotifications]; // Check notifications here to avoid 15 second delay on first call.
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
            // Return without error. The user should not be aware of this failure.
            return;
        }
        if (responseObject) {
            FRSTabBarController *tbc = (FRSTabBarController *)self.tabBarController;
            if ([tbc isKindOfClass:[FRSTabBarController class]]) {
                NSNumber *unseenCount = [responseObject objectForKey:@"unseen_count"];
                if (![unseenCount isEqual:@0]) {
                    [(FRSTabBarController *)self.tabBar showBell:YES];
                }
            }
        }
    }];
}

#pragma mark - Config

- (void)configureWindow {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor]; // used to be [UIColor whiteBackgroundColor];

    [self.window makeKeyAndVisible];
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

#pragma mark - Errors


// TODO: Reuse these errors
- (void)error:(NSError *)error {
    if (!error) {
        FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"GALLERY LOAD ERROR" message:@"Unable to load gallery. Please try again later." actionTitle:@"TRY AGAIN" cancelTitle:@"CANCEL" cancelTitleColor:nil delegate:nil];
        [alert show];
    } else if (error.code == -1009) {
        FRSConnectivityAlertView *alert = [[FRSConnectivityAlertView alloc] initNoConnectionAlert];
        [alert show];
    } else {
        FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"GALLERY LOAD ERROR" message:@"This gallery could not be found, or does not exist." actionTitle:@"TRY AGAIN" cancelTitle:@"CANCEL" cancelTitleColor:nil delegate:nil];
        [alert show];
    }
}

- (void)presentError:(NSError *)error withTitle:(NSString *)title {
    //Present error to user if needed and there currently is not one in view
    if(!self.isPresentingError && self.errorAlertView.window == nil){
        self.isPresentingError = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([title isEqualToString:uploadError]) {
                FRSUploadFailAlertView *alert = [[FRSUploadFailAlertView alloc] initUploadFailAlertViewWithError:error];
                [alert show];
            } else {
                self.errorAlertView = [[FRSAlertView alloc]
                                       initWithTitle:[title uppercaseString]
                                       message:error.localizedDescription
                                       actionTitle:@"OK"
                                       cancelTitle:@""
                                       cancelTitleColor:nil
                                       delegate:nil];
                
                [self.errorAlertView show];
            }
            self.isPresentingError = NO;
        });
    }
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
