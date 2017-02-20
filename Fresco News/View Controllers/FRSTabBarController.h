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

- (void)returnToGalleryPost;
- (void)presentAssignments;
- (void)setIrisItemColor:(UIColor *)color;
- (void)handleNotification:(NSDictionary *)notification;
- (void)respondToQuickAction:(NSString *)quickAction;
- (void)openGalleryID:(NSString *)galleryID;
- (void)openStoryID:(NSString *)storyID;
- (void)openUserID:(NSString *)userID;
- (void)openGalleryIDS:(NSArray *)galleryIDS;
- (void)openAssignmentID:(NSString *)assignmentID;
//- (void)updateBellIcon:(BOOL)unread;
- (void)updateUserIcon;
- (void)updateBellIcon;
//@property (strong, nonatomic) UIView *dot;

- (void)configureViewControllersWithNotif:(BOOL)notif;

/**
 This method changes both the image and the selected item on a tab bar item.

 @param index NSInteger index of the tab bar item to change.
 @param imageName NSString name of the image.
 @param selectedImageName NSString name of the selected image.
 */
- (void)updateTabBarIconAtIndex:(NSInteger)index withImageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName;

@end
