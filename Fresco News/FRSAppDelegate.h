//
//  FRSAppDelegate.h
//  Fresco
//
//  Created by Daniel Sun on 12/18/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <UserNotifications/UserNotifications.h>
#import "FRSCoreDataController.h"
#import "FRSAlertView.h"

// quick actions -- app delegate
static NSString *const assignmentsAction = @"FRSAssignmentsAction";
static NSString *const takeVideoAction = @"FRSVideoAction";
static NSString *const takePhotoAction = @"FRSPhotoAction";

@interface FRSAppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate, UNUserNotificationCenterDelegate> {
    NSTimer *notificationTimer;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FRSCoreDataController *coreDataController;
@property (nonatomic, strong) FRSAlertView *errorAlertView;
@property (nonatomic, retain) id tabBarController;
@property BOOL didPresentPermissionsRequest;
@property BOOL isPresentingError;

- (void)saveContext;
- (UITabBarController *)tabBar;
- (void)updateTabBarToUser;
- (void)startNotificationTimer;
- (void)stopNotificationTimer;
- (void)registerForPushNotifications;

/**
 Returns the managed object context from FRSCoreDataController

 @return NSManagedObjectContext from FRSCoreDataController
 */
- (NSManagedObjectContext *)managedObjectContext;

/**
 Presents error on window

 @param error Error to display
 @param title Title of alert view
 */
- (void)presentError:(NSError *)error withTitle:(NSString *)title;

@end
