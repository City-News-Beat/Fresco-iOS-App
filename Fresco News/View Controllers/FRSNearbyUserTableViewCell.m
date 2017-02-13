//
//  FRSNearbyUserTableViewCell.m
//  Fresco
//
//  Created by User on 2/12/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSNearbyUserTableViewCell.h"
#import "Haneke.h"
#import "FRSUserManager.h"
#import "FRSFollowManager.h"

@interface FRSNearbyUserTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *bioLabel;

@end

@implementation FRSNearbyUserTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)loadDataWithUser:(FRSUser *)user {
    [super loadDataWithUser:user];
    dispatch_async(dispatch_get_main_queue(), ^{
      self.bioLabel.text = (user.bio && ![user.bio isEqual:[NSNull null]] && ![user.bio isEqualToString:@""]) ? user.bio : @"";
    });
}

//- (IBAction)didToggleFollow:(id)sender {
//    if (self.following) {
//        [[FRSFollowManager sharedInstance] unfollowUser:self.user
//                                             completion:^(id responseObject, NSError *error) {
//                                               if (error) {
//                                                   return;
//                                               }
//                                               self.following = NO;
//                                               [self updateFollowButton:self.following];
//
//                                             }];
//    } else {
//        [[FRSFollowManager sharedInstance] followUser:self.user
//                                           completion:^(id responseObject, NSError *error) {
//                                             if (error) {
//                                                 return;
//                                             }
//                                             self.following = YES;
//                                             [self updateFollowButton:self.following];
//                                           }];
//    }
//}

@end
