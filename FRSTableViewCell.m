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

@end

@implementation FRSTableViewCell

-(void)configureSocialCellWithTitle:(NSString *)title andTag:(NSInteger)tag{
    
    CGFloat leftPadding = 16;
    CGFloat rightPadding = 10;
    
    UILabel *label  = [[UILabel alloc] initWithFrame:CGRectMake(56, 0, [UIScreen mainScreen].bounds.size.width - (rightPadding+leftPadding) - 10, self.frame.size.height)];
    label.text = title;
//    label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
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
    UILabel *textLabel = [UILabel new];
    textLabel.frame = CGRectMake(16, 15, 185, 17);
    textLabel.text = @"ASSIGNMENT NOTIFICATIONS";
    textLabel.font = [UIFont notaBoldWithSize:15];
    [self addSubview:textLabel];
    
    UILabel *detailTextLabel = [UILabel new];
    detailTextLabel.text = @"We’ll tell you about paid photo ops nearby";
    detailTextLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    detailTextLabel.frame = CGRectMake(16, 35, self.bounds.size.width, 14);
    detailTextLabel.textColor = [UIColor frescoMediumTextColor];
    [self addSubview:detailTextLabel];
    
    UISwitch *notificationSwitch = [[UISwitch alloc] init];
    notificationSwitch.center = self.center;
    notificationSwitch.center = CGPointMake([UIScreen mainScreen].bounds.size.width - notificationSwitch.bounds.size.width/2 - 13.5, notificationSwitch.bounds.size.height/2 + 14);
    [self addSubview:notificationSwitch];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 61, self.bounds.size.width, 1)];
    view.backgroundColor = [UIColor whiteColor];
    [self addSubview:view];
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
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0.5)];
    view.backgroundColor = [UIColor frescoLightTextColor];
    [self addSubview:view];

}

-(void)configureLogOut{
    
    UILabel *logOut = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 - 27, self.bounds.size.height/2 - 6, 54, 17)];
    logOut.text = @"LOG OUT";
    logOut.textColor = [UIColor frescoRedHeartColor];
    logOut.font = [UIFont notaBoldWithSize:15];
    [self addSubview:logOut];
    
}

-(void)configureEmptyCellSpace:(BOOL)yes{

    self.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(yes){
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 12, self.bounds.size.width, 1)];
    view.backgroundColor = [UIColor frescoBackgroundColorDark];
    [self addSubview:view];
    }
}

@end