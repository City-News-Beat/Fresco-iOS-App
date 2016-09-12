//
//  FRSDefaultNotificationTableViewCell.m
//  Fresco
//
//  Created by Omar Elfanek on 8/10/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSDefaultNotificationTableViewCell.h"
#import "UIColor+Fresco.h"
#import "FRSProfileViewController.h"
#import "FRSAPIClient.h"
#import <Haneke/Haneke.h>

@interface FRSDefaultNotificationTableViewCell ()


@property (weak, nonatomic) IBOutlet UIView *line;
@property (nonatomic) NSInteger generatedHeight;

@end

@implementation FRSDefaultNotificationTableViewCell

-(void)configureCellForType:(NSString *)cellType userID:(NSString *)userID assignmentID:(NSString *)assignmentID postID:(NSString *)postID storyID:(NSString *)storyID galleryID:(NSString *)galleryID {
    
    if ([cellType isEqualToString:@"user-social-followed"]) {
        [self configureUserFollowNotificationWithID:userID];
    } else if ([cellType isEqualToString:@""]) {
        return;
    }
}

-(void)setUserImage:(NSString *)userID {
    [[FRSAPIClient sharedClient] getUserWithUID:userID completion:^(id responseObject, NSError *error) {
        self.titleLabel.text = [responseObject objectForKey:@"full_name"];
        
        if([responseObject objectForKey:@"avatar"] != [NSNull null]){
            NSURL *avatarURL = [NSURL URLWithString:[responseObject objectForKey:@"avatar"]];
            [self.image hnk_setImageFromURL:avatarURL];
        }
        
        [self updateLabelsForCount];
    }];
}

-(void)configureUserRepostNotificationWithUserID:(NSString *)userID galleryID:(NSString *)galleryID {
    
    [self configureDefaultCellWithAttributesForNotification:FRSNotificationTypeRepost];
    [self setUserImage:userID];
    self.followButton.alpha = 0;
    self.annotationView.alpha = 0;
}

-(void)configureUserLikeNotificationWithUserID:(NSString *)userID galleryID:(NSString *)galleryID {
    
    [self configureDefaultCellWithAttributesForNotification:FRSNotificationTypeLike];
    [self setUserImage:userID];
    self.followButton.alpha = 0;
    self.annotationView.alpha = 0;
}

-(void)configureUserCommentNotificationWithUserID:(NSString *)userID commentID:(NSString *)commentID {
    
    [self configureDefaultCellWithAttributesForNotification:FRSNotificationTypeComment];
    [self setUserImage:userID];
    self.followButton.alpha = 0;
    self.annotationView.alpha = 0;
}

-(void)configureUserMentionCommentNotificationWithUserID:(NSString *)userID commentID:(NSString *)commentID {
    [self configureDefaultCellWithAttributesForNotification:FRSNotificationTypeCommentMention];
    [self setUserImage:userID];
    self.followButton.alpha = 0;
    self.annotationView.alpha = 0;
}


-(void)configureUserMentionGalleryNotificationWithUserID:(NSString *)userID galleryID:(NSString *)galleryID {
    [self configureDefaultCellWithAttributesForNotification:FRSNotificationTypeGalleryMention];
    [self setUserImage:userID];
    self.followButton.alpha = 0;
    self.annotationView.alpha = 0;
}

-(void)configurePhotoPurchasedWithPostID:(NSString *)postID outletID:(NSString *)outletID price:(NSString *)price paymentMethod:(NSString *)paymentMethod {
    self.titleLabel.text = @"Your photo was purchased!";
    
    [[FRSAPIClient sharedClient] getOutletWithID:outletID completion:^(id responseObject, NSError *error) {
        
    }];
    
    [[FRSAPIClient sharedClient] getPostWithID:postID completion:^(id responseObject, NSError *error) {
        
        if([responseObject objectForKey:@"image"] != [NSNull null]){
            
            NSURL *avatarURL = [NSURL URLWithString:[responseObject objectForKey:@"image"]];
            [self.image hnk_setImageFromURL:avatarURL];
        }
    }];
    
    //if user has payment method
    self.bodyLabel.text = [NSString stringWithFormat:@"%@ purchased your photo! We've sent %@ to your %@.", outletID, price, paymentMethod];
    
    //else if user does not have payment method
    self.bodyLabel.text = [NSString stringWithFormat:@"%@ purchased your photo! Tap to add a card and we’ll send you %@!", outletID, price];
}


-(void)configureVideoPurchasedWithPostID:(NSString *)postID outletID:(NSString *)outletID price:(NSString *)price paymentMethod:(NSString *)paymentMethod {
    self.titleLabel.text = @"Your video was purchased!";
    
    [[FRSAPIClient sharedClient] getOutletWithID:outletID completion:^(id responseObject, NSError *error) {
        
    }];
    
    [[FRSAPIClient sharedClient] getPostWithID:postID completion:^(id responseObject, NSError *error) {
        
        if([responseObject objectForKey:@"image"] != [NSNull null]){
            
            NSURL *avatarURL = [NSURL URLWithString:[responseObject objectForKey:@"image"]];
            [self.image hnk_setImageFromURL:avatarURL];
        }
    }];
    
    //if user has payment method
    self.bodyLabel.text = [NSString stringWithFormat:@"%@ purchased your video! We've sent %@ to your %@.", outletID, price, paymentMethod];
    
    //else if user does not have payment method
//    self.bodyLabel.text = [NSString stringWithFormat:@"%@ purchased your video! Tap to add a card and we’ll send you %@!", outletID, price];
}


-(void)configureUserFollowNotificationWithID:(NSString *)userID {
    
    [self configureDefaultCellWithAttributesForNotification:FRSNotificationTypeFollow];
    
    self.followButton.alpha = 1;
    self.followButton.tintColor = [UIColor blackColor];
    
    [[FRSAPIClient sharedClient] getUserWithUID:userID completion:^(id responseObject, NSError *error) {
        
        self.titleLabel.text = [responseObject objectForKey:@"full_name"];
         
        if([responseObject objectForKey:@"avatar"] != [NSNull null]){
            NSURL *avatarURL = [NSURL URLWithString:[responseObject objectForKey:@"avatar"]];
            [self.image hnk_setImageFromURL:avatarURL];
        }
        
        if ([[responseObject objectForKey:@"following"] boolValue]) {
            [self.followButton setImage:[UIImage imageNamed:@"account-check"] forState:UIControlStateNormal];
            self.followButton.tintColor = [UIColor frescoOrangeColor];
        } else {
            [self.followButton setImage:[UIImage imageNamed:@"account-add"] forState:UIControlStateNormal];
            self.followButton.tintColor = [UIColor blackColor];
        }
        
        [self updateLabelsForCount];
        
    }];
}

-(IBAction)followTapped:(id)sender {
    if ([self.followButton.imageView.image isEqual:[UIImage imageNamed:@"account-check"]]) {
        [self.followButton setImage:[UIImage imageNamed:@"account-add"] forState:UIControlStateNormal];
        self.followButton.tintColor = [UIColor blackColor];
    } else if ([self.followButton.imageView.image isEqual: [UIImage imageNamed:@"account-add"]]) {
        [self.followButton setImage:[UIImage imageNamed:@"account-check"] forState:UIControlStateNormal];
        self.followButton.tintColor = [UIColor frescoOrangeColor];
    }
}

-(void)configureFeaturedStoryCellWithStoryID:(NSString *)storyID {
    
    [self configureDefaultCell];
    self.annotationView.alpha = 0;
    
    [[FRSAPIClient sharedClient] getStoryWithUID:storyID completion:^(id responseObject, NSError *error) {
        
        self.titleLabel.text = [NSString stringWithFormat:@"Featured Story: %@", [responseObject objectForKey:@"title"]];
        self.bodyLabel.text = [responseObject objectForKey:@"caption"];
        self.bodyLabel.numberOfLines = 3;
        self.titleLabel.numberOfLines = 2;
        
        if([responseObject objectForKey:@"thumbnails"] != [NSNull null]){
            NSURL *avatarURL = [NSURL URLWithString:[[[responseObject objectForKey:@"thumbnails"] objectAtIndex:0] objectForKey:@"image"]];
            [self.image hnk_setImageFromURL:avatarURL];
        }
    }];
}



#pragma mark - Helpers
-(void)configureDefaultCell {
    self.image.backgroundColor = [UIColor frescoLightTextColor];
    self.image.layer.cornerRadius = 20;
    self.image.clipsToBounds = YES;
    self.followButton.alpha = 0;
    self.annotationView.layer.cornerRadius = 12;
    self.annotationView.alpha = 0;
}

-(void)configureDefaultCellWithAttributesForNotification:(FRSNotificationType)notificationType {
    
    [self configureDefaultCell];
    
    //Set bodyLabel based on notifcation type
    switch (notificationType) {
        case FRSNotificationTypeFollow:
            self.bodyLabel.text = @"Followed you.";
            break;
        case FRSNotificationTypeLike:
            self.bodyLabel.text = @"Liked your gallery.";
            break;
        case FRSNotificationTypeRepost:
            self.bodyLabel.text = @"Reposted your gallery.";
            break;
        case FRSNotificationTypeComment:
            self.bodyLabel.text = @"Commented on your gallery.";
            break;
        case FRSNotificationTypeGalleryMention:
            self.bodyLabel.text = @"Mentioned you in a gallery.";
            break;
        case FRSNotificationTypeCommentMention:
            self.bodyLabel.text = @"Mentioned you in a comment.";
            break;
            
        default:
            break;
    }
    
    if (self.count <= 1) {
        self.annotationView.alpha = 0;
        self.annotationLabel.alpha = 0;
    }
}


-(NSInteger)heightForCell {
    
    if (_generatedHeight) {
        return _generatedHeight;
    }
    
    NSInteger height = 0;
    
    int topPadding   = 10;
    int leftPadding  = 72;
    int rightPadding = 16;
    
    self.titleLabel.font = [UIFont notaMediumWithSize:17];
    self.titleLabel.numberOfLines = 1;
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = CGRectMake(leftPadding, topPadding, self.frame.size.width -leftPadding -rightPadding, 22);

    topPadding = 33;
    self.bodyLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.bodyLabel.numberOfLines = 3;
    
    [self.bodyLabel sizeToFit];
    [self.titleLabel sizeToFit];
    
    height += self.bodyLabel.frame.size.height;
    height += self.titleLabel.frame.size.height;
    height += 8; //spacing

    return height;
}



-(void)updateLabelsForCount {
    if (self.count > 1) {
        //Update labels based on count
        if (self.count <= 1) {
            self.annotationView.alpha = 0;
        } else if (self.count <= 9) {
            self.titleLabel.text = [NSString stringWithFormat:@"%@ + %ld others", self.titleLabel.text, self.count-1];
            self.annotationLabel.text = [NSString stringWithFormat:@"+%ld", self.count];
        } else {
            self.annotationLabel.text = @"+";
        }
    }
}

#pragma mark - UITableViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
}

-(void)prepareForReuse {
    [super prepareForReuse];
    self.titleLabel = nil;
    self.bodyLabel = nil;
    self.image = nil;
    self.followButton = nil;
    self.annotationView = nil;
    self.annotationLabel = nil;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    //UITableViewCell subviews' background colors turn to clearColor when selecting/highlighting.
    //Setting the background color overrides this
    self.annotationView.backgroundColor = [UIColor whiteColor];
    self.line.backgroundColor = [UIColor frescoLightTextColor];
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    //UITableViewCell subviews' background colors turn to clearColor when selecting/highlighting.
    //Setting the background color overrides this
    self.annotationView.backgroundColor = [UIColor whiteColor];
    self.line.backgroundColor = [UIColor frescoLightTextColor];
}











@end
