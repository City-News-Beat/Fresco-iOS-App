//
//  FRSDefaultNotificationTableViewCell.h
//  Fresco
//
//  Created by Omar Elfanek on 8/10/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSDefaultNotificationTableViewCell : UITableViewCell

typedef NS_ENUM(NSUInteger, FRSNotificationType) {
    
    /* Social */
    FRSNotificationTypeFollow,
    FRSNotificationTypeLike,
    FRSNotificationTypeRepost,
    FRSNotificationTypeComment
    
    /* News */
    
    /* Dispatch */
    
    /* Payment */
    
    /* Promo */
};

-(void)configureCell;

-(void)configureUserNotificationWithID:(NSString *)notificationID;
-(void)configureLikedContentNotificationWithUserID:(NSString *)userID galleryID:(NSString *)galleryID;
-(void)configureFeaturedStoryCellWithStoryID:(NSString *)storyID;

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *annotationLabel;
@property (weak, nonatomic) IBOutlet UIView *annotationView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTopConstraint;
@property (strong, nonatomic) UIColor *backgroundViewColor;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bodyLabelLeftConstraint;

@property (nonatomic) NSInteger count;

@end
