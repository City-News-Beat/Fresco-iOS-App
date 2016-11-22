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

#import "FRSNavigationController.h"
#import "FRSAlertView.h"

@interface FRSBaseViewController : UIViewController <FRSAlertViewDelegate>

@property (nonatomic) BOOL hiddenTabBar;
@property (nonatomic) BOOL actionBarVisible;
@property (nonatomic) BOOL isPresented;

-(void)configureBackButtonAnimated:(BOOL)animated;

-(void)removeNavigationBarLine;

-(void)hideTabBarAnimated:(BOOL)animated;

-(void)showTabBarAnimated:(BOOL)animated;

-(void)popViewController;

-(void)shouldShowStatusBar:(BOOL)statusBar animated:(BOOL)animated;

-(void)logoutWithPop:(BOOL)pop;

/* DEEP LINKS */
-(void)segueToPhotosOfTheDay:(NSArray *)postIDs;
-(void)segueToTodayInNews:(NSArray *)galleryIDs;
-(void)segueToTaxInfo;
-(void)segueToIDInfo;
-(void)segueToGallery:(NSString *)galleryID;
-(void)segueToStory:(NSString *)storyID;
-(void)segueHome;
-(void)segueToUser:(NSString *)userID;
-(void)segueToPost:(NSString *)postID;
-(void)segueToAssignmentWithID:(NSString *)assignmentID;
-(void)segueToGlobalAssignmentWithID:(NSString *)assignmentID;
-(void)segueToCameraWithAssignmentID:(NSString *)assignmentID;
-(void)segueToDebitCard;

/* KEYBOARD */
-(void)configureDismissKeyboardGestureRecognizer;
-(void)dismissKeyboardFromView;

/* FRSAlertView */
-(void)presentGenericError;
-(void)checkStatusAndPresentPermissionsAlert:(id)delegate;

/* MODERATION */
-(void)checkSuspended;

/* SMOOCH */
-(void)presentSmooch;

@end
