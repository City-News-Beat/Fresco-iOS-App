//
//  FRSUserView.m
//  Fresco
//
//  Created by Omar Elfanek on 1/5/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSUserView.h"
#import <Haneke/Haneke.h>
#import "UIFont+Fresco.h"
#import "UIColor+Fresco.h"

@implementation FRSUserView

#define USERNAME_PADDING 8
#define STANDARD_PADDING 16
#define LABEL_LEFT_PADDING 72
#define BUTTON_SIZE 34
#define BUTTON_TOP_PADDING 21
#define NAME_LABEL_HEIGHT 22
#define BIO_RIGHT_PADDING 56
#define BIO_TOP_PADDING 34
#define NAME_TOP_PADDING 12

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

- (instancetype)initWithUser:(FRSUser *)user {
    self = [super init];
    if (self) {
        
        self.user = user;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userAvatarTapped)];
        [self addGestureRecognizer:tap];

        UIImageView *profileIV = [[UIImageView alloc] init];
        profileIV.frame = CGRectMake(STANDARD_PADDING, 13, 40, 40);
        profileIV.layer.cornerRadius = 20;
        profileIV.clipsToBounds = YES;

        NSURL *avatar = [NSURL URLWithString:user.profileImage];
        [profileIV hnk_setImageFromURL:avatar];
        
        profileIV.backgroundColor = [UIColor frescoLightTextColor];
        
        UIImageView *profileIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user-24"]];
        if (user.profileImage == nil || [user.profileImage isEqual:[NSNull null]] || [user.profileImage length] <= 0) {
            profileIcon.frame = CGRectMake(8, 8, 24, 24);
            profileIcon.userInteractionEnabled = NO;
            [profileIV addSubview:profileIcon];
        }

        [self addSubview:profileIV];

        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.text = user.firstName;
        nameLabel.font = [UIFont notaMediumWithSize:17];
        nameLabel.textColor = [UIColor frescoDarkTextColor];
        [nameLabel sizeToFit];
        nameLabel.frame = CGRectMake(LABEL_LEFT_PADDING, NAME_TOP_PADDING, nameLabel.frame.size.width, NAME_LABEL_HEIGHT);
        [self addSubview:nameLabel];

        UILabel *usernameLabel = [[UILabel alloc] init];
        usernameLabel.text = (user.username && ![user.username isEqual:[NSNull null]] && ![user.username isEqualToString:@""]) ? [@"@" stringByAppendingString:user.username] : @"";
        usernameLabel.font = [UIFont notaRegularWithSize:12];
        usernameLabel.textColor = [UIColor frescoMediumTextColor];
        [usernameLabel sizeToFit];
        usernameLabel.frame = CGRectMake(LABEL_LEFT_PADDING + USERNAME_PADDING + nameLabel.frame.size.width, 17, SCREEN_WIDTH - LABEL_LEFT_PADDING, 14);
        if (nameLabel.text == nil || [nameLabel.text isEqualToString:@""]) {
            usernameLabel.frame = CGRectMake(LABEL_LEFT_PADDING + nameLabel.frame.size.width, 17, SCREEN_WIDTH - LABEL_LEFT_PADDING, 14);
        }
        [self addSubview:usernameLabel];
        
        
        UILabel *bioLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - LABEL_LEFT_PADDING - BIO_RIGHT_PADDING, CGFLOAT_MAX)];
        bioLabel.text = user.bio;
        bioLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        bioLabel.textColor = [UIColor frescoMediumTextColor];
        bioLabel.numberOfLines = 0;
        [bioLabel sizeToFit];
        bioLabel.frame = CGRectMake(LABEL_LEFT_PADDING, BIO_TOP_PADDING, SCREEN_WIDTH - LABEL_LEFT_PADDING - BIO_RIGHT_PADDING, bioLabel.frame.size.height);
        [self addSubview:bioLabel];

        self.calculatedHeight = NAME_TOP_PADDING + BIO_TOP_PADDING + bioLabel.frame.size.height;

        self.followingButton = [[FRSFollowButton alloc] initWithDelegate:self user:user];
        self.followingButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - BUTTON_SIZE - STANDARD_PADDING, BUTTON_TOP_PADDING, BUTTON_SIZE, BUTTON_SIZE);
        [self addSubview:self.followingButton];
        
        [self.followingButton updateIconForFollowing:[user.following boolValue]];
        
        if (![user.profileImage isEqual:[NSNull null]] && user.profileImage != nil) {
            NSURL *avatarURL = [NSURL URLWithString:user.profileImage];
            [profileIV hnk_setImageFromURL:avatarURL];
            profileIcon.alpha = 0;
        }
        

        // Size bio label before setting calculated height
        if (user.bio && ![user.bio isEqual:[NSNull null]] && [[user.bio class] isSubclassOfClass:[NSString class]] && [user.bio length] > 0) {
            bioLabel.text = user.bio;
        } else {
            // Set text to an empty space to avoid overlapping UI when calling sizeToFit
            bioLabel.text = @" ";
        }
        
        [bioLabel sizeToFit];
        
        // Set calculatedHeight after all UI elements have been configured
        self.calculatedHeight = NAME_TOP_PADDING + BIO_TOP_PADDING + bioLabel.frame.size.height;
    }
    
    return self;
}

- (void)userAvatarTapped {
    if (self.delegate) {
        [self.delegate userAvatarTapped];
    }
}


@end
