//
//  FRSNavigationController.h
//  Fresco
//
//  Created by Daniel Sun on 12/22/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FRSTabbedNavigationTitleView;

@interface FRSNavigationController : UINavigationController

@property (nonatomic) BOOL shouldHaveTabbedBar;
@property (nonatomic) BOOL shouldHaveBackButton;

@property (strong, nonatomic) UIView *titleView;

-(void)configureFRSNavigationBarWithTitle:(NSString *)title;
-(void)configureFRSNavigationBarWithTabs:(NSArray *)tabs;

@end
