//
//  FRSTableViewCell.m
//  Fresco
//
//  Created by Omar Elfanek on 1/8/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSTableViewCell.h"
#import "UIFont+Fresco.h"
#import "UIColor+Fresco.h"


@interface FRSTableViewCell()

@property (strong, nonatomic) UILabel *descriptionLabel;

@end

@implementation FRSTableViewCell


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self){
        
        if ([reuseIdentifier isEqualToString:@"default-cell"]){
            //            [self setupDefaultCell];
        }
        else if ([reuseIdentifier isEqualToString:@"profile-cell"]){
            //            [self setupProfileCell];
        }
        else {
            
        }
        
        self.descriptionLabel = [[UILabel alloc] init];
        self.descriptionLabel.textColor = [UIColor blackColor];
        self.descriptionLabel.font = [UIFont fontWithName:@"Arial" size:12];
        
        [self addSubview:self.descriptionLabel];
        
    }
    
    return self;
}


-(void)configureSocialCellWithTitle:(NSString *)title andTag:(NSInteger)tag{
    
    CGFloat leftPadding = 16;
    CGFloat rightPadding = 10;
    
    UILabel *label  = [[UILabel alloc] initWithFrame:CGRectMake(56, 0, [UIScreen mainScreen].bounds.size.width - (rightPadding+leftPadding) - 10, self.frame.size.height)];
    label.text = title;
    label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    label.textColor = [UIColor frescoDarkTextColor];
    [self addSubview:label];

    if (tag == 1){
        UIImageView *socialIV =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"twitter-icon-filled"]];
        socialIV.frame = CGRectMake(16, 10 ,24,24);
        [socialIV sizeToFit];
        [self addSubview:socialIV];
    } else if (tag == 2){
        UIImageView *socialIV =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"facebook-icon-filled"]];
        socialIV.frame = CGRectMake(16, 10 ,24,24);
        [socialIV sizeToFit];
        [self addSubview:socialIV];
    } else if (tag == 3){
        UIImageView *socialIV =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"google-icon-filled"]];
        socialIV.frame = CGRectMake(16, 10 ,24,24);
        [socialIV sizeToFit];
        [self addSubview:socialIV];
    }

 
}




-(void)configureAssignmentCell{
    self.tintColor = [UIColor clearColor];
    self.textLabel.text = @"ASSIGNMENT NOTIFICATIONS";
    self.textLabel.font = [UIFont notaBoldWithSize:15];
    self.detailTextLabel.text = @"We’ll tell you about paid photo ops nearby";
    self.detailTextLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    self.detailTextLabel.frame = CGRectMake(16, 36, self.bounds.size.width, 14);
    self.detailTextLabel.textColor = [UIColor frescoMediumTextColor];
    
    UISwitch *notificationSwitch = [[UISwitch alloc] init];
    notificationSwitch.center = self.center;
    notificationSwitch.center = CGPointMake([UIScreen mainScreen].bounds.size.width - notificationSwitch.bounds.size.width/2 - 13.5, notificationSwitch.bounds.size.height/2 + 14);
    [self addSubview:notificationSwitch];
    
    //    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 61, self.bounds.size.width, 1)];
    //    view.backgroundColor = [UIColor whiteColor];
    //    [self addSubview:view];
    
}


-(void)configureDefaultCellWithTitle:(NSString *)title andCarret:(BOOL)yes{
    
    
    CGFloat leftPadding = 16;
    CGFloat rightPadding = 10;
    
    UILabel *label  = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding, 0, [UIScreen mainScreen].bounds.size.width - (rightPadding+leftPadding) - 10, self.frame.size.height)];
    label.text = title;
    label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    label.textColor = [UIColor frescoDarkTextColor];
    [self addSubview:label];
    
    if (yes){
    UIImageView *carrotIV =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]];
    carrotIV.frame = CGRectMake(label.bounds.size.width +leftPadding, label.bounds.size.height/2 -7, 24, 24);
    [carrotIV sizeToFit];
    [self addSubview:carrotIV];
    }
    
}

-(void)configureDefaultCellWithTitle:(NSString *)title withSecondTitle:(NSString *)secondTitle{
    
    CGFloat leftPadding = 16;
    CGFloat rightPadding = 10;
    
    UILabel *label  = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding, 0, [UIScreen mainScreen].bounds.size.width - (rightPadding+leftPadding) - 10, self.frame.size.height)];
    label.text = title;
    label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    [self addSubview:label];
    
    UIImageView *carrotIV =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]];
    carrotIV.frame = CGRectMake(label.bounds.size.width +leftPadding, label.bounds.size.height/2 -7, 24, 24);
    [carrotIV sizeToFit];
    [self addSubview:carrotIV];
    
    UILabel *secondLabel  = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 130, 0, 100, self.frame.size.height)];
    secondLabel.textAlignment = NSTextAlignmentRight;
    secondLabel.text = secondTitle;
    secondLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    secondLabel.textColor = [UIColor frescoMediumTextColor];
    [self addSubview:secondLabel];
    
    //    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -1, self.bounds.size.width, 3)];
    //    view.backgroundColor = [UIColor whiteColor];
    //    [self addSubview:view];
    
}

-(void)configureCellWithUsername:(NSString *)username{
    
    CGFloat leftPadding = 16;
    CGFloat rightPadding = 10;
    
    UILabel *label  = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding, 0, [UIScreen mainScreen].bounds.size.width - (rightPadding+leftPadding),56)];
    label.text = username;
    label.font = [UIFont notaMediumWithSize:17];
    label.textColor = [UIColor frescoDarkTextColor];
    [self addSubview:label];
    
    UIImageView *carrotIV =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]];
    carrotIV.frame = CGRectMake(label.bounds.size.width+7, label.bounds.size.height/2 -7, 24, 24);
    [carrotIV sizeToFit];
    [self addSubview:carrotIV];
    
}

-(void)configureEmptyCellSpace{
    
    self.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

-(void)configureLogOut{
    
    
    UILabel *logOut = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 - 27, self.bounds.size.height/2 - 6, 54, 17)];
    logOut.text = @"LOG OUT";
    logOut.textColor = [UIColor frescoRedHeartColor];
    logOut.font = [UIFont notaBoldWithSize:15];
    [self addSubview:logOut];
    
}



@end
