//
//  FRSBaseViewController.h
//  Fresco
//
//  Created by Daniel Sun on 1/6/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"
#import "UIView+Helpers.h"

#import "UILabel+Custom.h"

@interface FRSBaseViewController : UIViewController

@property (nonatomic) BOOL hiddenTabBar;
@property (nonatomic) BOOL actionBarVisible;
@property (nonatomic) BOOL isPresented;

-(void)configureBackButtonAnimated:(BOOL)animated;

-(void)configureNavigationBar;

-(void)removeNavigationBarLine;

-(void)hideTabBarAnimated:(BOOL)animated;

-(void)showTabBarAnimated:(BOOL)animated;

-(void)popViewController;

@end
