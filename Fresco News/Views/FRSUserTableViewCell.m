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

@interface FRSUserTableViewCell()

@property (strong, nonatomic) UIImageView *profileIV;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) UIImageView *accessoryIV;

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
        self.profileIV.layer.cornerRadius = 32/2;
        [self addSubview:self.profileIV];
        
        self.nameLabel = [UILabel labelWithText:@"" textColor:[UIColor frescoDarkTextColor] font:[UIFont notaMediumWithSize:17]];
        [self addSubview:self.nameLabel];
        
        self.usernameLabel = [UILabel labelWithText:@"" textColor:[UIColor frescoMediumTextColor] font:[UIFont notaRegularWithSize:13]];
        [self addSubview:self.usernameLabel];
        
        self.accessoryIV = [[UIImageView alloc] init];
        self.accessoryIV.contentMode = UIViewContentModeCenter;
        [self addSubview:self.accessoryIV];
    }
    return self;
}

-(void)clearCell{
    self.profileIV.image = nil;
    self.nameLabel.text = nil;
    self.usernameLabel.text = nil;
    self.accessoryIV.image = nil;
}

-(void)configureCellWithUser:(FRSUser *)user{
    self.profileIV.frame = CGRectMake(16, 12, 32, 32);
    self.profileIV.image = [UIImage imageNamed:@"kobe"];
    
    self.nameLabel.text = @"Kobe Bryant";
    [self.nameLabel sizeToFit];
    [self.nameLabel centerVerticallyInView:self];
    [self.nameLabel setFrame:CGRectMake(64, self.nameLabel.frame.origin.y, self.nameLabel.frame.size.width, self.nameLabel.frame.size.height)];
    //CHECK FOR RELEASE we need to set a max width
    
    self.usernameLabel.text = @"@theblackmamba";
    [self.usernameLabel sizeToFit];
    [self.usernameLabel centerVerticallyInView:self];
    [self.nameLabel setFrame:CGRectMake(self.nameLabel.frame.size.width + self.nameLabel.frame.origin.x + 8, self.usernameLabel.frame.origin.y, self.usernameLabel.frame.size.width, self.usernameLabel.frame.size.height)];
    
    self.accessoryIV.image =
}









@end
