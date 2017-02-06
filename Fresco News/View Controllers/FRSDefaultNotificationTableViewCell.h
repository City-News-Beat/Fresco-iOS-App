//
//  FRSDefaultNotificationTableViewCell.h
//  Fresco
//
//  Created by Omar Elfanek on 8/10/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FRSDefaultNotificationCellDelegate <NSObject>

- (void)customButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;

@end

typedef NS_ENUM(NSUInteger, FRSNotificationType) {
    
    /* Social */
    FRSNotificationTypeFollow,
    FRSNotificationTypeLike,
    FRSNotificationTypeRepost,
    FRSNotificationTypeComment,
    FRSNotificationTypeGalleryMention,
    FRSNotificationTypeCommentMention
    
    /* News */
    
    /* Dispatch */
    
    /* Payment */
    
    /* Promo */
};

@interface FRSDefaultNotificationTableViewCell : UITableViewCell

@property (nonatomic, retain) id<FRSDefaultNotificationCellDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;

/* SOCIAL */
- (void)configureUserFollowNotificationWithID:(NSString *)userID;
- (void)configureUserLikeNotificationWithUserID:(NSString *)userID galleryID:(NSString *)galleryID;
- (void)configureFeaturedStoryCellWithStoryID:(NSString *)storyID;
- (void)configureAssignmentCellWithID:(NSString *)assignmentID;
- (void)configureUserRepostNotificationWithUserID:(NSString *)userID galleryID:(NSString *)galleryID;
- (void)configureUserCommentNotificationWithUserID:(NSString *)userID commentID:(NSString *)commentID;
- (void)configureUserMentionCommentNotificationWithUserID:(NSString *)userID commentID:(NSString *)commentID;
- (void)configureUserMentionGalleryNotificationWithUserID:(NSString *)userID galleryID:(NSString *)galleryID;

/* PAYMENT */
- (void)configurePhotoPurchasedWithPostID:(NSString *)postID outletID:(NSString *)outletID price:(NSString *)price paymentMethod:(NSString *)paymentMethod;
- (void)configureVideoPurchasedWithPostID:(NSString *)postID outletID:(NSString *)outletID price:(NSString *)price paymentMethod:(NSString *)paymentMethod;

- (void)configureCellForType:(NSString *)cellType userID:(NSString *)userID;
- (NSInteger)heightForCell;

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

/* HELPERS */
- (void)configureDefaultCell;
- (void)configureDefaultCellWithAttributesForNotification:(FRSNotificationType)notificationType;
- (void)updateLabelsForCount;
- (void)configureImageCell;
@end
