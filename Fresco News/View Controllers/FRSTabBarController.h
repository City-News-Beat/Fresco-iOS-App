//
//  FRSTabBarController.h
//  Fresco
//
//  Created by Daniel Sun on 12/18/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSAlertView.h"

@interface FRSTabBarController : UITabBarController <FRSAlertViewDelegate>

@property (nonatomic) NSInteger lastActiveIndex;

- (void)setIrisItemColor:(UIColor *)color;
- (void)respondToQuickAction:(NSString *)quickAction;
- (void)configureViewControllersWithNotif:(BOOL)notif;

/**
 This method changes both the image and the selected item on a tab bar item.

 @param index NSInteger index of the tab bar item to change.
 @param imageName NSString name of the image.
 @param selectedImageName NSString name of the selected image.
 */
- (void)updateTabBarIconAtIndex:(NSInteger)index withImageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName;


/**
 Shows or hides the user notification bell.

 @param bell BOOL to show the user icon or the bell icon.
 */
- (void)showBell:(BOOL)bell;

@end
