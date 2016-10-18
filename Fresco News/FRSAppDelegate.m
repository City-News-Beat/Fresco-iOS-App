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

@implementation FRSAppDelegate
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator, managedObjectModel = _managedObjectModel, managedObjectContext = _managedObjectContext;

#pragma mark - Startup and Application States

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    if ([self isFirstRun]) {
        [self clearKeychain]; // clear tokens from past install
    }
    
    [self startMixpanel];
    [self configureWindow];
    [self startFabric]; // crashlytics first yall
    [self configureThirdPartyApplicationsWithOptions:launchOptions];
    [self persistentStoreCoordinator];
    
    [self configureCoreDataStack];
    
    if ([[FRSAPIClient sharedClient] isAuthenticated]) {
        self.tabBarController = [[FRSTabBarController alloc] init];
        self.window.rootViewController = self.tabBarController;
        [self createItemsWithIcons];
        [self reloadUser];
    }
    else {
        
        [self startAuthentication];
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        return YES; // no other stuff going on (no quick action handling, etc)
    }
    NSLog(@"OPTIONS %@", launchOptions);
    
    if (launchOptions[UIApplicationLaunchOptionsLocationKey]) {
        [self handleLocationUpdate];
    }
    if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
        NSLog(@"HANDLE PUSH (LOCAL)");
        [self handleLocalPush];
    }
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        NSLog(@"HANDLE PUSH (REMOTE)");
        [self handleRemotePush:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    if (launchOptions[UIApplicationLaunchOptionsShortcutItemKey]) {
        [self handleColdQuickAction:launchOptions[UIApplicationLaunchOptionsShortcutItemKey]];
    }
    
    [self registerForPushNotifications];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];

    

    //[self startNotificationTimer];
    
    
    return YES;
}

-(void)startMixpanel {
    [Mixpanel sharedInstanceWithToken:mixPanelToken];
    
    if ([[FRSAPIClient sharedClient] authenticatedUser]) {
        [[Mixpanel sharedInstance] identify:[[FRSAPIClient sharedClient] authenticatedUser].uid];
        FRSUser *user = [[FRSAPIClient sharedClient] authenticatedUser];
        [[[Mixpanel sharedInstance] people] set:@{@"fresco_id":user.uid}];
        
        if (user.firstName) {
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
        
        NSLog(@"MARK AS READ SUCCESS: %d", success);
    }];
}

-(void)reloadUser {
    [[FRSAPIClient sharedClient] refreshCurrentUser:^(id responseObject, NSError *error) {
        // check against existing user
        if (error || responseObject[@"error"]) {
            // throw up sign in
            
            return;
        }
        
        FRSUser *authenticatedUser = [[FRSAPIClient sharedClient] authenticatedUser];
        
        if (!authenticatedUser) {
            authenticatedUser = [NSEntityDescription insertNewObjectForEntityForName:@"FRSUser" inManagedObjectContext:[self managedObjectContext]];
        }
        
        // update user
        authenticatedUser.uid = responseObject[@"id"];
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
        
        
        if ([responseObject[@"terms"][@"valid"] boolValue] == FALSE) { /* */
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
        
        if (![responseObject[@"identity"] isKindOfClass:[[NSNull null] class]]) {
            
            if (responseObject[@"identity"][@"due_by"] != Nil && ![responseObject[@"identity"][@"due_by"] isEqual:[NSNull null]]) {
                [authenticatedUser setValue:responseObject[@"due_by"] forKey:@"due_by"];
            }
            
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
            [authenticatedUser setValue:fieldsNeeded forKey:@"fieldsNeeded"];
            [authenticatedUser setValue:@(hasSavedFields) forKey:@"hasSavedFields"];
            
            [[self managedObjectContext] save:Nil];
        }
    }];
}

-(BOOL)isValue:(id)value {
    if (value != Nil && ![value isEqual:[NSNull null]]) {
        return TRUE;
    }
    
    return FALSE;
}


-(void)clearKeychain {
    SAMKeychainQuery *query = [[SAMKeychainQuery alloc] init];
    
    NSArray *accounts = [query fetchAll:nil];
    
    for (id account in accounts) {
        
        SAMKeychainQuery *query = [[SAMKeychainQuery alloc] init];
        
        query.service = serviceName;
        query.account = [account valueForKey:@"acct"];
        
        [query deleteItem:nil];
    }
}

-(BOOL)isFirstRun {

    BOOL firstRun = ![[[NSUserDefaults standardUserDefaults] stringForKey:@"isFirstRun"] isEqualToString:@"Yeah It Totally Is"];
    [[NSUserDefaults standardUserDefaults] setObject:@"Yeah It Totally Is" forKey:@"isFirstRun"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return firstRun;
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
    
    [[FRSAPIClient sharedClient] searchWithQuery:@"bernie" completion:^(id responseObject, NSError *error) {
    }];
    
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

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
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
    return _tabBarController;
}

-(void)startAuthentication {
    _tabBarController = [[FRSTabBarController alloc] init];
    
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
    
    if (!self.tabBarController) { // sry we kinda need that
        return;
    }
    
    [self.tabBarController respondToQuickAction:shortcutItem.type]; // tab bar can handle change
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    
    if (!self.tabBarController) { // sry we kinda need that pal
        return;
    }
    
    [self.tabBarController respondToQuickAction:shortcutItem.type]; // tab bar can handle change
}

-(void)registerForPushNotifications {
    
    UIUserNotificationType types = (UIUserNotificationType) (UIUserNotificationTypeBadge |
                                                             UIUserNotificationTypeSound | UIUserNotificationTypeAlert);
    
    UIUserNotificationSettings *mySettings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    const unsigned *tokenData = [deviceToken bytes];
    NSString *newDeviceToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                                                  ntohl(tokenData[0]), ntohl(tokenData[1]), ntohl(tokenData[2]),
                                                  ntohl(tokenData[3]), ntohl(tokenData[4]), ntohl(tokenData[5]),
                                                  ntohl(tokenData[6]), ntohl(tokenData[7])];
    
    [[NSUserDefaults standardUserDefaults] setObject:newDeviceToken forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSDictionary *installationDigest = [[FRSAPIClient sharedClient] currentInstallation];
    
    [[FRSAPIClient sharedClient] updateUserWithDigestion:@{@"installation":installationDigest} completion:^(id responseObject, NSError *error) {
        NSLog(@"Updated user installation");
    }];
    
    [FRSTracker track:@"Notifications Enabled"];
}

-(void)handleLocationUpdate {
    
}

-(void)handleLocalPush {
    
}

-(void)handleRemotePush:(NSDictionary *)push {
    UIViewController *viewController = [[UIViewController alloc] init];
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 900)];
    [viewController.view addSubview:textView];
    
    NSString *instruction = push[@"type"];
    NSString *notificationID = push[@"id"];
    NSLog(@"PUSH %@", push);
    
    //
   // self.window.rootViewController = viewController;
    textView.text = push.description;
    
    if (notificationID && ![notificationID isEqual:[NSNull null]]) {
        [self markAsRead:notificationID];
    }
    
    // payment
    if ([instruction isEqualToString:purchasedContentNotification]) {
        NSString *gallery = [push objectForKey:@"gallery_id"];
        
        if (gallery && ![gallery isEqual:[NSNull null]] && [[gallery class] isSubclassOfClass:[NSString class]]) {
            [self segueToGallery:gallery];
        }
    }
    if ([instruction isEqualToString:paymentExpiringNotification]) {
        [self segueToDebitCard];
    }
    if ([instruction isEqualToString:paymentSentNotification]) {
        [self segueToDebitCard];
    }
    if ([instruction isEqualToString:taxInfoRequiredNotification]) {
        [self segueToTaxInfo];
    }
    if ([instruction isEqualToString:taxInfoDeclinedNotification]) {
        [self segueToTaxInfo];
    }
    if ([instruction isEqualToString:taxInfoProcessedNotification]) {
        [self segueToTaxInfo];
    }
    if ([instruction isEqualToString:paymentDeclinedNotification]) {
        [self segueToDebitCard];
    }
    
    // social
    if ([instruction isEqualToString:followedNotification]) {
        NSString *user = [[push objectForKey:@"user_ids"] firstObject];
        [self segueToUser:user];
    }
    if ([instruction isEqualToString:@"user-social-gallery-liked"]) {
        NSString *gallery = [push  objectForKey:@"gallery_id"];
        
        if (gallery && ![gallery isEqual:[NSNull null]] && [[gallery class] isSubclassOfClass:[NSString class]]) {
            [self segueToGallery:gallery];
        }
        else {
            NSString *story = [push objectForKey:@"story_id"];
            if (story && ![story isEqual:[NSNull null]] && [[story class] isSubclassOfClass:[NSString class]]) {
                [self segueToStory:story];
            }
        }
    }
    if ([instruction isEqualToString:repostedNotification]) {
        NSString *gallery = [[push objectForKey:@"gallery_ids"] firstObject];
        
        if (gallery && ![gallery isEqual:[NSNull null]] && [[gallery class] isSubclassOfClass:[NSString class]]) {
            [self segueToGallery:gallery];
        }
        else {
            NSString *story = [[push objectForKey:@"meta"] objectForKey:@"story_id"];
            if (story && ![story isEqual:[NSNull null]] && [[story class] isSubclassOfClass:[NSString class]]) {
                [self segueToStory:story];
            }
        }
    }
    if ([instruction isEqualToString:commentedNotification]) {
        NSString *gallery = [[push objectForKey:@"gallery_ids"] firstObject];
        
        if (gallery && ![gallery isEqual:[NSNull null]] && [[gallery class] isSubclassOfClass:[NSString class]]) {
            [self segueToGallery:gallery];
        }
    }
    
    // general
    if ([instruction isEqualToString:photoOfDayNotification]) {
        NSString *gallery = [[push objectForKey:@"gallery_ids"] firstObject];
        
        if (gallery && ![gallery isEqual:[NSNull null]] && [[gallery class] isSubclassOfClass:[NSString class]]) {
            [self segueToGallery:gallery];
        }
    }
    if ([instruction isEqualToString:todayInNewsNotification]) {
        NSArray *galleryIDs = [push objectForKey:@"gallery_ids"];
        [self segueToTodayInNews:galleryIDs];

    }
}

-(void)applicationDidEnterBackground:(UIApplication *)application {
    
}

-(void)applicationWillResignActive:(UIApplication *)application{
    [[FRSLocationManager sharedManager] pauseLocationMonitoring];
}

-(void)applicationDidBecomeActive:(UIApplication *)application{
    
}

-(void)applicationWillTerminate:(UIApplication *)application{

}

#pragma mark - Push Notifications

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSLog(@"NOTIF: %@", userInfo);

    //untested, unable to receive remote notifs atm
    FRSTabBarController *tbc = (FRSTabBarController *)self.window.rootViewController;
    [tbc updateBellIcon:YES];
    completionHandler(TRUE);
    
    if([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive)
    {
        [self handleRemotePush:userInfo];
    }
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo {
    NSLog(@"NOTIF: %@", userInfo);
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    [FRSTracker track:@"Permissions notification disables"];
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"NOTIF LOCAL: %@", notification);

}

-(void)startNotificationTimer {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(checkNotifications) userInfo:nil repeats:YES];
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
            FRSTabBarController *tbc = (FRSTabBarController *)self.window.rootViewController;
            if ([[responseObject objectForKey:@"unseen_count"] integerValue] > 0) {
                
                [tbc updateBellIcon:YES];
            } else {
                [tbc updateUserIcon];
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


// DEEP LINKING
-(void)segueToPhotosOfTheDay:(NSArray *)postIDs {
    //Not part of the initial 3.0 release
}

-(void)segueToTodayInNews:(NSArray *)galleryIDs {
    __block BOOL isSegueingToStory;

    NSMutableArray *galleryArray = [[NSMutableArray alloc] init];
    
    for (NSString *gallery in galleryIDs) {
        
        [[FRSAPIClient sharedClient] getGalleryWithUID:gallery completion:^(id responseObject, NSError *error) {
            UITabBarController *tab = (UITabBarController *)self.tabBarController;
            
            if (![galleryArray containsObject:responseObject]) {
                [galleryArray addObject:(FRSGallery *)responseObject];
            }
            
            if (galleryArray.count == galleryIDs.count) {
                if (!isSegueingToStory) {
                    isSegueingToStory = YES;
                    FRSStoryDetailViewController *detailVC = [[FRSStoryDetailViewController alloc] init];
                    [detailVC configureWithGalleries:galleryArray];
                    detailVC.navigationController = tab.navigationController;
                    detailVC.title = @"TODAY IN NEWS";
                    [tab.navigationController pushViewController:detailVC animated:YES];
                }
            }
        }];
    }
}


-(void)segueToGallery:(NSString *)galleryID {
    __block BOOL isPushingGallery = FALSE;
    
    [[FRSAPIClient sharedClient] getGalleryWithUID:galleryID completion:^(id responseObject, NSError *error) {
        
        if (isPushingGallery) {
            return;
        }
        
        isPushingGallery = TRUE;
        
        FRSAppDelegate *appDelegate = self;
        FRSGallery *galleryToSave = [NSEntityDescription insertNewObjectForEntityForName:@"FRSGallery" inManagedObjectContext:[appDelegate managedObjectContext]];
        
        [galleryToSave configureWithDictionary:responseObject context:[appDelegate managedObjectContext]];
        
        FRSGalleryExpandedViewController *vc = [[FRSGalleryExpandedViewController alloc] initWithGallery:galleryToSave];
        vc.shouldHaveBackButton = YES;
        
        
        UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
        
        if ([[navController class] isSubclassOfClass:[UINavigationController class]]) {
            [navController pushViewController:vc animated:TRUE];
        }
        else {
            UITabBarController *tab = (UITabBarController *)navController;
            tab.navigationController.interactivePopGestureRecognizer.enabled = YES;
            tab.navigationController.interactivePopGestureRecognizer.delegate = nil;
            
            navController = (UINavigationController *)[[tab viewControllers] firstObject];
            [navController pushViewController:vc animated:TRUE];
        }
    }];
}

-(void)segueToStory:(NSString *)storyID {
    UITabBarController *tab = (UITabBarController *)self.tabBarController;
    __block BOOL isSegueingToStory;

    [[FRSAPIClient sharedClient] getStoryWithUID:storyID completion:^(id responseObject, NSError *error) {
        
        FRSAppDelegate *appDelegate = self;
        FRSStory *story = [NSEntityDescription insertNewObjectForEntityForName:@"FRSStory" inManagedObjectContext:[appDelegate managedObjectContext]];
        
        [story configureWithDictionary:responseObject];
        
        FRSStoryDetailViewController *detailView = [self detailViewControllerWithStory:story];
        detailView.navigationController = tab.navigationController;
        
        if (isSegueingToStory) {
            isSegueingToStory = YES;
            [tab.navigationController pushViewController:detailView animated:YES];
        }
    }];
}

-(FRSStoryDetailViewController *)detailViewControllerWithStory:(FRSStory *)story {
    FRSStoryDetailViewController *detailView = [[FRSStoryDetailViewController alloc] initWithNibName:@"FRSStoryDetailViewController" bundle:[NSBundle mainBundle]];
    detailView.story = story;
    [detailView reloadData];
    return detailView;
}

-(void)segueToUser:(NSString *)userID {
    UITabBarController *tab = (UITabBarController *)self.tabBarController;

    FRSProfileViewController *profileVC = [[FRSProfileViewController alloc] initWithUserID:userID];
    [tab.navigationController pushViewController:profileVC animated:YES];
}

-(void)segueToPost:(NSString *)postID {

    [[FRSAPIClient sharedClient] getPostWithID:postID completion:^(id responseObject, NSError *error) {
        
        [self segueToGallery:[[responseObject objectForKey:@"parent"] objectForKey:@"id"]];
        
    }];
}

-(void)segueToAssignmentWithID:(NSString *)assignmentID {
    UITabBarController *tab = (UITabBarController *)self.tabBarController;

    FRSNavigationController *navCont = (FRSNavigationController *)[tab.viewControllers objectAtIndex:3];
    FRSAssignmentsViewController *assignmentsVC = (FRSAssignmentsViewController *)[navCont.viewControllers objectAtIndex:0];
    
    assignmentsVC.hasDefault = YES;
    assignmentsVC.defaultID = assignmentID;
    [self.tabBarController setSelectedIndex:3];
    
    [self performSelector:@selector(popViewController) withObject:nil afterDelay:0.3];
    
    if (assignmentsVC.mapView) {
        [[FRSAPIClient sharedClient] getAssignmentWithUID:assignmentID completion:^(id responseObject, NSError *error) {
            
            FRSAppDelegate *appDelegate = self;
            FRSAssignment *assignment = [NSEntityDescription insertNewObjectForEntityForName:@"FRSAssignment" inManagedObjectContext:[appDelegate managedObjectContext]];
            [assignment configureWithDictionary:responseObject];
            [assignmentsVC focusOnAssignment:assignment];
            
        }];
    }
}


-(void)segueToCameraWithAssignmentID:(NSString *)assignmentID {
    UITabBarController *tab = (UITabBarController *)self.tabBarController;

    [[FRSAPIClient sharedClient] getAssignmentWithUID:assignmentID completion:^(id responseObject, NSError *error) {
        
        NSDictionary *assDict = [[NSDictionary alloc] init];
        assDict = responseObject;
        
        FRSCameraViewController *cam = [[FRSCameraViewController alloc] initWithCaptureMode:FRSCaptureModeVideo selectedAssignment:assDict selectedGlobalAssignment:nil];
        UINavigationController *navControl = [[UINavigationController alloc] init];
        navControl.navigationBar.barTintColor = [UIColor frescoOrangeColor];
        [navControl pushViewController:cam animated:NO];
        [navControl setNavigationBarHidden:YES];
        
        [tab presentViewController:navControl animated:YES completion:nil];
    }];
}

-(void)segueHome {
    UITabBarController *tab = (UITabBarController *)self.tabBarController;
    tab.selectedIndex = 0;
    [tab.navigationController popViewControllerAnimated:TRUE];
}

-(void)segueToDebitCard {
    UITabBarController *tab = (UITabBarController *)self.tabBarController;

    FRSDebitCardViewController *debitCardVC = [[FRSDebitCardViewController alloc] init];
    [tab.navigationController pushViewController:debitCardVC animated:YES];
}

-(void)segueToTaxInfo {
    UITabBarController *tab = (UITabBarController *)self.tabBarController;

    FRSTaxInformationViewController *taxVC = [[FRSTaxInformationViewController alloc] init];
    [tab.navigationController pushViewController:taxVC animated:YES];
}

-(void)segueToIDInfo {
    UITabBarController *tab = (UITabBarController *)self.tabBarController;

    FRSIdentityViewController *identityVC = [[FRSIdentityViewController alloc] init];
    [tab.navigationController pushViewController:identityVC animated:YES];
    
}

@end
