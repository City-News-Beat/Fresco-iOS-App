//
//  SwitchingRootViewController.h
//  FrescoNews
//
//  Created by Jason Gresh on 6/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TabBarController;

@interface SwitchingRootViewController : UIViewController

@property (strong, nonatomic) TabBarController *tbc;

- (void)setRootViewControllerToTabBar;
- (void)setRootViewControllerToFirstRun;

@end
