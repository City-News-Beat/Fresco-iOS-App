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
@interface FRSAppDelegate (Implement)

@end
@implementation FRSAppDelegate
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator, managedObjectModel = _managedObjectModel, managedObjectContext = _managedObjectContext;

#pragma mark - Startup and Application States

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    [self configureWindow];
    [self configureThirdPartyApplicationsWithOptions:launchOptions];
    [self persistentStoreCoordinator];
    
    [self configureCoreDataStack];
    [self createItemsWithIcons];
    
    [self startFabric];
 
    if ([[FRSAPIClient sharedClient] isAuthenticated] || TRUE) {
        self.window.rootViewController = [[FRSTabBarController alloc] init];
    }
    else {
        [self startAuthentication];
        return YES; // no other stuff going on (no quick action handling, etc)
    }

    if (launchOptions[UIApplicationLaunchOptionsLocationKey]) {
        [self handleLocationUpdate];
    }
    if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
        [self handleLocalPush];
    }
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [self handleRemotePush];
    }
    if (launchOptions[UIApplicationLaunchOptionsShortcutItemKey]) {
        [self handleColdQuickAction:launchOptions[UIApplicationLaunchOptionsShortcutItemKey]];
    }
    
    [self registerForPushNotifications];
    
    
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor frescoOrangeColor]];
    [[UINavigationBar appearance] setTranslucent:NO];
    
    return YES;
}

-(void)startFabric {
    [[Twitter sharedInstance] startWithConsumerKey:@"LuzgKf2eus1EGzxf2CyEtFJCJ" consumerSecret:@"kxlgOYo7SdgvLsHDUwUo90DkCbooDMbHQyDCayNSgD7oeUUUjT"];
    
    [Fabric with:@[[Twitter class], [Crashlytics class]]];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
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
        abort();
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


-(void)startAuthentication {
    
    FRSNavigationController *mainNav = [[FRSNavigationController alloc] init];
    [mainNav pushViewController:[[FRSOnboardingViewController alloc] init] animated:FALSE];
    [mainNav setNavigationBarHidden:YES];
    self.window.rootViewController = mainNav;
}

-(BOOL)isAuthenticated {
    
    // check against keychian
    
    return FALSE;
}

// when the app isn't open
-(void)handleColdQuickAction:(UIApplicationShortcutItem *)shortcutItem {
    
    if ([shortcutItem.type isEqualToString:takeVideoAction]) {
        // load video view
    }
    else if ([shortcutItem.type isEqualToString:takePhotoAction]) {
        // load photo view
    }
    else if ([shortcutItem.type isEqualToString:assignmentsAction]) {
        // load assignments view
    }

}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    
    if ([shortcutItem.type isEqualToString:takeVideoAction]) {
        // load video view
    }
    else if ([shortcutItem.type isEqualToString:takePhotoAction]) {
        // load photo view
    }
    else if ([shortcutItem.type isEqualToString:assignmentsAction]) {
        // load assignments view
    }
}

-(void)registerForPushNotifications {
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]) {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
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
    
    NSLog(@"%@", newDeviceToken);
    
}

-(void)handleLocationUpdate {
    
}

-(void)handleLocalPush {
    
}

-(void)handleRemotePush {
    
}

-(void)applicationDidEnterBackground:(UIApplication *)application{
    
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
    
    completionHandler(TRUE);
    
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
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


@end
