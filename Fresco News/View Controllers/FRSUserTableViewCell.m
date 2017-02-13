//
//  FRSUserTableViewCell.m
//  Fresco
//
//  Created by User on 2/11/17.
//  Copyright © 2017 Fresco. All rights reserved.
//
#import "FRSUserTableViewCell.h"
#import "Haneke.h"
#import "FRSUserManager.h"
#import "FRSFollowManager.h"

@interface FRSUserTableViewCell ()

@end

@implementation FRSUserTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.profileImageView.layer.cornerRadius = 16;
    self.profileImageView.layer.masksToBounds = YES;
}

- (void)loadDataWithUser:(FRSUser *)user {
    self.user = user;
    self.following = [user.following boolValue];

    NSURL *avatarURL;
    if (user.profileImage || ![user.profileImage isEqual:[NSNull null]]) {
        avatarURL = [NSURL URLWithString:user.profileImage];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.profileImageView hnk_setImageFromURL:avatarURL placeholder:[UIImage imageNamed:@"user-24"]];
      if (avatarURL) {
          [self.profileImageView setContentMode:UIViewContentModeScaleAspectFill];

      } else {
          [self.profileImageView setContentMode:UIViewContentModeCenter];
      }
      self.usernameLabel.text = (user.username && ![user.username isEqual:[NSNull null]] && ![user.username isEqualToString:@""]) ? [@"@" stringByAppendingString:user.username] : @"";
      self.nameLabel.text = user.firstName;

      [self updateFollowButton:self.following];

      if (user.uid && [[FRSUserManager sharedInstance] authenticatedUser].uid && [user.uid isEqualToString:[[FRSUserManager sharedInstance] authenticatedUser].uid]) {
          self.followButton.hidden = YES;
      } else {
          self.followButton.hidden = NO;
      }
    });
}

- (void)updateFollowButton:(BOOL)isFollowing {
    if (isFollowing) {
        [self.followButton setImage:[UIImage imageNamed:@"account-check"] forState:UIControlStateNormal];
        self.followButton.tintColor = [UIColor frescoOrangeColor];
    } else {
        [self.followButton setImage:[UIImage imageNamed:@"account-add"] forState:UIControlStateNormal];
        self.followButton.tintColor = [UIColor blackColor];
    }
}

- (IBAction)didToggleFollow:(id)sender {
    if (self.following) {
        [[FRSFollowManager sharedInstance] unfollowUser:self.user
                                             completion:^(id responseObject, NSError *error) {
                                               if (error) {
                                                   return;
                                               }
                                               self.following = NO;
                                               [self updateFollowButton:self.following];

                                             }];
    } else {
        [[FRSFollowManager sharedInstance] followUser:self.user
                                           completion:^(id responseObject, NSError *error) {
                                             if (error) {
                                                 return;
                                             }
                                             self.following = YES;
                                             [self updateFollowButton:self.following];
                                           }];
    }
}

@end
