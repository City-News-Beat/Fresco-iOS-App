//
//  FRSUserTableViewCell.h
//  Fresco
//
//  Created by User on 2/11/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FRSUser;

static NSString *const userCellIdentifier = @"user-cell";
static CGFloat const userCellHeight = 56;

@interface FRSUserTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIButton *followButton;

@property (nonatomic, strong) FRSUser *user;
@property (nonatomic) BOOL following;

- (void)loadDataWithUser:(FRSUser *)user;

@end
