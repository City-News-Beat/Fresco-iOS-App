//
//  FRSTableViewCell.m
//  Fresco
//
//  Created by Omar Elfanek on 1/8/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSTableViewCell.h"

/* Categories */
#import "UIFont+Fresco.h"
#import "UIColor+Fresco.h"
#import "UIView+Helpers.h"

#import "FRSAlertView.h"
#import "FRSSettingsViewController.h"
#import "DGElasticPullToRefreshLoadingViewCircle.h"
#import "FRSAPIClient.h"
#import <Haneke/Haneke.h>
@interface FRSTableViewCell() <FRSAlertViewDelegate>

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

@property (strong, nonatomic) UILabel *disableAccountTitleLabel;
@property (strong, nonatomic) UILabel *disableAccountSubtitleLabel;
@property (strong, nonatomic) UIImageView *sadEmojiIV;

@property (strong, nonatomic) UILabel *findFriendsLabel;

@property (strong, nonatomic) FRSAlertView *alert;

@property (strong, nonatomic) DGElasticPullToRefreshLoadingViewCircle *loadingView;

@property BOOL notificationsEnabled;
@property BOOL locationEnabled;

@property BOOL didToggleTwitter;
@property BOOL didToggleFacebook;

@property (strong, nonatomic) NSDictionary *currentUserDict;
@property (strong, nonatomic) UIButton *followingButton;
@property BOOL following;

@property (strong, nonatomic) FRSUser *currentUser;

@end


@implementation FRSTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self){
        
        self.leftPadding = 16;
        self.rightPadding = 10;
        
    }

    return self;
}

-(void)configureSocialCellWithTitle:(NSString *)title andTag:(NSInteger)tag enabled:(BOOL)enabled {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.socialTitleLabel  = [[UILabel alloc] initWithFrame:CGRectMake(56, 0, [UIScreen mainScreen].bounds.size.width - (self.rightPadding+self.leftPadding) - 10, self.frame.size.height)];
    self.socialTitleLabel.text = title;
    self.socialTitleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.socialTitleLabel.textColor = [UIColor frescoDarkTextColor];
    [self addSubview:self.socialTitleLabel];
    
    if (tag == 1){
        self.twitterIV =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"social-twitter"]];
        self.twitterIV.frame = CGRectMake(16, 10 ,24,24);
        [self.twitterIV sizeToFit];
        [self addSubview:self.twitterIV];
        
        self.twitterSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.frame.size.width - 12 - 51, 6, 51, 31)];
        [self.twitterSwitch addTarget:self action:@selector(twitterToggle) forControlEvents:UIControlEventValueChanged];
        self.twitterSwitch.onTintColor = [UIColor twitterBlueColor];
        [self.twitterSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"twitter-connected" ] animated:NO];

        [self addSubview:self.twitterSwitch];
        
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"twitter-handle"]) {
            self.socialTitleLabel.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"twitter-handle"];
        } else if (self.twitterHandle) {
            self.socialTitleLabel.text = self.twitterHandle;
            [[NSUserDefaults standardUserDefaults] setValue:self.twitterHandle forKey:@"twitter-handle"];
        }

    } else if (tag == 2){
        self.facebookIV =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"social-facebook"]];
        self.facebookIV.frame = CGRectMake(16, 10 ,24, 24);
        [self.facebookIV sizeToFit];
        [self addSubview:self.facebookIV];
        
        self.facebookSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.frame.size.width - 12 - 51, 6, 51, 31)];
        [self.facebookSwitch addTarget:self action:@selector(facebookToggle) forControlEvents:UIControlEventValueChanged];
        self.facebookSwitch.onTintColor = [UIColor facebookBlueColor];
        
        [self.facebookSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"facebook-connected"] animated:NO];
        [self addSubview:self.facebookSwitch];
        
    } else if (tag == 3){
        self.googleIV =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"google-icon-filled"]];
        self.googleIV.frame = CGRectMake(16, 10 ,24,24);
        [self.googleIV sizeToFit];
        [self addSubview:self.googleIV];
    }
}


-(void)didPressButtonAtIndex:(NSInteger)index {
    if (self.didToggleTwitter) {
        self.didToggleTwitter = NO;
        if (index == 0) {
            NSLog(@"twitter index = 0");
            [self.twitterSwitch setOn:YES animated:YES];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"twitter-connected"];
        } else {
            NSLog(@"twitter index = 1");
            [self.twitterSwitch setOn:NO animated:YES];
            self.twitterHandle = nil;
            [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"twitter-handle"];
            self.socialTitleLabel.text = @"Connect Twitter";
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"twitter-connected"];
        }
    } else if (self.didToggleFacebook) {
        self.didToggleFacebook = NO;
        if (index == 0) {
            NSLog(@"facebook index = 0");
            [self.facebookSwitch setOn:YES animated:YES];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"facebook-connected"];

        } else if (index == 1) {
            NSLog(@"facebook index = 1");
            [self.facebookSwitch setOn:NO animated:YES];
            self.facebookName = nil;
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"facebook-connected"];
            self.socialTitleLabel.text = @"Connect Facebook";
            [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"facebook-name"];

        }
    }
    
    self.alert = nil;
}


-(void)twitterToggle {
    
    if (self.alert) {
        return;
    }
    
    self.didToggleTwitter = YES;
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"twitter-handle"]) {
        
        NSLog(@"DISABLED TWITTER");
        self.alert = [[FRSAlertView alloc] initWithTitle:@"DISCONNECT TWITTER?" message:@"You’ll be unable to use your Twitter account for logging in and sharing galleries." actionTitle:@"CANCEL" cancelTitle:@"DISCONNECT" cancelTitleColor:[UIColor frescoRedHeartColor] delegate:self];
        self.alert.delegate = self;
        [self.alert show];
        
    } else {
//        self.twitterSwitch.userInteractionEnabled = NO;
//        self.userInteractionEnabled = NO;
//        self.twitterIV.alpha = 0;
//        [self configureSpinner];
        [FRSSocial loginWithTwitter:^(BOOL authenticated, NSError *error, TWTRSession *session, FBSDKAccessToken *token) {
//            [self.loadingView stopLoading];
//            [self.loadingView removeFromSuperview];
            self.twitterSwitch.userInteractionEnabled = YES;
            self.userInteractionEnabled = YES;
            
            if (session) {
                
                [[FRSAPIClient sharedClient] updateUserWithDigestion:@{@"twitter_handle" : session.userName} completion:^(id responseObject, NSError *error) {
                }];
                
                
                self.twitterHandle = session.userName;
                [self.twitterSwitch setOn:YES animated:YES];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"twitter-connected"];
                self.socialTitleLabel.text = self.twitterHandle;
                [[NSUserDefaults standardUserDefaults] setValue:self.twitterHandle forKey:@"twitter-handle"];
            } else if (error) {
                FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"ERROR" message:@"Unable to connect Twitter. Please try again later." actionTitle:@"OK" cancelTitle:@"" cancelTitleColor:nil delegate:nil];
                [alert show];
            }
        }];
    }
}

-(void)facebookToggle {
    
    
    if (self.alert) {
        return;
    }
    
    
    self.didToggleFacebook = YES;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"facebook-connected"]) {
        NSLog(@"DISABLE FACEBOOK");
        
        self.alert = [[FRSAlertView alloc] initWithTitle:@"DISCONNECT FACEBOOK?" message:@"You’ll be unable to use your Facebook account for logging in and sharing galleries." actionTitle:@"CANCEL" cancelTitle:@"DISCONNECT" cancelTitleColor:[UIColor frescoRedHeartColor] delegate:self];
        self.alert.delegate = self;
        [self.alert show];

    } else {
        
        
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        
        [login logInWithReadPermissions: @[@"public_profile", @"email", @"user_friends"] fromViewController:self.inputViewController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {

            if (error) {
                //handle errors
            }
            
            if (result && !error) {
                NSDictionary *socialDigest = [[FRSAPIClient sharedClient] socialDigestionWithTwitter:nil facebook:[FBSDKAccessToken currentAccessToken]];
                
                [[FRSAPIClient sharedClient] updateUserWithDigestion:socialDigest completion:^(id responseObject, NSError *error) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"facebook-connected"];
                    [self.facebookSwitch setOn:YES animated:YES];
                    self.facebookSwitch.alpha = 0;
                    
                    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"name"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                        if (!error) {
                            self.facebookName = [result valueForKey:@"name"];
                            self.socialTitleLabel.text = self.facebookName;
                            [[NSUserDefaults standardUserDefaults] setObject:self.facebookName forKey:@"facebook-name"];
                        }
                    }];
                    
                }];
            }
        }];
    }
}

-(void)configureSpinner {
    self.loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    self.loadingView.frame = CGRectMake(16, 10, 24, 24);
    self.loadingView.tintColor = [UIColor frescoOrangeColor];
    [self.loadingView setPullProgress:90];
    [self.loadingView startAnimating];
//    [self addSubview:self.loadingView];
}


-(void)configureAssignmentCellEnabled:(BOOL)enabled {
    
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
    [self.notificationSwitch setOn:enabled animated:NO];
    [self.notificationSwitch addTarget:self action:@selector(notificationToggle:) forControlEvents:UIControlEventValueChanged];
    self.notificationSwitch.center = CGPointMake([UIScreen mainScreen].bounds.size.width - self.notificationSwitch.bounds.size.width/2 - 13.5, self.notificationSwitch.bounds.size.height/2 + 14);
    [self addSubview:self.notificationSwitch];
    
    self.assignmentHideDividerView = [[UIView alloc] initWithFrame:CGRectMake(0, 61, self.bounds.size.width, 1)];
    self.assignmentHideDividerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.assignmentHideDividerView];
}


-(void)configureDefaultCellWithTitle:(NSString *)title andCarret:(BOOL)yes andRightAlignedTitle:(NSString *)secondTitle {
    
    self.defaultTitleLabel  = [[UILabel alloc] initWithFrame:CGRectMake(self.leftPadding, 0, [UIScreen mainScreen].bounds.size.width - (self.rightPadding + self.leftPadding) - 10, self.frame.size.height)];
    self.defaultTitleLabel.text = title;
    self.defaultTitleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.defaultTitleLabel.textColor = [UIColor frescoDarkTextColor];
    [self addSubview:self.defaultTitleLabel];
    
    self.rightAlignedDefaultTitleLabel  = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 230, 0, 200, self.frame.size.height)];
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

-(void)configureCellWithUsername:(NSString *)username {
    
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

-(void)configureLogOut {
    
    self.logOutLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 - 27, self.bounds.size.height/2 - 6, 54, 17)];
    self.logOutLabel.text = @"LOG OUT";
    self.logOutLabel.textColor = [UIColor frescoRedHeartColor];
    self.logOutLabel.font = [UIFont notaBoldWithSize:15];
    [self addSubview:self.logOutLabel];
    
}

-(void)configureEmptyCellSpace:(BOOL)yes {
    
    self.backgroundColor = [UIColor frescoBackgroundColorDark];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(yes){
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 12, self.bounds.size.width, 1)];
        view.backgroundColor = [UIColor frescoBackgroundColorDark];
        [self addSubview:view];
    }
}

-(void)configureEditableCellWithDefaultText:(NSString *)string withTopSeperator:(BOOL)topSeperator withBottomSeperator:(BOOL)bottomSeperator isSecure:(BOOL)secure withKeyboardType:(UIKeyboardType)keyboardType {
    
    self.textField  = [[UITextField alloc] initWithFrame:CGRectMake(self.leftPadding, 0, [UIScreen mainScreen].bounds.size.width - (self.self.rightPadding+self.leftPadding),44)];
    self.textField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.textField.placeholder = string;
    self.textField.delegate = (id<UITextFieldDelegate>)self;
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

-(void)configureEditableCellWithDefaultTextWithMultipleFields:(NSArray *)titles withTopSeperator:(BOOL)topSeperator withBottomSeperator:(BOOL)bottomSeperator isSecure:(BOOL)secure withKeyboardType:(UIKeyboardType)keyboardType {
    
    self.textField  = [[UITextField alloc] initWithFrame:CGRectMake(self.leftPadding, 0, ([UIScreen mainScreen].bounds.size.width/3)*2 - (self.self.rightPadding+self.leftPadding),44)];
    self.textField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.textField.placeholder = titles[0];
    self.textField.delegate = (id<UITextFieldDelegate>)self;
    self.textField.textColor = [UIColor frescoDarkTextColor];
    self.textField.tintColor = [UIColor frescoBlueColor];
    [self addSubview:self.textField];
    
    self.secondaryField = [[UITextField alloc] initWithFrame:CGRectMake(_textField.frame.size.width, _textField.frame.origin.y, _textField.frame.size.width/3, _textField.frame.size.height)];
    [self addSubview:self.secondaryField];
    
    self.secondaryField.placeholder = titles[1];
    
    self.tertiaryField = [[UITextField alloc] initWithFrame:CGRectMake(_textField.frame.size.width + _secondaryField.frame.size.width, _textField.frame.origin.y, _textField.frame.size.width/3, _textField.frame.size.height)];
    [self addSubview:self.tertiaryField];
    
    self.tertiaryField.placeholder = titles[2];
    
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


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 40;
}

-(void)configureCellWithRightAlignedButtonTitle:(NSString *)title withWidth:(CGFloat)width withColor:(UIColor *)color {
    
    self.backgroundColor = [UIColor clearColor];
    self.rightAlignedButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.rightAlignedButton.frame = CGRectMake(self.frame.size.width - width, 0, width, self.frame.size.height);
    [self.rightAlignedButton setTitle:title forState:UIControlStateNormal];
    [self.rightAlignedButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
    self.rightAlignedButton.userInteractionEnabled = NO;
    [self.rightAlignedButton setTitleColor:color forState:UIControlStateNormal];
    [self addSubview:self.rightAlignedButton];
}

-(void)configureCheckBoxCellWithTitle:(NSString *)title withTopSeperator:(BOOL)topSeperator withBottomSeperator:(BOOL)bottomSeperator isSelected:(BOOL)isSelected {
    
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


-(void)configureDisableAccountCell {
    
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
    self.sadEmojiIV.frame = CGRectMake(231, 16, 24, 24);
    [self addSubview:self.sadEmojiIV];
    
}


-(void)configureSliderCell {
    
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

-(void)configureMapCell {

//    MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//    mapView.delegate = self;
//    mapView.zoomEnabled =
//    mapView.scrollEnabled = NO;
//    mapView.centerCoordinate = CLLocationCoordinate2DMake(40.00123, -70.10239);
//    
//    MKCoordinateRegion region;
//    region.center.latitude = 40.7118;
//    region.center.longitude = -74.0105;
//    region.span.latitudeDelta = 0.015;
//    region.span.longitudeDelta = 0.015;
//    mapView.region = region;
//    
//    [self addSubview:mapView];
//    
//    [mapView addSubview:[UIView lineAtPoint:CGPointMake(0, -0.5)]];
    
}

-(void)configureSettingsHeaderCellWithTitle:(NSString *)title {
    
    self.defaultTitleLabel  = [[UILabel alloc] initWithFrame:CGRectMake(self.leftPadding, 8, [UIScreen mainScreen].bounds.size.width - (self.rightPadding + self.leftPadding) - 10, self.frame.size.height)];
    self.defaultTitleLabel.text = title;
    self.defaultTitleLabel.font = [UIFont notaBoldWithSize:15];
    self.defaultTitleLabel.textColor = [UIColor frescoMediumTextColor];
    [self addSubview:self.defaultTitleLabel];
    
    self.backgroundColor = [UIColor frescoBackgroundColorDark];
}

-(void)configureSearchSeeAllCellWithTitle:(NSString *)title {
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0.5)];
    topLine.backgroundColor = [UIColor colorWithRed:0.878 green:0.878 blue:0.878 alpha:1.00]; //Color is frescoShadowColor behnd frescoBackgroundColorLight without any transparency. Added to avoid double alpha when top and bottom overlap
    [self addSubview:topLine];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 44, [UIScreen mainScreen].bounds.size.width, 0.5)];
    bottomLine.backgroundColor = [UIColor colorWithRed:0.878 green:0.878 blue:0.878 alpha:1.00];
    [self addSubview:bottomLine];
    
    self.defaultTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.frame.size.height)];
    self.defaultTitleLabel.text = title;
    self.defaultTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.defaultTitleLabel.font = [UIFont notaBoldWithSize:15];
    self.defaultTitleLabel.textColor = [UIColor frescoBlueColor];
    [self addSubview:self.defaultTitleLabel];
    self.backgroundColor = [UIColor whiteColor];
}


-(void)configureSearchUserCellWithProfilePhoto:(NSURL *)profile fullName:(NSString *)nameString userName:(NSString *)username isFollowing:(BOOL)isFollowing userDict:(NSDictionary *)userDict user:(FRSUser *)user {
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0.5)];
    topLine.backgroundColor = [UIColor colorWithRed:0.878 green:0.878 blue:0.878 alpha:1.00]; //Color is frescoShadowColor behnd frescoBackgroundColorLight without any transparency. Added to avoid double alpha when top and bottom overlap
    [self addSubview:topLine];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 56, [UIScreen mainScreen].bounds.size.width, 0.5)];
    bottomLine.backgroundColor = [UIColor colorWithRed:0.878 green:0.878 blue:0.878 alpha:1.00];
    [self addSubview:bottomLine];
    
    UIImageView *profileIV = [[UIImageView alloc] init];
    profileIV.frame = CGRectMake(16, 12, 32, 32);
    profileIV.layer.cornerRadius = 16;
    profileIV.clipsToBounds = YES;
    
    [profileIV hnk_setImageFromURL:(NSURL *)profile];
    
    profileIV.backgroundColor = [UIColor frescoLightTextColor];
    NSLog(@"profile image URL: %@", profile);
    if (!profile) {
        UIImageView *profileIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user-24"]];
        profileIcon.frame = CGRectMake(4, 4, 24, 24);
        [profileIV addSubview:profileIcon];
    }
    
    [self addSubview:profileIV];

    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, self.frame.size.height/2 - 8 + 7, self.frame.size.width - 64, self.frame.size.height)];
    nameLabel.text = nameString;
    nameLabel.font = [UIFont notaMediumWithSize:17];
    nameLabel.textColor = [UIColor frescoDarkTextColor];
    [nameLabel sizeToFit];
    [self addSubview:nameLabel];
    
    UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(64 + 8 + nameLabel.frame.size.width, 23, self.frame.size.width - 64, 14)];
    usernameLabel.text = (username && ![username isEqual:[NSNull null]]) ? [@"@" stringByAppendingString:username] : @"";
    usernameLabel.font = [UIFont notaRegularWithSize:12];
    usernameLabel.textColor = [UIColor frescoMediumTextColor];
    [usernameLabel sizeToFit];
    usernameLabel.frame = CGRectMake(64 + 8 + nameLabel.frame.size.width, 23, self.frame.size.width - 64 - nameLabel.frame.size.width, 14); //set label max width
    
    //Checks if username label is truncating and nameLabel.text is not empty
    CGSize size = [usernameLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont notaRegularWithSize:12]}];
    if ((size.width > usernameLabel.bounds.size.width) && ![nameLabel.text isEqualToString:@""]) {
        usernameLabel.alpha = 0;
    }
    
    if ([nameLabel.text isEqualToString: @""]) {
        usernameLabel.frame = CGRectMake(64 + nameLabel.frame.size.width, 23, self.frame.size.width - 64, 14);
    }
    
//    CGSize nameLabelSize = [usernameLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont notaMediumWithSize:17]}];
//    if (nameLabelSize.width > usernameLabel.bounds.size.width) {
//
//    }
    
    [self addSubview:usernameLabel];

    self.followingButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.followingButton addTarget:self action:@selector(follow) forControlEvents:UIControlEventTouchUpInside];
    self.followingButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 40, 16, 24, 24);
    
    [self addSubview:self.followingButton];
    
    if (isFollowing){
        [self.followingButton setImage:[UIImage imageNamed:@"account-check"] forState:UIControlStateNormal];
        self.followingButton.tintColor = [UIColor frescoOrangeColor];
    } else {
        [self.followingButton setImage:[UIImage imageNamed:@"account-add"] forState:UIControlStateNormal];
        self.followingButton.tintColor = [UIColor frescoMediumTextColor];
    }

    self.currentUserDict = userDict;
    self.following = isFollowing;
    self.currentUser = user;

}

-(void)follow {
    //Used to pass in current user
    [self follow:self.currentUserDict user:self.currentUser following:self.following];
}


-(void)follow:(NSDictionary *)userDict user:(FRSUser *)user following:(BOOL)following {
    
    FRSUser *currentUser;
    if (userDict) {
         currentUser = [FRSUser nonSavedUserWithProperties:userDict context:[[FRSAPIClient sharedClient] managedObjectContext]];
    } else {
        currentUser = user;
    }

    if (following) {
        NSLog(@"USER IS FOLLOWING, UNFOLLOW AND CHANGE ICON");
        [self unfollow:currentUser];
    } else {
        NSLog(@"USER IS NOT FOLLOWING, FOLLOW AND CHANGE ICON");
        [self follow:currentUser];
    }
}


-(void)follow:(FRSUser *)user {
    
    [[FRSAPIClient sharedClient] followUser:user completion:^(id responseObject, NSError *error) {
        if (error) {
            return;
        }

        [self.followingButton setImage:[UIImage imageNamed:@"account-check"] forState:UIControlStateNormal];
        self.followingButton.tintColor = [UIColor frescoOrangeColor];
        self.following = YES;
    }];
}

-(void)unfollow:(FRSUser *)user {
    
    [[FRSAPIClient sharedClient] unfollowUser:user completion:^(id responseObject, NSError *error) {
        if (error) {
            return;
        }
        
        [self.followingButton setImage:[UIImage imageNamed:@"account-add"] forState:UIControlStateNormal];
        self.followingButton.tintColor = [UIColor frescoMediumTextColor];
        self.following = NO;
    }];
}


-(void)configureSearchStoryCellWithStoryPhoto:(NSURL *)storyPhoto storyName:(NSString *)nameString {
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0.5)];
    topLine.backgroundColor = [UIColor colorWithRed:0.878 green:0.878 blue:0.878 alpha:1.00]; //Color is frescoShadowColor behnd frescoBackgroundColorLight without any transparency. Added to avoid double alpha when top and bottom overlap
    [self addSubview:topLine];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 56, [UIScreen mainScreen].bounds.size.width, 0.5)];
    bottomLine.backgroundColor = [UIColor colorWithRed:0.878 green:0.878 blue:0.878 alpha:1.00];
    [self addSubview:bottomLine];
    
    UIImageView *storyPreviewIV = [[UIImageView alloc] init];
    storyPreviewIV.frame = CGRectMake(16, 12, 32, 32);
    storyPreviewIV.layer.cornerRadius = 16;
    storyPreviewIV.clipsToBounds = YES;
    [self addSubview:storyPreviewIV];
    [storyPreviewIV hnk_setImageFromURL:storyPhoto];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, self.frame.size.height/2- 26+11, self.frame.size.width -16 -8, self.frame.size.height)];
    nameLabel.text = nameString;
    nameLabel.font = [UIFont notaMediumWithSize:17];
    nameLabel.textColor = [UIColor frescoDarkTextColor];
    [self addSubview:nameLabel];
}

-(void)configureFindFriendsCell {

    self.findFriendsLabel  = [[UILabel alloc] initWithFrame:CGRectMake(56, 0, [UIScreen mainScreen].bounds.size.width - (self.rightPadding+self.leftPadding) - 10, self.frame.size.height)];
    self.findFriendsLabel.text = @"Find Friends";
    self.findFriendsLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    self.findFriendsLabel.textColor = [UIColor frescoDarkTextColor];
    [self addSubview:self.findFriendsLabel];
    
    self.twitterIV =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"friends"]];
    self.twitterIV.frame = CGRectMake(16, 10 ,24, 24);
    [self.twitterIV sizeToFit];
    [self addSubview:self.twitterIV];
    
    self.carrotIV =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]];
    self.carrotIV.frame = CGRectMake(self.findFriendsLabel.bounds.size.width + self.leftPadding, self.findFriendsLabel.bounds.size.height/2 -7, 24, 24);
    [self.carrotIV sizeToFit];
    [self addSubview:self.carrotIV];
}

-(void)notificationToggle:(id)sender {
    [self checkNotificationStatus];
    [self checkLocationStatus];
    
    BOOL state;
    
    
    if ([sender isOn]) {
        state = YES;
        if (!self.notificationsEnabled || !self.locationEnabled) {
            FRSAlertView *alert = [[FRSAlertView alloc] initPermissionsAlert];
            [alert show];
        }
//        [self requestNotifications]; //Request and enable notifications
    } else {
        state = NO;
        [[UIApplication sharedApplication] unregisterForRemoteNotifications]; //Unregister from notifications
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:state forKey:@"notifications-enabled"];
}

-(void)checkNotificationStatus {
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]) {
        UIUserNotificationSettings *notificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        
        if (!notificationSettings || (notificationSettings.types == UIUserNotificationTypeNone)) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"notifications-enabled"];
            self.notificationsEnabled = NO;
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notifications-enabled"];
            self.notificationsEnabled = YES;
        }
    }
}

-(void)checkLocationStatus {
    if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"location-enabled"];
        self.locationEnabled = YES;
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"location-enabled"];
        self.locationEnabled = NO;
    }
    
}


-(void)requestNotifications {
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"notifications-enabled"]) {
        return;
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"NotificationsRequested"]) {
        UIUserNotificationType types = (UIUserNotificationType) (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NotificationsRequested"];
}












@end