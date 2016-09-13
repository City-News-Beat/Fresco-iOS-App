//
//  FRSTabBarController.h
//  Fresco
//
//  Created by Daniel Sun on 12/18/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSTabBarController : UITabBarController


@property (nonatomic) NSInteger lastActiveIndex;

- (void)returnToGalleryPost;

//- (void)presentCameraForCaptureMode:(FRSCaptureMode)captureMode;

- (void)presentAssignments;
-(void)setIrisItemColor:(UIColor *)color;
-(void)handleNotification:(NSDictionary *)notification;
-(void)respondToQuickAction:(NSString *)quickAction;
-(void)openGalleryID:(NSString *)galleryID;
-(void)openStoryID:(NSString *)storyID;
-(void)openUserID:(NSString *)userID;
-(void)openGalleryIDS:(NSArray *)galleryIDS;
-(void)openAssignmentID:(NSString *)assignmentID;
-(void)updateBellIcon:(BOOL)unread;
-(void)updateUserIcon;
@property (strong, nonatomic) UIView *dot;

@end
