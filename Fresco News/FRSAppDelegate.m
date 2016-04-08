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
#import <MagicalRecord/MagicalRecord.h>
#import <CoreLocation/CoreLocation.h>
#import "FRSLoginViewController.h"
#import "FRSAPIClient.h"
#import "VideoTrimmerViewController.h"

#import "Fresco.h"
@interface FRSAppDelegate (Implement)

@end
@implementation FRSAppDelegate


#pragma mark - Startup and Application States

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    [self configureWindow];
    [self configureThirdPartyApplicationsWithOptions:launchOptions];
    
    [self configureCoreDataStack];
    [self createItemsWithIcons];
    
    if ([[FRSAPIClient sharedClient] isAuthenticated] || TRUE) {
        self.window.rootViewController = [[VideoTrimmerViewController alloc] init];
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
    
    return YES;
}

-(void)startAuthentication {
    self.window.rootViewController = [[FRSOnboardingViewController alloc] init];
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
    [MagicalRecord cleanUp];
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
    [MagicalRecord setupCoreDataStack];
    //[MagicalRecord setupAutoMigratingCoreDataStack];
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
