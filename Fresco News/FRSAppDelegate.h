//
//  FRSAppDelegate.h
//  Fresco
//
//  Created by Daniel Sun on 12/18/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import <Crashlytics/Crashlytics.h>
#import <Smooch/Smooch.h>
#import <UserNotifications/UserNotifications.h>
#import <UserNotifications/UserNotifications.h>
#import "Adjust.h"
#import "FRSCoreDataController.h"

@interface FRSAppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate, UNUserNotificationCenterDelegate> {
    NSTimer *notificationTimer;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FRSCoreDataController *coreDataController;
@property (nonatomic, retain) id tabBarController;
@property BOOL didPresentPermissionsRequest;

- (void)saveContext;
- (UITabBarController *)tabBar;
- (void)updateTabBarToUser;
- (void)clearKeychain;
- (void)restartUpload;
- (void)startNotificationTimer;
- (void)stopNotificationTimer;
- (void)registerForPushNotifications;



/**
 Returns the managed object context from FRSCoreDataController

 @return NSManagedObjectContext from FRSCoreDataController
 */
- (NSManagedObjectContext *)managedObjectContext;
@end
