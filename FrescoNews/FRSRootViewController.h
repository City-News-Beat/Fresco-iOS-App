//
//  SwitchingRootViewController.h
//  FrescoNews
//
//  Created by Fresco News on 6/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FRSTabBarController;

@interface FRSRootViewController : UIViewController

@property (strong, nonatomic) FRSTabBarController *tbc;

@property (weak, nonatomic) UIViewController *viewController;

- (void)setRootViewControllerToTabBar;

- (void)setRootViewControllerToFirstRun;

- (void)setRootViewControllerToOnboard;

- (void)setRootViewControllerToCamera;

- (void)hideTabBar;

- (void)showTabBar;

@end