//
//  FRSAlertView.m
//  Fresco
//
//  Created by Omar Elfanek on 12/18/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSAlertView.h"
#import "UIColor+Fresco.h"
#import "UIFont+Fresco.h"
#import "UIView+Helpers.h"
#import "DGElasticPullToRefreshLoadingViewCircle.h"
#import <MapKit/MapKit.h>
#import <Contacts/Contacts.h>
#import "FRSAuthManager.h"
#import "FRSUserManager.h"
#import "NSString+Validation.h"

#define ALERT_WIDTH 270
#define MESSAGE_WIDTH 238

@interface FRSAlertView () <UITextViewDelegate>

/* Reusable Alert Properties */
@property (strong, nonatomic) UIView *overlayView;
@property (strong, nonatomic) UIView *buttonShadow;

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;

@property (strong, nonatomic) UIButton *cancelButton;

@property (strong, nonatomic) UIView *actionLine;

@property CGFloat height;

@property (strong, nonatomic) UIButton *expandTOSButton;
@property (strong, nonatomic) UITextView *TOSTextView;
@property (strong, nonatomic) UIView *topLine;

@property (nonatomic) BOOL usernameTaken;
@property (nonatomic) BOOL emailTaken;
@property (strong, nonatomic) NSTimer *usernameTimer;

@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UITextField *emailTextField;
@property (strong, nonatomic) UITextField *passwordTextField;

@property (strong, nonatomic) UIImageView *usernameCheckIV;
@property (strong, nonatomic) UILabel *usernameTakenLabel;
@property BOOL migrationAlertShouldShowPassword;

@property (strong, nonatomic) UIImageView *emailCheckIV;

@property (strong, nonatomic) UITapGestureRecognizer *dismissKeyboardTap;

@end

@implementation FRSAlertView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message actionTitle:(NSString *)actionTitle cancelTitle:(NSString *)cancelTitle cancelTitleColor:(UIColor *)cancelTitleColor delegate:(id)delegate {
    self = [super init];
    if (self) {

        self.delegate = delegate;

        self.frame = CGRectMake(0, 0, ALERT_WIDTH, 0);

        [self configureDarkOverlay];

        /* Alert Box */
        self.backgroundColor = [UIColor frescoBackgroundColorLight];

        /* Title Label */
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ALERT_WIDTH, 44)];
        [self.titleLabel setFont:[UIFont notaBoldWithSize:17]];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = title;
        self.titleLabel.alpha = .87;
        [self addSubview:self.titleLabel];

        /* Body Label */
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - MESSAGE_WIDTH) / 2, 44, MESSAGE_WIDTH, 0)];
        self.messageLabel.alpha = .54;
        self.messageLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.numberOfLines = 0;

        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:message];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:2];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [message length])];

        self.messageLabel.attributedText = attributedString;
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        [self.messageLabel sizeToFit];
        self.messageLabel.frame = CGRectMake(self.messageLabel.frame.origin.x, self.messageLabel.frame.origin.y, MESSAGE_WIDTH, self.messageLabel.frame.size.height);
        [self addSubview:self.messageLabel];

        /* Action Shadow */
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 14.5, ALERT_WIDTH, 0.5)];
        line.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
        [self addSubview:line];

        if ([cancelTitle isEqual:@""]) {
            /* Single Action Button */
            self.actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [self.actionButton addTarget:self action:@selector(actionTapped) forControlEvents:UIControlEventTouchUpInside];
            self.actionButton.frame = CGRectMake(0, self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 15, ALERT_WIDTH, 44);
            [self.actionButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
            [self.actionButton setTitle:actionTitle forState:UIControlStateNormal];
            [self.actionButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
            [self addSubview:self.actionButton];
        } else {
            /* Left Action */
            self.actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [self.actionButton addTarget:self action:@selector(actionTapped) forControlEvents:UIControlEventTouchUpInside];
            self.actionButton.frame = CGRectMake(16, self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 15, 121, 44);
            self.actionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [self.actionButton setTitleColor:[UIColor frescoDarkTextColor] forState:UIControlStateNormal];
            [self.actionButton setTitle:actionTitle forState:UIControlStateNormal];
            [self.actionButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
            [self addSubview:self.actionButton];

            /* Right Action */
            self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
            self.cancelButton.frame = CGRectMake(169, self.actionButton.frame.origin.y, 101, 44);
            [self.cancelButton addTarget:self action:@selector(cancelTapped) forControlEvents:UIControlEventTouchUpInside];
            [self.cancelButton setTitleColor:cancelTitleColor forState:UIControlStateNormal];
            [self.cancelButton setTitle:cancelTitle forState:UIControlStateNormal];
            [self.cancelButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
            [self.cancelButton sizeToFit];
            [self.cancelButton setFrame:CGRectMake(self.frame.size.width - self.cancelButton.frame.size.width - 32, self.cancelButton.frame.origin.y, self.cancelButton.frame.size.width + 32, 44)];
            [self addSubview:self.cancelButton];
        }
        [self adjustFrame];
        [self addShadowAndClip];

        [self animateIn];
    }
    self.delegate = delegate;
    return self;
}

- (void)show {
    /* keyWindow places the view above all. Add overlay view first, and then alertView*/
    [[UIApplication sharedApplication].keyWindow addSubview:self.overlayView];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self.inputViewController.view endEditing:YES];
}

- (void)adjustFrame {
    self.height = self.actionButton.frame.size.height + self.messageLabel.frame.size.height + self.titleLabel.frame.size.height + 15;

    //UIViewController* vc = (UIViewController *)self.delegate;

    NSInteger xOrigin = ([UIScreen mainScreen].bounds.size.width - ALERT_WIDTH) / 2;
    NSInteger yOrigin = ([UIScreen mainScreen].bounds.size.height - self.height) / 2;

    self.frame = CGRectMake(xOrigin, yOrigin, ALERT_WIDTH, self.height);
}

- (void)addShadowAndClip {
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 4);
    self.layer.shadowRadius = 2;
    self.layer.shadowOpacity = 0.1;
    self.layer.cornerRadius = 2;
}

- (void)cancelTapped {
    [self animateOut];

    if (self.delegate) {
        [self.delegate didPressButton:self atIndex:1];
    }

    FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.didPresentPermissionsRequest = NO;
}

- (void)actionTapped {
    [self animateOut];

    if (self.delegate) {
        [self.delegate didPressButton:self atIndex:0];
    }

    FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.didPresentPermissionsRequest = NO;
}

- (void)settingsTapped {
    [self animateOut];

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)animateIn {

    /* Set default state before animating in */
    self.transform = CGAffineTransformMakeScale(1.175, 1.175);
    self.alpha = 0;

    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{

                       self.alpha = 1;
                       self.titleLabel.alpha = 1;
                       self.cancelButton.alpha = 1;
                       self.actionButton.alpha = 1;
                       self.overlayView.alpha = 0.26;
                       self.transform = CGAffineTransformMakeScale(1, 1);

                     }
                     completion:nil];
}

- (void)animateOut {

    [UIView animateWithDuration:0.25
        delay:0.0
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{

          self.alpha = 0;
          self.titleLabel.alpha = 0;
          self.cancelButton.alpha = 0;
          self.actionButton.alpha = 0;
          self.overlayView.alpha = 0;
          self.transform = CGAffineTransformMakeScale(0.9, 0.9);

        }
        completion:^(BOOL finished) {
          [self removeFromSuperview];
        }];
}

- (void)configureDarkOverlay {
    /* Dark Overlay */
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    self.overlayView.backgroundColor = [UIColor blackColor];
    self.overlayView.alpha = 0;
    [self addSubview:(self.overlayView)];
}

#pragma mark - Custom Alerts

- (instancetype)initFindFriendsAlert {
    self = [super init];

    if (self) {

        self.frame = CGRectMake(0, 0, ALERT_WIDTH, 0);

        [self configureDarkOverlay];

        /* Alert Box */
        self.backgroundColor = [UIColor frescoBackgroundColorLight];

        /* Title Label */
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ALERT_WIDTH, 44)];
        [self.titleLabel setFont:[UIFont notaBoldWithSize:17]];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = @"NOT SURE WHO TO FOLLOW?";
        self.titleLabel.alpha = .87;
        [self addSubview:self.titleLabel];

        /* Body Label */
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - MESSAGE_WIDTH) / 2, 44, MESSAGE_WIDTH, 0)];
        self.messageLabel.alpha = .54;
        self.messageLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.numberOfLines = 0;

        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Connect your address book to find your friends on Fresco."];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:2];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [@"Connect your address book to find your friends on Fresco." length])];

        self.messageLabel.attributedText = attributedString;
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        [self.messageLabel sizeToFit];
        self.messageLabel.frame = CGRectMake(self.messageLabel.frame.origin.x, self.messageLabel.frame.origin.y, MESSAGE_WIDTH, self.messageLabel.frame.size.height);
        [self addSubview:self.messageLabel];

        /* Action Shadow */
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 14.5, ALERT_WIDTH, 0.5)];
        line.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
        [self addSubview:line];

        /* Left Action */
        self.actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.actionButton addTarget:self action:@selector(cancelTapped) forControlEvents:UIControlEventTouchUpInside];
        self.actionButton.frame = CGRectMake(14, self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 15, 85, 44);
        [self.actionButton setTitleColor:[UIColor frescoDarkTextColor] forState:UIControlStateNormal];
        [self.actionButton setTitle:@"NO THANKS" forState:UIControlStateNormal];
        [self.actionButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self addSubview:self.actionButton];

        /* Right Action */
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.cancelButton.frame = CGRectMake(169, self.actionButton.frame.origin.y, 0, 44);
        [self.cancelButton addTarget:self action:@selector(requestContacts) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        [self.cancelButton setTitle:@"FIND FRIENDS" forState:UIControlStateNormal];
        [self.cancelButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self.cancelButton sizeToFit];
        [self.cancelButton setFrame:CGRectMake(self.frame.size.width - self.cancelButton.frame.size.width - 32, self.cancelButton.frame.origin.y, self.cancelButton.frame.size.width + 32, 44)];
        [self addSubview:self.cancelButton];

        self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - ALERT_WIDTH / 2, [UIScreen mainScreen].bounds.size.height / 2 - 70, ALERT_WIDTH, 140);

        [self addShadowAndClip];
        [self animateIn];
    }
    return self;
}

- (void)requestContacts {

    //    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    //    if (status == CNAuthorizationStatusDenied || status == CNAuthorizationStatusRestricted || status == CNAuthorizationStatusNotDetermined) {

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];

    //        return;
    //    }
}

- (instancetype)initNoConnectionAlert {
    self = [super init];

    if (self) {

        NSString *message = @"Please check your internet connection.";

        self.frame = CGRectMake(0, 0, ALERT_WIDTH, 0);

        [self configureDarkOverlay];

        /* Alert Box */
        self.backgroundColor = [UIColor frescoBackgroundColorLight];

        /* Title Label */
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ALERT_WIDTH, 44)];
        [self.titleLabel setFont:[UIFont notaBoldWithSize:17]];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = @"NO CONNECTION";
        self.titleLabel.alpha = .87;
        [self addSubview:self.titleLabel];

        /* Body Label */
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - MESSAGE_WIDTH) / 2, 44, MESSAGE_WIDTH, 0)];
        self.messageLabel.alpha = .54;
        self.messageLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.numberOfLines = 0;

        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:message];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:2];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [message length])];

        self.messageLabel.attributedText = attributedString;
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        [self.messageLabel sizeToFit];
        self.messageLabel.frame = CGRectMake(self.messageLabel.frame.origin.x, self.messageLabel.frame.origin.y, MESSAGE_WIDTH, self.messageLabel.frame.size.height);
        [self addSubview:self.messageLabel];

        /* Action Shadow */
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 14.5, ALERT_WIDTH, 0.5)];
        line.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
        [self addSubview:line];

        /* Left Action */
        self.actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.actionButton addTarget:self action:@selector(settingsTapped) forControlEvents:UIControlEventTouchUpInside];
        self.actionButton.frame = CGRectMake(0, self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 15, 85, 44);
        [self.actionButton setTitleColor:[UIColor frescoDarkTextColor] forState:UIControlStateNormal];
        [self.actionButton setTitle:@"SETTINGS" forState:UIControlStateNormal];
        [self.actionButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self addSubview:self.actionButton];

        /* Right Action */
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.cancelButton.frame = CGRectMake(169, self.actionButton.frame.origin.y, 101, 44);
        [self.cancelButton addTarget:self action:@selector(cancelTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        [self.cancelButton setTitle:@"OK" forState:UIControlStateNormal];
        [self.cancelButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self.cancelButton sizeToFit];
        [self.cancelButton setFrame:CGRectMake(self.frame.size.width - self.cancelButton.frame.size.width - 32, self.cancelButton.frame.origin.y, self.cancelButton.frame.size.width + 32, 44)];
        [self addSubview:self.cancelButton];

        [self adjustFrame];
        [self addShadowAndClip];

        [self animateIn];
    }

    return self;
}

- (void)dismiss {
    [self animateOut];

    [[UIApplication sharedApplication].keyWindow removeGestureRecognizer:self.dismissKeyboardTap];
    [self removeFromSuperview];
}

- (instancetype)initNoConnectionBannerWithBackButton:(BOOL)backButton {

    self = [super init];

    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64);
        self.backgroundColor = [UIColor frescoRedColor];

        NSString *title = @"";

        if (IS_IPHONE_5) {
            title = @"UNABLE TO CONNECT";
        } else if (IS_IPHONE_6) {
            title = @"UNABLE TO CONNECT. CHECK SIGNAL";
        } else if (IS_IPHONE_6_PLUS) {
            title = @"UNABLE TO CONNECT. CHECK YOUR SIGNAL";
        }

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 33, [UIScreen mainScreen].bounds.size.width - 80, 19)];
        label.font = [UIFont notaBoldWithSize:17];
        label.textColor = [UIColor whiteColor];
        label.text = title;
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];

        if (backButton) {
            UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [backButton setImage:[UIImage imageNamed:@"back-arrow-light"] forState:UIControlStateNormal];
            backButton.frame = CGRectMake(12, 30, 24, 24);
            backButton.tintColor = [UIColor whiteColor];
            [self addSubview:backButton];
        }

        [UIView animateWithDuration:0.3
                              delay:2.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                           self.alpha = 0;
                         }
                         completion:nil];
    }
    return self;
}

- (instancetype)initTOS {
    self = [super init];

    if (self) {

        if (![FRSUserManager sharedInstance].authenticatedUser) {
            return nil;
        }

        self.frame = CGRectMake(0, 0, ALERT_WIDTH, 0);
        self.alpha = 0;

        [self configureDarkOverlay];

        /* Alert Box */
        self.backgroundColor = [UIColor frescoBackgroundColorLight];

        /* Title Label */
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ALERT_WIDTH, 44)];
        [self.titleLabel setFont:[UIFont notaBoldWithSize:17]];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = @"UPDATED TERMS";
        self.titleLabel.alpha = .87;
        [self addSubview:self.titleLabel];

        [[FRSUserManager sharedInstance] getTermsWithCompletion:^(id responseObject, NSError *error) {
          if (error || !responseObject) {
              return;
          }

          NSString *TOS = responseObject[@"terms"];
          TOS = [TOS stringByReplacingOccurrencesOfString:@"�" withString:@"\""];

          self.TOSTextView.text = TOS;

          [self addShadowAndClip];
          [self animateIn];
        }];

        self.TOSTextView = [[UITextView alloc] initWithFrame:CGRectMake((self.frame.size.width - MESSAGE_WIDTH) / 2, 44, MESSAGE_WIDTH, 320)];
        self.TOSTextView.textColor = [UIColor frescoMediumTextColor];
        self.TOSTextView.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        self.TOSTextView.textAlignment = NSTextAlignmentLeft;
        self.TOSTextView.backgroundColor = [UIColor clearColor];
        self.TOSTextView.editable = NO;
        self.TOSTextView.delegate = self;
        [self addSubview:self.TOSTextView];

        self.expandTOSButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.expandTOSButton.tintColor = [UIColor blackColor];
        self.expandTOSButton.frame = CGRectMake(self.frame.size.width - 24 - 12, 10, 24, 24);
        [self.expandTOSButton setImage:[UIImage imageNamed:@"arrow-expand"] forState:UIControlStateNormal];
        [self.expandTOSButton addTarget:self action:@selector(expandTOS) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.expandTOSButton];

        /* Action Shadow */
        self.actionLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 43.5, ALERT_WIDTH, 0.5)];
        self.actionLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
        [self addSubview:self.actionLine];

        self.topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, 0.5)];
        self.topLine.alpha = 0;
        self.topLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
        [self addSubview:self.topLine];

        /* Left Action */
        self.actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.actionButton addTarget:self action:@selector(logoutTapped) forControlEvents:UIControlEventTouchUpInside];
        self.actionButton.frame = CGRectMake(14, self.TOSTextView.frame.origin.y + self.TOSTextView.frame.size.height, 54, 44);
        [self.actionButton setTitleColor:[UIColor frescoRedColor] forState:UIControlStateNormal];
        [self.actionButton setTitle:@"LOG OUT" forState:UIControlStateNormal];
        [self.actionButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self addSubview:self.actionButton];

        /* Right Action */
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.cancelButton.frame = CGRectMake(169, self.actionButton.frame.origin.y, 0, 44);
        [self.cancelButton addTarget:self action:@selector(acceptTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        [self.cancelButton setTitle:@"ACCEPT" forState:UIControlStateNormal];
        [self.cancelButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self.cancelButton sizeToFit];
        [self.cancelButton setFrame:CGRectMake(self.frame.size.width - self.cancelButton.frame.size.width - 16, self.cancelButton.frame.origin.y, 49, 44)];
        [self addSubview:self.cancelButton];

        self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - ALERT_WIDTH / 2, [UIScreen mainScreen].bounds.size.height / 2 - 408 / 2, ALERT_WIDTH, 408);
        self.actionLine.frame = CGRectMake(0, self.frame.size.height - 43.5, ALERT_WIDTH, 0.5);

        //        [self addShadowAndClip];
        //[self animateIn];
    }
    return self;
}

- (void)expandTOS {

    //    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
    if ((IS_STANDARD_IPHONE_6_PLUS) || (IS_STANDARD_IPHONE_6)) {
        self.titleLabel.text = @"UPDATED TERMS OF SERVICE";
    }

    if (self.frame.size.width == ALERT_WIDTH) {
        self.frame = CGRectMake(16, 20, [UIScreen mainScreen].bounds.size.width - 32, [UIScreen mainScreen].bounds.size.height - 40);
        [self.expandTOSButton setImage:[UIImage imageNamed:@"arrow-compress"] forState:UIControlStateNormal];
    } else {
        self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - ALERT_WIDTH / 2, [UIScreen mainScreen].bounds.size.height / 2 - 408 / 2, ALERT_WIDTH, 408);
        [self.expandTOSButton setImage:[UIImage imageNamed:@"arrow-expand"] forState:UIControlStateNormal];
        self.titleLabel.text = @"UPDATED TERMS";
    }

    self.expandTOSButton.frame = CGRectMake(self.frame.size.width - 24 - 12, 10, 24, 24);
    self.titleLabel.frame = CGRectMake(0, 0, self.frame.size.width, 44);
    self.TOSTextView.frame = CGRectMake((self.frame.size.width - (self.frame.size.width - 32)) / 2, 44, (self.frame.size.width - 32), self.frame.size.height - 88);
    self.actionButton.frame = CGRectMake(14, self.frame.size.height - 44, 54, 44);
    self.cancelButton.frame = CGRectMake(self.frame.size.width - self.cancelButton.frame.size.width - 16, self.actionButton.frame.origin.y, self.cancelButton.frame.size.width, 44);
    self.actionLine.frame = CGRectMake(0, self.frame.size.height - 43.5, self.frame.size.width, 0.5);
    self.topLine.frame = CGRectMake(0, 44, self.frame.size.width, 0.5);
    //    } completion:nil];
}

- (void)acceptTapped {
    [[FRSUserManager sharedInstance] acceptTermsWithCompletion:^(id responseObject, NSError *error) {
      if (!error) {
          [self dismiss];
      } else {
          FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"OOPS" message:@"Something’s wrong on our end. Sorry about that!" actionTitle:@"CANCEL" cancelTitle:@"TRY AGAIN" cancelTitleColor:[UIColor frescoBlueColor] delegate:nil];
          [alert show];
      }
    }];
}

- (void)logoutTapped {
    [self.delegate logoutAlertAction];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logout_notification" object:nil];
    [[UIApplication sharedApplication].keyWindow removeGestureRecognizer:self.dismissKeyboardTap];
    [self dismiss];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.TOSTextView) {
        if (scrollView.contentOffset.y >= 5) {
            self.topLine.alpha = 1;
        } else {
            self.topLine.alpha = 0;
        }
    }
}

- (instancetype)initNewStuffWithPasswordField:(BOOL)password {

    self = [super init];
    if (self) {

        BOOL userHasEmail;
        BOOL userHasUsername;
        BOOL userHasPassword = !password;

        if ([[[[FRSUserManager sharedInstance] authenticatedUser] username] isEqual:[NSNull null]] || [[[[FRSUserManager sharedInstance] authenticatedUser] username] isEqualToString:@""] || ![[[FRSUserManager sharedInstance] authenticatedUser] username]) {
            userHasUsername = NO;
        } else {
            userHasUsername = YES;
        }

        if ([[[[FRSUserManager sharedInstance] authenticatedUser] email] isEqual:[NSNull null]] || [[[[FRSUserManager sharedInstance] authenticatedUser] email] isEqualToString:@""] || ![[[FRSUserManager sharedInstance] authenticatedUser] email]) {
            userHasEmail = NO;
        } else {
            userHasEmail = YES;
        }

        self.height = 0;
        self.frame = CGRectMake(0, 0, ALERT_WIDTH, 0);
        [self configureDarkOverlay];

        self.backgroundColor = [UIColor frescoBackgroundColorLight];

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ALERT_WIDTH, 44)];
        [self.titleLabel setFont:[UIFont notaBoldWithSize:17]];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = @"NEW STUFF!";
        self.titleLabel.alpha = .87;
        [self addSubview:self.titleLabel];

        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - MESSAGE_WIDTH) / 2, 44, MESSAGE_WIDTH, 0)];
        self.messageLabel.alpha = .54;
        self.messageLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.text = [NSString stringWithFormat:@"We’ve added a ton of new\nfeatures for Fresco 3.0. You can now %@, %@, and %@ on galleries, %@ your friends and favorite photographers, and see more about assignments.\n\nTo start, we’ll need you to choose a username. You’ll be able to change it later on.", @"like", @"repost", @"comment", @"follow"];
        NSRange range1 = [self.messageLabel.text rangeOfString:@"like"];
        NSRange range2 = [self.messageLabel.text rangeOfString:@"repost"];
        NSRange range3 = [self.messageLabel.text rangeOfString:@"comment"];
        NSRange range4 = [self.messageLabel.text rangeOfString:@"follow"];
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:self.messageLabel.text];
        [attributedText setAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightMedium] } range:range1];
        [attributedText setAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightMedium] } range:range2];
        [attributedText setAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightMedium] } range:range3];
        [attributedText setAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightMedium] } range:range4];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:attributedText.string];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:2];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedText.string length])];

        self.messageLabel.attributedText = attributedText;
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        [self.messageLabel sizeToFit];
        self.messageLabel.frame = CGRectMake(self.messageLabel.frame.origin.x, self.messageLabel.frame.origin.y, MESSAGE_WIDTH, self.messageLabel.frame.size.height);
        [self addSubview:self.messageLabel];

        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 336, ALERT_WIDTH, 0.5)];
        line.backgroundColor = [UIColor colorWithWhite:0 alpha:0.12];
        [self addSubview:line];

        self.actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.actionButton addTarget:self action:@selector(logoutTapped) forControlEvents:UIControlEventTouchUpInside];
        self.actionButton.frame = CGRectMake(16, 337, 54, 44);
        [self.actionButton setTitleColor:[UIColor frescoRedColor] forState:UIControlStateNormal];
        [self.actionButton setTitle:@"LOG OUT" forState:UIControlStateNormal];
        [self.actionButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self addSubview:self.actionButton];

        self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.cancelButton.frame = CGRectMake(169, self.actionButton.frame.origin.y, 37, 44);
        [self.cancelButton addTarget:self action:@selector(updateUserInfo) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        [self.cancelButton setTitle:@"DONE" forState:UIControlStateNormal];
        self.cancelButton.enabled = NO;
        [self.cancelButton.titleLabel setFont:[UIFont notaBoldWithSize:15]];
        [self.cancelButton sizeToFit];
        [self.cancelButton setFrame:CGRectMake(self.frame.size.width - self.cancelButton.frame.size.width - 32, self.cancelButton.frame.origin.y, self.cancelButton.frame.size.width + 32, 44)];
        [self addSubview:self.cancelButton];

        UIView *usernameContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 248, self.frame.size.width, 44)];
        [self addSubview:usernameContainer];
        UIView *usernameTopLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
        usernameTopLine.backgroundColor = [UIColor frescoShadowColor];
        [usernameContainer addSubview:usernameTopLine];
        UIView *emailContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 44 * 3, self.frame.size.width, 44)];
        [self addSubview:emailContainer];
        UIView *emailTopLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
        emailTopLine.backgroundColor = [UIColor frescoShadowColor];
        [emailContainer addSubview:emailTopLine];

        self.usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(16, 11, self.frame.size.width - (16 + 16), 20)];
        [self.usernameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.usernameTextField.tag = 1;
        self.usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.usernameTextField.placeholder = @"@username";
        self.usernameTextField.tintColor = [UIColor frescoBlueColor];
        self.usernameTextField.delegate = self;
        self.usernameTextField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        self.usernameTextField.textColor = [UIColor frescoDarkTextColor];
        self.usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        [usernameContainer addSubview:self.usernameTextField];

        self.usernameCheckIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-red"]];
        self.usernameCheckIV.frame = CGRectMake(usernameContainer.frame.size.width - 24 - 6, 10, 24, 24);
        self.usernameCheckIV.alpha = 0;
        [usernameContainer addSubview:self.usernameCheckIV];

        self.usernameTakenLabel = [[UILabel alloc] initWithFrame:CGRectMake(-44 - 6, 5, 44, 17)];
        self.usernameTakenLabel.text = @"TAKEN";
        self.usernameTakenLabel.alpha = 0;
        self.usernameTakenLabel.textColor = [UIColor frescoRedColor];
        self.usernameTakenLabel.font = [UIFont notaBoldWithSize:15];
        [self.usernameCheckIV addSubview:self.usernameTakenLabel];

        self.emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(16, 11, self.frame.size.width - (16 + 16), 20)];
        [self.emailTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.emailTextField.tag = 2;
        self.emailTextField.placeholder = @"Email address";
        self.emailTextField.tintColor = [UIColor frescoBlueColor];
        self.emailTextField.delegate = self;
        self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        self.emailTextField.textColor = [UIColor frescoDarkTextColor];
        self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.emailTextField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        [emailContainer addSubview:self.emailTextField];

        self.emailCheckIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-red"]];
        self.emailCheckIV.frame = CGRectMake(emailContainer.frame.size.width - 24 - 6, 10, 24, 24);
        self.emailCheckIV.alpha = 0;
        [emailContainer addSubview:self.emailCheckIV];

        if (userHasEmail) {
            emailContainer.alpha = 0;
            self.height -= 44;
            self.emailTextField = nil;
            [self.emailTextField removeFromSuperview];
        }

        if (userHasUsername) {
            usernameContainer.alpha = 0;
            self.height -= 44;
            self.usernameTextField = nil;
            [self.usernameTextField removeFromSuperview];
        }

        UIView *passwordContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 44, self.frame.size.width, 44)];
        if (!userHasPassword) {
            self.migrationAlertShouldShowPassword = YES;
            self.height += 44;
            [self addSubview:passwordContainer];

            UIView *passwordTopLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
            passwordTopLine.backgroundColor = [UIColor frescoShadowColor];
            [passwordContainer addSubview:passwordTopLine];

            self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(16, 11, self.frame.size.width - (16 + 16), 20)];
            [self.passwordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            self.passwordTextField.tag = 3;
            if ([[FRSAuthManager sharedInstance] socialUsed]) {
                self.passwordTextField.placeholder = @"Set a New Password";
            } else {
                self.passwordTextField.placeholder = @"Confirm Password";
            }
            self.passwordTextField.tintColor = [UIColor frescoBlueColor];
            self.passwordTextField.delegate = self;
            self.passwordTextField.keyboardType = UIKeyboardTypeDefault;
            self.passwordTextField.secureTextEntry = YES;
            self.passwordTextField.textColor = [UIColor frescoDarkTextColor];
            self.passwordTextField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            [passwordContainer addSubview:self.passwordTextField];

            if (emailContainer.alpha == 0) {
                passwordContainer.transform = CGAffineTransformMakeTranslation(0, -44);
            }
        }

        self.dismissKeyboardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [[UIApplication sharedApplication].keyWindow addGestureRecognizer:self.dismissKeyboardTap];

        self.height += 380;

        NSInteger xOrigin = ([UIScreen mainScreen].bounds.size.width - ALERT_WIDTH) / 2;
        NSInteger yOrigin = ([UIScreen mainScreen].bounds.size.height - self.height) / 2;

        self.cancelButton.frame = CGRectMake(self.cancelButton.frame.origin.x, self.height - 44, self.cancelButton.frame.size.width, self.cancelButton.frame.size.height);
        self.actionButton.frame = CGRectMake(self.actionButton.frame.origin.x, self.height - 44, self.actionButton.frame.size.width, self.actionButton.frame.size.height);
        line.frame = CGRectMake(line.frame.origin.x, self.height - 44, line.frame.size.width, line.frame.size.height);
        self.frame = CGRectMake(xOrigin, yOrigin, ALERT_WIDTH, self.height);

        [self addShadowAndClip];

        [self animateIn];

        //Only updating username
        if (userHasPassword && userHasEmail && !userHasUsername) {
            usernameContainer.frame = CGRectMake(0, self.frame.size.height - 44 * 2, self.frame.size.width, 44);

            return self;
        }

        //Only updaing email
        if (userHasPassword && !userHasEmail && userHasUsername) {
            emailContainer.frame = CGRectMake(0, self.frame.size.height - 44 * 2, self.frame.size.width, 44);
            return self;
        }

        //Only updating password
        if (!userHasPassword && userHasEmail && userHasUsername) {
            passwordContainer.frame = CGRectMake(0, self.frame.size.height - 44 * 2, self.frame.size.width, 44);
            return self;
        }

        //Updating password and username
        if (!userHasPassword && userHasEmail && !userHasUsername) {
            usernameContainer.frame = CGRectMake(0, self.frame.size.height - 44 * 3, self.frame.size.width, 44);
            passwordContainer.frame = CGRectMake(0, self.frame.size.height - 44 * 2, self.frame.size.width, 44);
            return self;
        }

        //Updating password and email
        if (!userHasPassword && !userHasEmail && userHasUsername) {
            emailContainer.frame = CGRectMake(0, self.frame.size.height - 44 * 3, self.frame.size.width, 44);
            passwordContainer.frame = CGRectMake(0, self.frame.size.height - 44 * 2, self.frame.size.width, 44);
            return self;
        }

        //Updating username and email
        if (userHasPassword && !userHasEmail && !userHasUsername) {
            usernameContainer.frame = CGRectMake(0, self.frame.size.height - 44 * 3, self.frame.size.width, 44);
            emailContainer.frame = CGRectMake(0, self.frame.size.height - 44 * 2, self.frame.size.width, 44);
            return self;
        }

        //Updaing username, email, and password
        if (!userHasPassword && !userHasEmail && !userHasUsername) {
            usernameContainer.frame = CGRectMake(0, self.frame.size.height - 44 * 4, self.frame.size.width, 44);
            emailContainer.frame = CGRectMake(0, self.frame.size.height - 44 * 3, self.frame.size.width, 44);
            passwordContainer.frame = CGRectMake(0, self.frame.size.height - 44 * 2, self.frame.size.width, 44);
            return self;
        }
    }
    return self;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {

    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{

                       if (self.migrationAlertShouldShowPassword) {
                           self.transform = CGAffineTransformMakeTranslation(0, -100);
                       } else {
                           self.transform = CGAffineTransformMakeTranslation(0, -80);
                       }

                     }
                     completion:nil];

    if (self.emailTextField.isEditing) {
        self.emailCheckIV.alpha = 0;
    }

    if (textField.tag == 1) {
        [self startUsernameTimer];
        if ([textField.text isEqualToString:@""]) {
            textField.text = @"@";
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {

    if (textField == self.usernameTextField) {

        if ([textField.text isEqualToString:@"@"]) {
            textField.text = @"";
        }
    }

    if ((textField == self.emailTextField) && ([self.emailTextField.text isValidEmail])) {
        [self checkEmail];
    }

    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{

                       self.transform = CGAffineTransformMakeTranslation(0, 0);

                     }
                     completion:nil];
}

- (void)textFieldDidChange:(UITextField *)textField {
    if ((textField == self.emailTextField) && ([self.emailTextField.text isValidEmail])) {
        [self checkEmail];
    }

    if (textField == self.usernameTextField) {
        if ([textField.text isEqualToString:@"@"]) {
            [self checkCreateAccountButtonState];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    if (self.usernameTextField.isEditing) {
        [self startUsernameTimer];

        if ([[self.usernameTextField.text substringFromIndex:1] isEqualToString:@""]) {
            [self animateUsernameCheckImageView:self.usernameCheckIV animateIn:NO success:NO];
        }
    }

    [self checkCreateAccountButtonState];

    if (textField.tag == 1) {

        if ([string containsString:@" "]) {
            return NO;
        }

        if (textField.text.length == 1 && [string isEqualToString:@""]) {
            return NO;
        }

        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return newLength <= 20;
    }

    return YES;
}

- (void)tap {
    [self resignFirstResponder];
    [self endEditing:YES];
}

- (void)updateUserInfo {

    [self checkEmail];

    [[UIApplication sharedApplication].keyWindow removeGestureRecognizer:self.dismissKeyboardTap];

    NSMutableDictionary *digestion = [[NSMutableDictionary alloc] init];

    NSString *username = [self.usernameTextField.text stringByReplacingOccurrencesOfString:@"@" withString:@""];
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;

    if (email != nil) {
        [digestion setObject:email forKey:@"email"];
    }

    if (username != nil) {
        [digestion setObject:username forKey:@"username"];
    }

    // if ([[FRSAPIClient sharedClient] passwordUsed]) {
    //     [digestion setObject:[[FRSAPIClient sharedClient] passwordUsed] forKey:@"verify_password"];
    // } else if (password){
    //  [digestion setObject:password forKey:@"verify_password"];
    //}

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"twitter-connected"];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"needs-password"]) {
        [digestion setObject:password forKey:@"password"];
    }

    DGElasticPullToRefreshLoadingViewCircle *spinner = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];

    self.cancelButton.alpha = 0;
    spinner.frame = CGRectMake(self.frame.size.width - 20 - 10, self.frame.size.height - 20 - 10, 20, 20);
    spinner.tintColor = [UIColor frescoOrangeColor];
    [spinner setPullProgress:90];
    [spinner startAnimating];
    [self addSubview:spinner];

    [[FRSUserManager sharedInstance] updateLegacyUserWithDigestion:digestion
                                                        completion:^(id responseObject, NSError *error) {
                                                          [[FRSUserManager sharedInstance] saveUserFields:responseObject];

                                                          if (responseObject && !error) {
                                                              [[NSUserDefaults standardUserDefaults] setValue:nil forKey:userNeedsToMigrate];
                                                              [[NSUserDefaults standardUserDefaults] setBool:true forKey:userHasFinishedMigrating];
                                                              [[NSUserDefaults standardUserDefaults] synchronize];
                                                          }

                                                          spinner.alpha = 0;
                                                          [spinner stopLoading];
                                                          [spinner removeFromSuperview];
                                                          self.cancelButton.alpha = 1;

                                                          if (error) {
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                [spinner stopLoading];
                                                                [spinner removeFromSuperview];
                                                                [self.cancelButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
                                                              });

                                                              if (error) {
                                                                  FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"OOPS" message:@"Something’s wrong on our end. Sorry about that!" actionTitle:@"CANCEL" cancelTitle:@"TRY AGAIN" cancelTitleColor:[UIColor frescoBlueColor] delegate:nil];
                                                                  [alert show];

                                                                  return;
                                                              }

                                                              if (responseObject) {

                                                                  if ([self.usernameTextField isEqual:[NSNull null]] || ![self.usernameTextField.text isEqualToString:@""]) {
                                                                      [[FRSUserManager sharedInstance] authenticatedUser].username = [self.usernameTextField.text substringFromIndex:1];
                                                                  }

                                                                  if ([self.emailTextField isEqual:[NSNull null]] || ![self.emailTextField.text isEqualToString:@""]) {
                                                                      [[FRSUserManager sharedInstance] authenticatedUser].email = self.emailTextField.text;
                                                                  }
                                                              }
                                                          }

                                                          [self dismiss];
                                                        }];
}

- (void)checkEmail {
    //Prepopulated from login
    if (!self.emailTextField.userInteractionEnabled) {
        return;
    }

    [[FRSUserManager sharedInstance] checkEmail:self.emailTextField.text
                                     completion:^(id responseObject, NSError *error) {

                                       if (!error) {
                                           self.emailTaken = YES;
                                           [self shouldShowEmailError:YES];
                                       } else {
                                           self.emailTaken = NO;
                                           [self shouldShowEmailError:NO];
                                       }

                                       [self checkCreateAccountButtonState];
                                     }];
}

- (void)shouldShowEmailError:(BOOL)error {
    if (error) {
        self.emailCheckIV.alpha = 1;
    } else {
        self.emailCheckIV.alpha = 0;
    }
}

- (void)startUsernameTimer {
    if (!self.usernameTimer) {
        self.usernameTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(usernameTimerFired) userInfo:nil repeats:YES];
    }
}

- (void)stopUsernameTimer {
    if ([self.usernameTimer isValid]) {
        [self.usernameTimer invalidate];
    }
    self.usernameTimer = nil;
}

- (void)usernameTimerFired {

    if ([self.usernameTextField.text isEqualToString:@""]) {
        self.usernameCheckIV.alpha = 0;
        self.usernameTakenLabel.alpha = 0;
        [self stopUsernameTimer];
        return;
    }

    // Check for emoji and error
    if ([[self.usernameTextField.text substringFromIndex:1] stringContainsEmoji]) {
        [self animateUsernameCheckImageView:self.usernameCheckIV animateIn:YES success:NO];
        return;
    }

    if (self.usernameTextField.isEditing && (![[self.usernameTextField.text substringFromIndex:1] stringContainsEmoji])) {
        if ((![[self.usernameTextField.text substringFromIndex:1] isEqualToString:@""])) {
            [[FRSUserManager sharedInstance] checkUsername:[self.usernameTextField.text substringFromIndex:1]
                                                completion:^(id responseObject, NSError *error) {
                                                  //Return if no internet
                                                  if (error.code == -1009) {
                                                      return;
                                                  }
                                                  NSHTTPURLResponse *response = error.userInfo[@"com.alamofire.serialization.response.error.response"];
                                                  NSInteger responseCode = response.statusCode;

                                                  if (responseCode == 404) { //
                                                      [self animateUsernameCheckImageView:self.usernameCheckIV animateIn:YES success:YES];
                                                      self.usernameTaken = NO;
                                                      [self stopUsernameTimer];
                                                      [self checkCreateAccountButtonState];
                                                      return;
                                                  } else {
                                                      [self animateUsernameCheckImageView:self.usernameCheckIV animateIn:YES success:NO];
                                                      self.usernameTaken = YES;
                                                      [self stopUsernameTimer];
                                                      [self checkCreateAccountButtonState];
                                                  }
                                                }];
        }
    }
}

- (void)animateUsernameCheckImageView:(UIImageView *)imageView animateIn:(BOOL)animateIn success:(BOOL)success {

    if (success) {
        self.usernameCheckIV.image = [UIImage imageNamed:@""];
        self.usernameTakenLabel.alpha = 0;
    } else {
        self.usernameCheckIV.image = [UIImage imageNamed:@"check-red"];
        self.usernameTakenLabel.alpha = 1;
    }

    if (animateIn) {
        if (self.usernameCheckIV.alpha == 0) {

            self.usernameCheckIV.transform = CGAffineTransformMakeScale(0.001, 0.001);
            self.usernameCheckIV.alpha = 0;
            self.usernameCheckIV.alpha = 1;
            self.usernameCheckIV.transform = CGAffineTransformMakeScale(1.05, 1.05);
            self.usernameCheckIV.transform = CGAffineTransformMakeScale(1, 1);
        }
    } else {

        self.usernameCheckIV.transform = CGAffineTransformMakeScale(1.1, 1.1);
        self.usernameCheckIV.transform = CGAffineTransformMakeScale(0.001, 0.001);
        self.usernameCheckIV.alpha = 0;
    }
}

- (void)checkCreateAccountButtonState {
    UIControlState controlState;

    //Only updating username
    if (!self.passwordTextField && !self.emailTextField && self.usernameTextField) {
        if ([[self.usernameTextField.text substringFromIndex:1] isValidUsername] && (!self.usernameTaken)) {
            controlState = UIControlStateHighlighted;
        } else {
            controlState = UIControlStateNormal;
        }
        [self toggleCreateAccountButtonTitleColorToState:controlState];
    }

    //Only updaing email
    if (!self.passwordTextField && self.emailTextField && !self.usernameTextField) {
        if ([self.emailTextField.text isValidEmail] && (!self.emailTaken)) {
            controlState = UIControlStateHighlighted;
        } else {
            controlState = UIControlStateNormal;
        }
        [self toggleCreateAccountButtonTitleColorToState:controlState];
    }

    //Only updating password
    if (self.passwordTextField && !self.emailTextField && !self.usernameTextField) {
        if ([self.passwordTextField.text length] >= 6) {
            controlState = UIControlStateHighlighted;
        } else {
            controlState = UIControlStateNormal;
        }
        [self toggleCreateAccountButtonTitleColorToState:controlState];
    }

    //Updating password and username
    if (self.passwordTextField && !self.emailTextField && self.usernameTextField) {
        if ([self.passwordTextField.text length] >= 6 && [[self.usernameTextField.text substringFromIndex:1] isValidUsername] && (!self.usernameTaken)) {
            controlState = UIControlStateHighlighted;
        } else {
            controlState = UIControlStateNormal;
        }
        [self toggleCreateAccountButtonTitleColorToState:controlState];
    }

    //Updating password and email
    if (self.passwordTextField && self.emailTextField && !self.usernameTextField) {
        if ([self.passwordTextField.text length] >= 6 && [self.emailTextField.text isValidEmail] && (!self.emailTaken)) {
            controlState = UIControlStateHighlighted;
        } else {
            controlState = UIControlStateNormal;
        }
        [self toggleCreateAccountButtonTitleColorToState:controlState];
    }

    //Updating username and email
    if (!self.passwordTextField && self.emailTextField && self.usernameTextField) {
        if ([[self.usernameTextField.text substringFromIndex:1] isValidUsername] && (!self.usernameTaken) && [self.emailTextField.text isValidEmail] && (!self.emailTaken)) {
            controlState = UIControlStateHighlighted;
        } else {
            controlState = UIControlStateNormal;
        }
        [self toggleCreateAccountButtonTitleColorToState:controlState];
    }

    //Updaing username, email, and password
    if (self.passwordTextField && self.emailTextField && self.usernameTextField) {
        if ([[self.usernameTextField.text substringFromIndex:1] isValidUsername] && (!self.usernameTaken) && [self.emailTextField.text isValidEmail] && (!self.emailTaken) && [self.passwordTextField.text length] >= 6) {
            controlState = UIControlStateHighlighted;
        } else {
            controlState = UIControlStateNormal;
        }
        [self toggleCreateAccountButtonTitleColorToState:controlState];
    }
}

- (void)toggleCreateAccountButtonTitleColorToState:(UIControlState)controlState {
    if (controlState == UIControlStateNormal) {
        [self.cancelButton setTitleColor:[UIColor frescoLightTextColor] forState:UIControlStateNormal];
        self.cancelButton.enabled = NO;
    } else {
        [self.cancelButton setTitleColor:[UIColor frescoBlueColor] forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[[UIColor frescoBlueColor] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
        self.cancelButton.enabled = YES;
    }
}

@end
