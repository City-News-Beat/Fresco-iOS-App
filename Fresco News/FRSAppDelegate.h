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

@interface FRSAppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate, UNUserNotificationCenterDelegate> {
    NSTimer *notificationTimer;
}

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) id tabBarController;
@property BOOL didPresentPermissionsRequest;

- (void)saveContext;
- (UITabBarController *)tabBar;
- (BOOL)isFirstRun;
- (void)updateTabBarToUser;
- (void)clearKeychain;
- (void)restartUpload;
- (void)startNotificationTimer;
- (void)stopNotificationTimer;
- (void)registerForPushNotifications;

@end
