//
//  FRSUserTableViewCell.m
//  Fresco
//
//  Created by Daniel Sun on 2/9/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUserTableViewCell.h"

#import "FRSUser.h"

#import "UILabel+Custom.h"
#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"
#import "UIView+Helpers.h"

#import <Haneke/Haneke.h>
@interface FRSUserTableViewCell()

@property (strong, nonatomic) UIImageView *profileIV;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) UIButton *followButton;
@property (strong, nonatomic) UIView *bottomLine;

@end

@implementation FRSUserTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        
        self.profileIV = [[UIImageView alloc] init];
        self.profileIV.contentMode = UIViewContentModeScaleAspectFill;
        self.profileIV.clipsToBounds = YES;
        [self addSubview:self.profileIV];
        
        self.nameLabel = [UILabel labelWithText:@"" textColor:[UIColor frescoDarkTextColor] font:[UIFont notaMediumWithSize:17]];
        [self addSubview:self.nameLabel];
        
        self.usernameLabel = [UILabel labelWithText:@"" textColor:[UIColor frescoMediumTextColor] font:[UIFont notaRegularWithSize:13]];
        [self addSubview:self.usernameLabel];
        
        self.followButton = [[UIButton alloc] init];
        [self.followButton addTarget:self action:@selector(toggleFollowButton) forControlEvents:UIControlEventTouchUpInside];
        self.followButton.contentMode = UIViewContentModeCenter;
        [self addSubview:self.followButton];
        
        self.bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0.5)];
        self.bottomLine.backgroundColor = [UIColor frescoShadowColor];
        [self addSubview:self.bottomLine];
    };
    return self;
}

-(void)clearCell{
    self.profileIV.image = nil;
    self.nameLabel.text = nil;
    self.usernameLabel.text = nil;
    self.followButton.imageView.image = nil;
}

-(void)toggleFollowButton{
    [[FRSAPIClient sharedClient] followUser:self.user completion:^(id responseObject, NSError *error) {
        [self.followButton setSelected:!self.followButton.selected];
        if(self.followButton.selected){
            NSLog(@"FOLLOWED USER: %d %@", (error == Nil), self.user.uid);
        }else{
            NSLog(@"UNFOLLOWED USER: %d %@", (error == Nil), self.user.uid);
        }
    }];
}

-(void)configureCellWithUser:(FRSUser *)user isFollowing:(BOOL)followingUser{
    self.user = user;
    
    CGRect newFrame = self.frame;
    newFrame.size.height = self.cellHeight;
    [self setFrame:newFrame];
    
    self.profileIV.frame = CGRectMake(16, 12, 32, 32);
    self.profileIV.layer.cornerRadius = 32/2;
    
    if(user.profileImage){
        [self.profileIV hnk_setImageFromURL:[NSURL URLWithString:user.profileImage]];
    }else{
        self.profileIV.image = [UIImage imageNamed:@"kobe"];
    }
    
    if(user.firstName){
        self.nameLabel.text = [NSString stringWithFormat:@"%@", user.firstName];
    }else{
        self.nameLabel.text = @"Kobe Bryant";
    }
    
    [self.nameLabel sizeToFit];
    [self.nameLabel centerVerticallyInView:self];
    [self.nameLabel setFrame:CGRectMake(64, self.nameLabel.frame.origin.y, self.nameLabel.frame.size.width, self.nameLabel.frame.size.height)];
    //CHECK FOR RELEASE we need to set a max width
    
    if(user.username.length > 0){
        self.usernameLabel.text = [NSString stringWithFormat:@"@%@", user.username];
    }else{
        self.usernameLabel.text = @"@theblackmamba";
    }
    
    [self.usernameLabel sizeToFit];
    [self.usernameLabel centerVerticallyInView:self];
    [self.usernameLabel setFrame:CGRectMake(self.nameLabel.frame.size.width + self.nameLabel.frame.origin.x + 8, self.usernameLabel.frame.origin.y, self.usernameLabel.frame.size.width, self.usernameLabel.frame.size.height)];
    NSLog(@"Width %f",self.frame.size.width);
    NSLog(@"X %f",self.frame.origin.x);
    self.followButton.frame = CGRectMake(self.frame.size.width - 40, 16, 24, 24);

    [self.followButton setImage:[UIImage imageNamed:@"add-follower"] forState:UIControlStateNormal];
    [self.followButton setImage:[UIImage imageNamed:@"already-following"] forState:UIControlStateSelected];
    [self.followButton setSelected:followingUser];
    
    self.bottomLine.frame = CGRectMake(0, self.frame.size.height - 1, self.bottomLine.frame.size.width, 1);\
}









@end
