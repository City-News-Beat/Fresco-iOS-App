//
//  AppDelegate.h
//  FrescoNews
//
//  Created by Jason Gresh on 3/2/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)setRootViewControllerToTabBar;
- (void)setRootViewControllerToFirstRun;
- (void)registerForPushNotifications;

@end
