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
#import "FRSSettingsViewController.h"
#import "FRSNavigationController.h"
#import "FRSSignUpViewController.h"
#import "FRSSetupProfileViewController.h"
#import "FRSProfileViewController.h"
#import "FRSLocationManager.h"
#import "FRSCameraViewController.h"
#import "MagicalRecord.h"
#import <CoreLocation/CoreLocation.h>
#import "FRSLoginViewController.h"
#import "FRSAPIClient.h"
#import "VideoTrimmerViewController.h"
#import "Fresco.h"
#import "SAMKeychain.h"
#import "FRSUser.h"
#import "FRSNavigationBar.h"
#import "FRSHomeViewController.h"
#import "FRSStoryDetailViewController.h"
#import "FRSGalleryExpandedViewController.h"
#import "FRSNavigationController.h"
#import "FRSAssignmentsViewController.h"
#import "FRSDebitCardViewController.h"
#import "FRSTaxInformationViewController.h"
#import "FRSIdentityViewController.h"
#import "FRSStoriesViewController.h"
#import "FRSUploadManager.h"
#import "FRSNotificationHandler.h"
#import <UserNotifications/UserNotifications.h>


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:(v) options:NSNumericSearch] != NSOrderedAscending)

@implementation FRSAppDelegate
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator, managedObjectModel = _managedObjectModel, managedObjectContext = _managedObjectContext;

#pragma mark - Startup and Application States

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    [self startFabric]; // crashlytics first yall
    [self configureStartDate];
    [self clearUploadCache];
    
    [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    if ([self isFirstRun] && !launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [[FRSAPIClient sharedClient] logout];
    }
    
    [self startMixpanel];
    [self configureWindow];
    [self configureThirdPartyApplicationsWithOptions:launchOptions];
    [self persistentStoreCoordinator];
    
    [self configureCoreDataStack];
    
    //Migration checks
    if([[NSUserDefaults standardUserDefaults] valueForKey:userNeedsToMigrate] != nil && [[[NSUserDefaults standardUserDefaults] valueForKey:userNeedsToMigrate] boolValue]){
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:userNeedsToMigrate];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if ([[FRSAPIClient sharedClient] isAuthenticated] || launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        self.tabBarController = [[FRSTabBarController alloc] init];
        FRSNavigationController *mainNav = [[FRSNavigationController alloc] initWithNavigationBarClass:[FRSNavigationBar class] toolbarClass:Nil];
        
        [mainNav pushViewController:self.tabBarController animated:FALSE];
        [mainNav setNavigationBarHidden:YES];
        
        self.window.rootViewController = mainNav;
        [self createItemsWithIcons];
        [self reloadUser];
        [self startNotificationTimer];
    }
    else {
        
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
        [self handleLocalPush:[launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] userInfo]];
    }
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [self handleRemotePush:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    if (launchOptions[UIApplicationLaunchOptionsShortcutItemKey]) {
        [self handleColdQuickAction:launchOptions[UIApplicationLaunchOptionsShortcutItemKey]];
    }
    
    [self registerForPushNotifications];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[FRSUploadManager sharedUploader] checkCachedUploads];
    
    return YES;
}

-(void)configureStartDate {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:startDate] == nil) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:startDate];
    }
}

-(void)clearUploadCache {
    
    BOOL isDir;
    NSString *directory = [NSTemporaryDirectory() stringByAppendingPathComponent:@"frs"]; // temp directory where we store video
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:directory isDirectory:&isDir])
        if(![fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL])
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

-(void)startMixpanel {
    [Mixpanel sharedInstanceWithToken:mixPanelToken];
    
    if ([[FRSAPIClient sharedClient] authenticatedUser]) {
        [[Mixpanel sharedInstance] identify:[[FRSAPIClient sharedClient] authenticatedUser].uid];
        FRSUser *user = [[FRSAPIClient sharedClient] authenticatedUser];
        
        if (user.uid && ![user.uid isEqual:[NSNull null]]) {
            [[[Mixpanel sharedInstance] people] set:@{@"fresco_id":user.uid}];
        }
        
        if (user.firstName && ![user.firstName isEqual:[NSNull null]]) {
            [[[Mixpanel sharedInstance] people] set:@{@"$name":user.firstName}];
        }
    }
    else {
        [[Mixpanel sharedInstance] identify:[Mixpanel sharedInstance].distinctId];
    }
}

-(void)markAsRead:(NSString *)notificationID {
    NSDictionary *params = @{@"notification_ids":@[notificationID]};
    [[FRSAPIClient sharedClient] post:@"user/notifications/see" withParameters:params completion:^(id responseObject, NSError *error) {
        BOOL success = FALSE;
        
        if (!error && responseObject) {
            success = TRUE;
        }
    }];
}

-(void)refreshSettings {
    [[FRSAPIClient sharedClient] fetchSettings:^(id responseObject, NSError *error) {
        if ([[responseObject class] isSubclassOfClass:[NSArray class]]) {
            for (NSDictionary *setting in responseObject) {
                if ([setting[@"type"] isEqualToString:@"notify-user-dispatch-new-assignment"]) {
                    if (setting[@"options"] && ![setting[@"option"] isEqual:[NSNull null]]) {
                        if ([setting[@"options"][@"send_push"] boolValue]) {
                            [[NSUserDefaults standardUserDefaults] setValue:@(TRUE) forKey:settingsUserNotificationToggle];
                        }
                        else {
                            [[NSUserDefaults standardUserDefaults] setValue:@(FALSE) forKey:settingsUserNotificationToggle];
                        }
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }
            }
        }
    }];
}

-(void)reloadUser:(FRSAPIDefaultCompletionBlock)completion {
    
    [[FRSAPIClient sharedClient] refreshCurrentUser:^(id responseObject, NSError *error) {
        // check against existing user
        if (error || responseObject[@"error"]) {
            // throw up sign in
            
            return;
        }
        
        [self.managedObjectContext performBlock:^{
            [self saveUserFields:responseObject];
        }];
        
        if ([[FRSAPIClient sharedClient] isAuthenticated] && !self.didPresentPermissionsRequest) {
            if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)) {
                [[FRSLocationManager sharedManager] startLocationMonitoringForeground];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(Nil,Nil);
            }
        });
        
    }];
    
    [self refreshSettings];
}

-(void)saveUserFields:(NSDictionary *)responseObject {
    FRSUser *authenticatedUser = [[FRSAPIClient sharedClient] authenticatedUser];
    
    if (!authenticatedUser) {
        authenticatedUser = [NSEntityDescription insertNewObjectForEntityForName:@"FRSUser" inManagedObjectContext:[self managedObjectContext]];
    }
    
    // update user
    
    if (responseObject[@"id"] && ![responseObject[@"id"] isEqual:[NSNull null]]) {
        authenticatedUser.uid = responseObject[@"id"];
    }
    //        authenticatedUser.email = responseObject[@"email"];
    
    if (![responseObject[@"full_name"] isEqual:[NSNull null]]) {
        authenticatedUser.firstName = responseObject[@"full_name"];
    }
    if (responseObject[@"username"] && ![responseObject[@"username"] isEqual:[NSNull null]]) {
        authenticatedUser.username = responseObject[@"username"];
    }
    if (![responseObject[@"bio"] isEqual:[NSNull null]]) {
        authenticatedUser.bio = responseObject[@"bio"];
    }
    if (![responseObject[@"email"] isEqual:[NSNull null]]) {
        authenticatedUser.email = responseObject[@"email"];
    }
    authenticatedUser.isLoggedIn = @(TRUE);
    if (![responseObject[@"avatar"] isEqual:[NSNull null]]) {
        authenticatedUser.profileImage = responseObject[@"avatar"];
    }
    
    if (responseObject[@"location"] != Nil && ![responseObject[@"location"] isEqual:[NSNull null]]) {
        [authenticatedUser setValue:responseObject[@"location"] forKey:@"location"];
    }
    
    if (responseObject[@"followed_count"] != Nil && ![responseObject[@"followed_count"] isEqual:[NSNull null]]) {
        [authenticatedUser setValue:responseObject[@"followed_count"] forKey:@"followedCount"];
    }
    
    if (responseObject[@"following_count"] != Nil && ![responseObject[@"following_count"] isEqual:[NSNull null]]) {
        [authenticatedUser setValue:responseObject[@"following_count"] forKey:@"followingCount"];
    }
    
    
    if (responseObject[@"terms"] && ![responseObject[@"terms"] isEqual:[NSNull null]] && [responseObject[@"terms"][@"valid"] boolValue] == FALSE) { /* */
        UITabBarController *tabBar = (UITabBarController *)self.tabBarController;
        UINavigationController *nav = [tabBar.viewControllers firstObject];
        FRSHomeViewController *homeViewController = [nav.viewControllers firstObject];
        [homeViewController presentTOS];
    }
    
    if (responseObject[@"blocked"] && ![responseObject[@"blocked"] isEqual:[NSNull null]]) {
        authenticatedUser.blocked = [responseObject[@"blocked"] boolValue];
    }
    
    if (responseObject[@"blocking"] && ![responseObject[@"blocking"] isEqual:[NSNull null]]) {
        authenticatedUser.blocking = [responseObject[@"blocking"] boolValue];
    }
    
    if (responseObject[@"suspended_until"] && ![responseObject[@"suspended_until"] isEqual:[NSNull null]]) {
        authenticatedUser.suspended = YES;
    } else {
        authenticatedUser.suspended = NO;
    }
    
    if (responseObject[@"disabled"] && ![responseObject[@"disabled"] isEqual:[NSNull null]]) {
        authenticatedUser.disabled = [responseObject[@"disabled"] boolValue];
    }
    
    if (responseObject[@"identity"] && ![responseObject[@"identity"] isKindOfClass:[[NSNull null] class]]) {
        
        //        if (responseObject[@"identity"][@"due_by"] != Nil && ![responseObject[@"identity"][@"due_by"] isEqual:[NSNull null]]) {
        //            [authenticatedUser setValue:responseObject[@"due_by"] forKey:@"due_by"];
        //        }
        
        if (responseObject[@"identity"][@"first_name"] != Nil && ![responseObject[@"identity"][@"first_name"] isEqual:[NSNull null]]) {
            [authenticatedUser setValue:responseObject[@"identity"][@"first_name"] forKey:@"stripeFirst"];
        }
        if (responseObject[@"identity"][@"last_name"] != Nil && ![responseObject[@"identity"][@"last_name"] isEqual:[NSNull null]]) {
            [authenticatedUser setValue:responseObject[@"identity"][@"last_name"] forKey:@"stripeLast"];
        }
        
        
        
        NSDictionary *identity = responseObject[@"identity"];
        
        NSString *birthDay = identity[@"dob_day"];
        NSString *birthMonth = identity[@"dob_month"];
        NSString *birthYear = identity[@"dob_year"];
        NSString *addressLineOne = identity[@"address_line1"];
        NSString *addressLineTwo = identity[@"address_line2"];
        NSString *addressZip = identity[@"address_zip"];
        NSString *addressCity = identity[@"address_city"];
        NSString *addressState = identity[@"address_state"];
        
        NSString *radius = [responseObject valueForKey:@"radius"];
        if ([self isValue:radius]) {
            [[NSUserDefaults standardUserDefaults] setValue:radius forKey:settingsUserNotificationRadius];
            authenticatedUser.notificationRadius = @([radius floatValue]);
        }
        
        BOOL hasSavedFields = FALSE;
        
        if ([self isValue:birthDay]) {
            [authenticatedUser setValue:birthDay forKey:@"dob_day"];
            hasSavedFields = TRUE;
        }
        if ([self isValue:birthMonth]) {
            [authenticatedUser setValue:birthMonth forKey:@"dob_month"];
            hasSavedFields = TRUE;
            
        }
        if ([self isValue:birthYear]) {
            [authenticatedUser setValue:birthYear forKey:@"dob_year"];
            hasSavedFields = TRUE;
            
        }
        if ([self isValue:addressLineOne]) {
            [authenticatedUser setValue:addressLineOne forKey:@"address_line1"];
            hasSavedFields = TRUE;
            
        }
        if ([self isValue:addressLineTwo]) {
            [authenticatedUser setValue:addressLineTwo forKey:@"address_line2"];
            hasSavedFields = TRUE;
            
        }
        
        
        if ([self isValue:addressZip]) {
            [authenticatedUser setValue:addressZip forKey:@"address_zip"];
            hasSavedFields = TRUE;
            
        }
        if ([self isValue:addressCity]) {
            [authenticatedUser setValue:addressCity forKey:@"address_city"];
            hasSavedFields = TRUE;
            
        }
        if ([self isValue:addressState]) {
            [authenticatedUser setValue:addressState forKey:@"address_state"];
            hasSavedFields = TRUE;
            
        }
        
        NSArray *fieldsNeeded = identity[@"fields_needed"];
        
        if(fieldsNeeded) {
            [authenticatedUser setValue:fieldsNeeded forKey:@"fieldsNeeded"];
            [authenticatedUser setValue:@(hasSavedFields) forKey:@"hasSavedFields"];
        }
        
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self saveContext];
        });
    }
}

-(void)reloadUser {
    [self reloadUser:Nil];
}

-(BOOL)isValue:(id)value {
    if (value != Nil && ![value isEqual:[NSNull null]]) {
        return TRUE;
    }
    
    return FALSE;
}

-(void)clearKeychain {
    
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

-(BOOL)isFirstRun {
    
    BOOL firstRun = [[[NSUserDefaults standardUserDefaults] stringForKey:@"isFirstRun"] isEqualToString:@"Yeah It Totally Is"];
    [[NSUserDefaults standardUserDefaults] setObject:@"Yeah It Totally Is" forKey:@"isFirstRun"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return !firstRun;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation
                    ];
    // Add any custom logic here.
    return handled;
}

-(void)startFabric {
    [[Twitter sharedInstance] startWithConsumerKey:@"kT772ISFiuWQdVQblU4AmBWw3" consumerSecret:@"navenvTSRCcyUL7F4Ait3gACnxfc7YXWyaee2bAX1sWnYGe4oY"];
    [Fabric with:@[[Twitter class], [Crashlytics class]]];
    [Smooch initWithSettings:[SKTSettings settingsWithAppToken:@"bmk6otjwgrb5wyaiohse0qbr0"]];
}

- (NSManagedObjectModel *)managedObjectModel {
    //    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    //    if (_managedObjectModel != nil) {
    //        return _managedObjectModel;
    //    }
    //    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    //    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    //    return _managedObjectModel;
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    // [self handleRemotePush:notification.request.content.userInfo];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler
{
    NSLog( @"Handle push from background or closed" );
    // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
    NSLog(@"%@", response.notification.request.content.userInfo);
    [self handleRemotePush:response.notification.request.content.userInfo];
}



- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.opentoggle.c" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

-(UITabBarController *)tabBar {
    return self.tabBarController;
}





-(void)startAuthentication {
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

-(BOOL)isAuthenticated {
    
    // check against keychian
    
    return FALSE;
}
// when the app isn't open
-(void)handleColdQuickAction:(UIApplicationShortcutItem *)shortcutItem {
    
    FRSTabBarController *tab = (FRSTabBarController *)self.window.rootViewController;
    
    if ([[tab class] isSubclassOfClass:[UITabBarController class]]) {
        [tab respondToQuickAction:shortcutItem.type]; // tab bar can handle change
    }
    else {
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
    }
    else {
        UINavigationController *nav = (UINavigationController *)tab;
        tab = (FRSTabBarController *)[[nav viewControllers] firstObject];
        if ([[tab class] isSubclassOfClass:[UITabBarController class]]) {
            [tab respondToQuickAction:shortcutItem.type];
        }
    }
}

-(void)registerForPushNotifications {
    
    return;
    
    
    //    UIUserNotificationType types = (UIUserNotificationType) (UIUserNotificationTypeBadge |
    //                                                             UIUserNotificationTypeSound | UIUserNotificationTypeAlert);
    //
    //    UIUserNotificationSettings *mySettings =
    //    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    //
    //    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    //    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO( @"10.0" ) == FALSE)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound |    UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
        //if( option != nil )
        //{
        //    NSLog( @"registerForPushWithOptions:" );
        //}
    }
    else
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error)
         {
             if( !error )
             {
                 [[UIApplication sharedApplication] registerForRemoteNotifications];  // required to get the app to do anything at all about push notifications
                 NSLog( @"Push registration success." );
             }
             else
             {
                 NSLog( @"Push registration FAILED" );
                 NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
                 NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
             }
         }];
    }
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void(^)(UIBackgroundFetchResult))completionHandler
{
    // iOS 10 will handle notifications through other methods
    // custom code to handle notification content
    if([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive)
    {
        [self handleRemotePush:userInfo];
    }
    
    if( [UIApplication sharedApplication].applicationState == UIApplicationStateInactive )
    {
        NSLog( @"INACTIVE" );
        completionHandler( UIBackgroundFetchResultNewData );
    }
    else if( [UIApplication sharedApplication].applicationState == UIApplicationStateBackground )
    {
        [self handleRemotePush:userInfo];
        NSLog( @"BACKGROUND" );
        completionHandler( UIBackgroundFetchResultNewData );
    }
    else
    {
        NSLog( @"FOREGROUND" );
        completionHandler( UIBackgroundFetchResultNewData );
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:^(UIBackgroundFetchResult result) {
        // nothing
        [self handleRemotePush:userInfo];
    }];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    const unsigned *tokenData = [deviceToken bytes];
    NSString *newDeviceToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                                ntohl(tokenData[0]), ntohl(tokenData[1]), ntohl(tokenData[2]),
                                ntohl(tokenData[3]), ntohl(tokenData[4]), ntohl(tokenData[5]),
                                ntohl(tokenData[6]), ntohl(tokenData[7])];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"] == Nil)  {
        [FRSTracker track:notificationsEnabled];
    }
    
    NSString *oldDeviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
    
    [[NSUserDefaults standardUserDefaults] setObject:newDeviceToken forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSMutableDictionary *installationDigest = (NSMutableDictionary *)[[FRSAPIClient sharedClient] currentInstallation];
    
    if (oldDeviceToken && [[oldDeviceToken class] isSubclassOfClass:[NSString class]] && ![oldDeviceToken isEqualToString:newDeviceToken]) {
        [installationDigest setObject:oldDeviceToken forKey:@"old_device_token"];
    }
    
    
    
    [[FRSAPIClient sharedClient] updateUserWithDigestion:@{@"installation":installationDigest} completion:^(id responseObject, NSError *error) {
        NSLog(@"Updated user installation");
    }];
    
}

-(void)handleLocationUpdate {
    
}

-(void)handleLocalPush:(NSDictionary *)push {
    [self handleRemotePush:push];
}

-(void)handleRemotePush:(NSDictionary *)push {
    [FRSNotificationHandler handleNotification:push];
}

-(void)restartUpload {
    
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(nonnull UILocalNotification *)notification {
    [self handleRemotePush:notification.userInfo];
}

-(void)applicationDidEnterBackground:(UIApplication *)application {
    //    UNMutableNotificationContent *objNotificationContent = [[UNMutableNotificationContent alloc] init];
    //    objNotificationContent.title = [NSString localizedUserNotificationStringForKey:@"Title" arguments:nil];
    //    objNotificationContent.body = [NSString localizedUserNotificationStringForKey:@"Body"
    //                                                                        arguments:nil];
    //    objNotificationContent.sound = [UNNotificationSound defaultSound];
    //    objNotificationContent.userInfo = @{@"type":followedNotification, @"meta": @{@"user_ids": @[@"neN16OqW3D47"]}};
    //
    //    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[NSDate date]];
    //    components.second += 3;
    //    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger
    //                                              triggerWithDateMatchingComponents:components repeats:FALSE];
    //
    //    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"com.fresconews.Fresco"
    //                                                                          content:objNotificationContent trigger:trigger];
    //    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    //    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
    //        if (!error) {
    //            NSLog(@"Local Notification succeeded");
    //        }
    //        else {
    //            NSLog(@"Local Notification failed");
    //        }
    //    }];
}

-(void)applicationWillResignActive:(UIApplication *)application{
    [[FRSLocationManager sharedManager] pauseLocationMonitoring];
}

-(void)applicationDidBecomeActive:(UIApplication *)application{
    
    if ([[FRSAPIClient sharedClient] isAuthenticated] && !self.didPresentPermissionsRequest) {
        if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)) {
            [[FRSLocationManager sharedManager] startLocationMonitoringForeground];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FRSResetUpload" object:nil userInfo:@{@"type":@"reset"}];
}

-(void)applicationWillTerminate:(UIApplication *)application{
    
}

#pragma mark - Push Notifications



-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    [FRSTracker track:notificationsDisabled];
}



-(void)startNotificationTimer {
    if (!notificationTimer) {
        notificationTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(checkNotifications) userInfo:nil repeats:YES];
    }
}

-(void)stopNotificationTimer {
    if (notificationTimer) {
        [notificationTimer invalidate];
        notificationTimer = nil;
    }
}

-(void)checkNotifications {
    
    if (![[FRSAPIClient sharedClient] isAuthenticated]) {
        return;
    }
    
    [[FRSAPIClient sharedClient] getNotificationsWithCompletion:^(id responseObject, NSError *error) {
        if (error) {
            //soft fail
            return;
        }
        if (responseObject) {
            FRSTabBarController *tbc = (FRSTabBarController *)self.tabBarController;
            if ([tbc isKindOfClass:[FRSTabBarController class]]) {
                if ([[responseObject objectForKey:@"unseen_count"] integerValue] > 0) {
                    [tbc updateBellIcon:YES];
                } else {
                    [tbc updateUserIcon];
                }
            }
        }
    }];
}

#pragma mark - App Path

-(void)determineAppPath{
    
    NSString *versionString = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    NSArray *versionComps = [versionString componentsSeparatedByString:@"."];
    NSInteger firstVersionNum = [[versionComps firstObject] integerValue];
    
    /*
     Focus on this -- pull old persistance (however its managed) into new magical record / core data layer
     */
    if (firstVersionNum < 3){ // This is a legacy user from prior to the redesign and persistance layer
        [self configureCoreDataStack];
        
    }
    else if (firstVersionNum == 3){ // This is the current high level version number we are working with.
        [self configureCoreDataStack];
        
    }
    else { //We will eventually need this if our high level verison numbers increment, but for now, it will never get called.
        
    }
}

#pragma mark - Config

-(void)configureWindow{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor]; // used to be [UIColor whiteBackgroundColor];
    
    [self.window makeKeyAndVisible];
}

-(void)configureThirdPartyApplicationsWithOptions:(NSDictionary *)options{
    
}

-(void)configureCoreDataStack{
    
}


#pragma mark - Quick Actions

- (void)createItemsWithIcons {
    BOOL isAuthenticated = TRUE; // check keychain
    
    if (!isAuthenticated) {
        [UIApplication sharedApplication].shortcutItems = @[];
        return;
    }
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0){
        
        UIApplicationShortcutIcon *camera = [UIApplicationShortcutIcon iconWithTemplateImageName:@"quick-action-camera"];
        UIApplicationShortcutIcon *video = [UIApplicationShortcutIcon iconWithTemplateImageName:@"quick-action-video"];
        UIApplicationShortcutIcon *map = [UIApplicationShortcutIcon iconWithTemplateImageName:@"quick-action-map"];
        
        // create dynamic shortcut items
        UIMutableApplicationShortcutItem *item1 = [[UIMutableApplicationShortcutItem alloc]initWithType:takePhotoAction localizedTitle:@"Take photo" localizedSubtitle:@"" icon:camera userInfo:nil];
        
        UIMutableApplicationShortcutItem *item2 = [[UIMutableApplicationShortcutItem alloc]initWithType:takeVideoAction localizedTitle:@"Take video" localizedSubtitle:@"" icon:video userInfo:nil];
        
        UIMutableApplicationShortcutItem *item3 = [[UIMutableApplicationShortcutItem alloc]initWithType:assignmentsAction localizedTitle:@"Assignments" localizedSubtitle:@"" icon:map userInfo:nil];
        
        // add all items to an array
        NSArray *items = @[item1, item2, item3];
        
        // add the array to our app
        [UIApplication sharedApplication].shortcutItems = items;
    }
}


-(void)updateTabBarToUser {
    
    FRSTabBarController *frsTabBar = (FRSTabBarController *)self.tabBarController;
    [frsTabBar updateUserIcon];
    frsTabBar.dot.alpha = 0;
}

#pragma mark - Status Bar
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    CGPoint location = [[[event allTouches] anyObject] locationInView:[self window]];
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    if (CGRectContainsPoint(statusBarFrame, location)){
        [self statusBarTouchedAction];
    }
}

-(void)statusBarTouchedAction {
    [[NSNotificationCenter defaultCenter] postNotificationName:kStatusBarTappedNotification
                                                        object:nil];
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(nonnull NSString *)identifier completionHandler:(nonnull void (^)())completionHandler {
    // pass responsibility onto FRSFileUploadManager (will trigger completion handler when done with work needed)
    // [[FRSFileUploadManager sharedUploader] handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
}

-(void)error:(NSError *)error {
    if (!error) {
        FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"GALLERY LOAD ERROR" message:@"Unable to load gallery. Please try again later." actionTitle:@"TRY AGAIN" cancelTitle:@"CANCEL" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
        [alert show];
    }
    else if (error.code == -1009) {
        FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"CONNECTION ERROR" message:@"Unable to connect to the internet. Please check your connection and try again." actionTitle:@"TRY AGAIN" cancelTitle:@"CANCEL" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
        [alert show];
    }
    else {
        FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"GALLERY LOAD ERROR" message:@"This gallery could not be found, or does not exist." actionTitle:@"TRY AGAIN" cancelTitle:@"CANCEL" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
        [alert show];
    }
}

-(FRSStoryDetailViewController *)detailViewControllerWithStory:(FRSStory *)story {
    FRSStoryDetailViewController *detailView = [[FRSStoryDetailViewController alloc] initWithNibName:@"FRSStoryDetailViewController" bundle:[NSBundle mainBundle]];
    detailView.story = story;
    [detailView reloadData];
    return detailView;
}

-(void)popViewController {
    
}
-(void)segueHome {
    UITabBarController *tab = (UITabBarController *)self.tabBarController;
    tab.selectedIndex = 0;
    [tab.navigationController popViewControllerAnimated:TRUE];
}



@end
