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

#import <MagicalRecord/MagicalRecord.h>

@implementation FRSAppDelegate


#pragma mark - Startup and Application States

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    [self configureWindow];
    [self configureThirdPartyApplicationsWithOptions:launchOptions];
    [self configureCoreDataStack];
    
    
    self.window.rootViewController = [[FRSTabBarController alloc] init];
//    self.window.rootViewController = [[FRSOnboardingViewController alloc] init];
    
    
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

#pragma mark - Config

-(void)configureWindow{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteBackgroundColor];
    [self.window makeKeyAndVisible];
}

-(void)configureThirdPartyApplicationsWithOptions:(NSDictionary *)options{
    
}

-(void)configureCoreDataStack{
    [MagicalRecord setupAutoMigratingCoreDataStack];
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelVerbose];
}



@end
