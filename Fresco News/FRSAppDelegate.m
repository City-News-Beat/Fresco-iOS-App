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





#import "FRSSignUpViewController.h"
#import "FRSSetupProfileViewController.h"
#import "TempViewController.h"
#import "ViewController.h"

#import <MagicalRecord/MagicalRecord.h>

@implementation FRSAppDelegate


#pragma mark - Startup and Application States

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    [self configureWindow];
    [self configureThirdPartyApplicationsWithOptions:launchOptions];
    
//    [self determineAppPath];
//    self.window.rootViewController = [[FRSTabBarController alloc] init];
    
    self.window.rootViewController = [[FRSNavigationController alloc] initWithRootViewController:[[ViewController alloc] init]];
    
    return YES;
}

-(void)applicationDidEnterBackground:(UIApplication *)application{
    
}

-(void)applicationWillResignActive:(UIApplication *)application{
    
}

-(void)applicationDidBecomeActive:(UIApplication *)application{
    
}

-(void)applicationWillTerminate:(UIApplication *)application{
    [MagicalRecord cleanUp];
}

#pragma mark - Push Notifications

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
}

#pragma mark - App Path

-(void)determineAppPath{

    NSString *versionString = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    NSArray *versionComps = [versionString componentsSeparatedByString:@"."];
    NSInteger firstVersionNum = [[versionComps firstObject] integerValue];
    
    if (firstVersionNum < 3){ //This is a legacy user from prior to the redesign and persistance layer
        [self configureCoreDataStack];
        
    }
    else if (firstVersionNum == 3){ //This is the current high level version number we are working with.
        [self configureCoreDataStack];
        
        
    }
    else { //We will eventually need this if our high level verison numbers increment, but for now, it will never get called.
        
    }
    
    
}


#pragma mark - Config

-(void)configureWindow{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
}

-(void)configureThirdPartyApplicationsWithOptions:(NSDictionary *)options{
    
}

-(void)configureCoreDataStack{
    [MagicalRecord setupAutoMigratingCoreDataStack];
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelVerbose];
}



@end
