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
#import "MKMapView+Additions.h"
#import "UIView+Helpers.h"

@interface FRSTableViewCell()

@property CGFloat leftPadding;
@property CGFloat rightPadding;

@property (strong, nonatomic) UILabel *socialTitleLabel;
@property (strong, nonatomic) UIImageView *twitterIV;
@property (strong, nonatomic) UIImageView *facebookIV;
@property (strong, nonatomic) UIImageView *googleIV;

@property (strong, nonatomic) UILabel *assignmentNotificationsLabel;
@property (strong, nonatomic) UILabel *assignmentNotificationsDetailLabel;
@property (strong, nonatomic) UISwitch *notificationSwitch;
@property (strong, nonatomic) UIView *assignmentHideDividerView;

@property (strong, nonatomic) UILabel *defaultTitleLabel;
@property (strong, nonatomic) UILabel *rightAlignedDefaultTitleLabel;
@property (strong, nonatomic) UIImageView *carrotIV;

@property (strong, nonatomic) UIImageView *dynamicCircle;
@property (strong, nonatomic) UILabel *dynamicTitle;

@property (strong, nonatomic) UILabel *usernameTitleLabel;

@property (strong, nonatomic) UILabel *logOutLabel;

@property (strong, nonatomic) UITextField *textField;

@property (strong, nonatomic) UIButton *rightAlignedButton;

@property (strong, nonatomic) UILabel *disableAccountTitleLabel;
@property (strong, nonatomic) UILabel *disableAccountSubtitleLabel;
@property (strong, nonatomic) UIImageView *sadEmojiIV;


@end

@implementation FRSTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        
        self.leftPadding = 16;
        self.rightPadding = 10;
        
        
        //        if ([reuseIdentifier isEqualToString:@"username-cell"]){
        //
        //        } else if ([reuseIdentifier isEqualToString:@"email-cell"]){
        //
        //        } else if ([reuseIdentifier isEqualToString:@"update-password-cell"]){
        //
        //        } else if ([reuseIdentifier isEqualToString:@"assignment-notifications-cell"]){
        //
        //        } else if ([reuseIdentifier isEqualToString:@"notification-radius-cell"]){
        //
        //        } else if ([reuseIdentifier isEqualToString:@"debit-card-cell"]){
        //
        //        } else if ([reuseIdentifier isEqualToString:@"tax-cell"]){
        //
        //        } else if ([reuseIdentifier isEqualToString:@"twitter-cell"]){
        //
        //        } else if ([reuseIdentifier isEqualToString:@"facebook-cell"]){
        //
        //        } else if ([reuseIdentifier isEqualToString:@"google-cell"]){
        //
        //        } else if ([reuseIdentifier isEqualToString:@"promo-codes-cell"]){
        //
        //        } else if ([reuseIdentifier isEqualToString:@"logout-cell"]){
        //
        //        } else if ([reuseIdentifier isEqualToString:@"email-support-cell"]){
        //
        //        } else if ([reuseIdentifier isEqualToString:@"disable-account-cell"]){
        //
        //        }
        //    }
    }
    
    return self;
}

-(void)configureSocialCellWithTitle:(NSString *)title andTag:(NSInteger)tag{
    
    self.socialTitleLabel  = [[UILabel alloc] initWithFrame:CGRectMake(56, 0, [UIScreen mainScreen].bounds.size.width - (self.rightPadding+self.leftPadding) - 10, self.frame.size.height)];
    self.socialTitleLabel.text = title;
    self.socialTitleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.socialTitleLabel.textColor = [UIColor frescoDarkTextColor];
    [self addSubview:self.socialTitleLabel];
    
    if (tag == 1){
        self.twitterIV =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"twitter-icon-filled"]];
        self.twitterIV.frame = CGRectMake(16, 10 ,24,24);
        [self.twitterIV sizeToFit];
        [self addSubview:self.twitterIV];
    } else if (tag == 2){
        self.facebookIV =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"facebook-icon-filled"]];
        self.facebookIV.frame = CGRectMake(16, 10 ,24,24);
        [self.facebookIV sizeToFit];
        [self addSubview:self.facebookIV];
    } else if (tag == 3){
        self.googleIV =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"google-icon-filled"]];
        self.googleIV.frame = CGRectMake(16, 10 ,24,24);
        [self.googleIV sizeToFit];
        [self addSubview:self.googleIV];
    }
}

-(void)configureAssignmentCell{
    
    self.assignmentNotificationsLabel = [UILabel new];
    self.assignmentNotificationsLabel.frame = CGRectMake(16, 15, 185, 17);
    self.assignmentNotificationsLabel.text = @"ASSIGNMENT NOTIFICATIONS";
    self.assignmentNotificationsLabel.font = [UIFont notaBoldWithSize:15];
    [self addSubview:self.assignmentNotificationsLabel];
    
    self.assignmentNotificationsDetailLabel = [UILabel new];
    self.assignmentNotificationsDetailLabel.text = @"We’ll tell you about paid photo ops nearby";
    self.assignmentNotificationsDetailLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    self.assignmentNotificationsDetailLabel.frame = CGRectMake(16, 35, self.bounds.size.width, 14);
    self.assignmentNotificationsDetailLabel.textColor = [UIColor frescoMediumTextColor];
    [self addSubview:self.assignmentNotificationsDetailLabel];
    
    self.notificationSwitch = [[UISwitch alloc] init];
    self.notificationSwitch.center = self.center;
    self.notificationSwitch.center = CGPointMake([UIScreen mainScreen].bounds.size.width - self.notificationSwitch.bounds.size.width/2 - 13.5, self.notificationSwitch.bounds.size.height/2 + 14);
    [self addSubview:self.notificationSwitch];
    
    self.assignmentHideDividerView = [[UIView alloc] initWithFrame:CGRectMake(0, 61, self.bounds.size.width, 1)];
    self.assignmentHideDividerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.assignmentHideDividerView];
}


-(void)configureDefaultCellWithTitle:(NSString *)title andCarret:(BOOL)yes andRightAlignedTitle:(NSString *)secondTitle{
    
    self.defaultTitleLabel  = [[UILabel alloc] initWithFrame:CGRectMake(self.leftPadding, 0, [UIScreen mainScreen].bounds.size.width - (self.rightPadding + self.leftPadding) - 10, self.frame.size.height)];
    self.defaultTitleLabel.text = title;
    self.defaultTitleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.defaultTitleLabel.textColor = [UIColor frescoDarkTextColor];
    [self addSubview:self.defaultTitleLabel];
    
    self.rightAlignedDefaultTitleLabel  = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 130, 0, 100, self.frame.size.height)];
    self.rightAlignedDefaultTitleLabel.textAlignment = NSTextAlignmentRight;
    self.rightAlignedDefaultTitleLabel.text = secondTitle;
    self.rightAlignedDefaultTitleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.rightAlignedDefaultTitleLabel.textColor = [UIColor frescoMediumTextColor];
    [self addSubview:self.rightAlignedDefaultTitleLabel];
    
    if (yes){
        self.carrotIV =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]];
        self.carrotIV.frame = CGRectMake(self.defaultTitleLabel.bounds.size.width + self.leftPadding, self.defaultTitleLabel.bounds.size.height/2 -7, 24, 24);
        [self.carrotIV sizeToFit];
        [self addSubview:self.carrotIV];
    }
}

-(void)configureCellWithUsername:(NSString *)username{
    
    CGFloat leftPadding = 16;
    CGFloat rightPadding = 10;
    
    self.usernameTitleLabel  = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding, 0, [UIScreen mainScreen].bounds.size.width - (rightPadding+leftPadding),56)];
    self.usernameTitleLabel.text = username;
    self.usernameTitleLabel.font = [UIFont notaMediumWithSize:17];
    self.usernameTitleLabel.textColor = [UIColor frescoDarkTextColor];
    [self addSubview:self.usernameTitleLabel];
    
    self.carrotIV =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]];
    self.carrotIV.frame = CGRectMake(self.usernameTitleLabel.bounds.size.width+7, self.usernameTitleLabel.bounds.size.height/2 -7, 24, 24);
    [self.carrotIV sizeToFit];
    [self addSubview:self.carrotIV];
    
}

-(void)configureLogOut{
    
    self.logOutLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 - 27, self.bounds.size.height/2 - 6, 54, 17)];
    self.logOutLabel.text = @"LOG OUT";
    self.logOutLabel.textColor = [UIColor frescoRedHeartColor];
    self.logOutLabel.font = [UIFont notaBoldWithSize:15];
    [self addSubview:self.logOutLabel];
    
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

-(void)configureEditableCellWithDefaultText:(NSString *)string withTopSeperator:(BOOL)topSeperator withBottomSeperator:(BOOL)bottomSeperator isSecure:(BOOL)secure withKeyboardType:(UIKeyboardType)keyboardType{
    
    self.textField  = [[UITextField alloc] initWithFrame:CGRectMake(self.leftPadding, 0, [UIScreen mainScreen].bounds.size.width - (self.self.rightPadding+self.leftPadding),44)];
    self.textField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.textField.placeholder = string;
    self.textField.delegate = self;
    self.textField.textColor = [UIColor frescoDarkTextColor];
    self.textField.tintColor = [UIColor frescoBlueColor];
    [self addSubview:self.textField];
    
    self.textField.keyboardType = keyboardType;
    
    if (topSeperator) {
        UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0.5)];
        top.alpha = 0.2;
        top.backgroundColor = [UIColor frescoDarkTextColor];
        [self addSubview:top];
    }
    
    if (bottomSeperator){
        UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.bounds.size.width, 0.5)];
        bottom.alpha = 0.2;
        bottom.backgroundColor = [UIColor frescoDarkTextColor];
        [self addSubview:bottom];
    }
    
    if(secure){
        self.textField.secureTextEntry = YES;
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 40;
}

-(void)configureCellWithRightAlignedButtonTitle:(NSString *)title withWidth:(CGFloat)width withColor:(UIColor *)color{
    self.backgroundColor = [UIColor clearColor];
    self.rightAlignedButton = [[UIButton alloc] initWithFrame: CGRectMake(self.frame.size.width - width, 0, width, self.frame.size.height)];
    [self.rightAlignedButton setTitle:title forState:UIControlStateNormal];
    [self.rightAlignedButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    [self.rightAlignedButton setTitleColor:color forState:UIControlStateNormal];
    [self addSubview:self.rightAlignedButton];
}


-(void)configureCheckBoxCellWithTitle:(NSString *)title withTopSeperator:(BOOL)topSeperator withBottomSeperator:(BOOL)bottomSeperator isSelected:(BOOL)isSelected{
    
    self.dynamicTitle  = [[UILabel alloc] initWithFrame:CGRectMake(self.leftPadding, 0, [UIScreen mainScreen].bounds.size.width - (self.rightPadding + self.leftPadding) - 10, self.frame.size.height)];
    self.dynamicTitle.text = title;
    self.dynamicTitle.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.dynamicTitle.textColor = [UIColor frescoDarkTextColor];
    [self addSubview:self.dynamicTitle];
    
    self.dynamicCircle =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-box-circle-outline"]];
    self.dynamicCircle.frame = CGRectMake(self.dynamicTitle.bounds.size.width, self.dynamicTitle.bounds.size.height/2 - 12, 24, 24);
    [self.dynamicCircle sizeToFit];
    [self addSubview:self.dynamicCircle];
    
    if (topSeperator) {
        UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0.5)];
        top.alpha = 0.2;
        top.backgroundColor = [UIColor frescoDarkTextColor];
        [self addSubview:top];
    }
    
    if (bottomSeperator){
        UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.bounds.size.width, 0.5)];
        bottom.alpha = 0.2;
        bottom.backgroundColor = [UIColor frescoDarkTextColor];
        [self addSubview:bottom];
    }
    
    if (isSelected) {
        
        self.dynamicCircle.image = [UIImage imageNamed:@"check-box-circle-filled"];
        self.dynamicTitle.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        
    }
}


-(void)configureDisableAccountCell{
    
    self.backgroundColor = [UIColor frescoBackgroundColorDark];
    
    self.disableAccountTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 18, 207, 22)];
    [self.disableAccountTitleLabel setFont:[UIFont notaMediumWithSize:17]];
    [self.disableAccountTitleLabel setTextColor:[UIColor frescoDarkTextColor]];
    self.disableAccountTitleLabel.text = @"It doesn’t have to end like this";
    [self addSubview:self.disableAccountTitleLabel];
    
    self.disableAccountSubtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 52, 288, 29)];
    [self.disableAccountSubtitleLabel setFont:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular]];
    [self.disableAccountSubtitleLabel setTextColor:[UIColor frescoMediumTextColor]];
    self.disableAccountSubtitleLabel.numberOfLines = 2;
    self.disableAccountSubtitleLabel.text = @"Just in case you decide to come back, we’ll back up your account for one year before we delete it.";
    [self addSubview:self.disableAccountSubtitleLabel];
    
    self.sadEmojiIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sad-emoticon"]];
    self.sadEmojiIV.frame = CGRectMake(231, 18, 20, 20);
    [self addSubview:self.sadEmojiIV];
    
}


-(void)configureSliderCell{
    
    UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0.5)];
    top.alpha = 0.2;
    top.backgroundColor = [UIColor frescoDarkTextColor];
    [self addSubview:top];
    
    UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 56, self.bounds.size.width, 0.5)];
    bottom.alpha = 0.2;
    bottom.backgroundColor = [UIColor frescoDarkTextColor];
    [self addSubview:bottom];
    
    UISlider *radiusSlider = [[UISlider alloc] initWithFrame:CGRectMake(52, 14, self.frame.size.width - 104, 28)];
    [radiusSlider setMinimumTrackTintColor:[UIColor frescoBlueColor]];
    [radiusSlider setMaximumTrackTintColor:[UIColor frescoSliderGray]];
    [self addSubview:radiusSlider];
    
    UIImageView *smallIV = [[UIImageView alloc] initWithFrame:CGRectMake(12, 16, 24, 24)];
    smallIV.image = [UIImage imageNamed:@"radius-small"];
    [self addSubview:smallIV];
    
    UIImageView *bigIV = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 12 - 24, 16, 24, 24)];
    bigIV.image = [UIImage imageNamed:@"radius-large"];
    [self addSubview:bigIV];

}

-(void)configureMapCell{
    
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    mapView.delegate = self;
    mapView.zoomEnabled = NO;
    mapView.scrollEnabled = NO;
    mapView.centerCoordinate = CLLocationCoordinate2DMake(40.00123, -70.10239);
    
    MKCoordinateRegion region;
    region.center.latitude = 40.7118;
    region.center.longitude = -74.0105;
    region.span.latitudeDelta = 0.015;
    region.span.longitudeDelta = 0.015;
    mapView.region = region;
    
    [self addSubview:mapView];
    
    [mapView addSubview:[UIView lineAtPoint:CGPointMake(0, -0.5)]];
    
}

-(void)clearCell{
    
}

-(void)test{
    NSLog(@"test");
}


@end