//
//  FRSTOSAlertView.m
//  Fresco
//
//  Created by Maurice Wu on 3/12/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSTOSAlertView.h"
#import "UIFont+Fresco.h"
#import "FRSUserManager.h"

#define ALERT_WIDTH 270
#define MESSAGE_WIDTH 238

@interface FRSTOSAlertView () <UITextFieldDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UIView *overlayView;
@property (strong, nonatomic) UIView *buttonShadow;

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;

@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *actionButton;
@property (strong, nonatomic) UIView *actionLine;

@property (strong, nonatomic) UIButton *expandTOSButton;
@property (strong, nonatomic) UITextView *TOSTextView;
@property (strong, nonatomic) UIView *topLine;

@property (strong, nonatomic) UITapGestureRecognizer *dismissKeyboardTap;

@end

@implementation FRSTOSAlertView

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

- (void)configureDarkOverlay {
    /* Dark Overlay */
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    self.overlayView.backgroundColor = [UIColor blackColor];
    self.overlayView.alpha = 0;
    [self addSubview:(self.overlayView)];
}

- (void)show {
    /* keyWindow places the view above all. Add overlay view first, and then alertView*/
    [[UIApplication sharedApplication].keyWindow addSubview:self.overlayView];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self.inputViewController.view endEditing:YES];
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
          self.actionButton.alpha = 0;
          self.overlayView.alpha = 0;
          self.transform = CGAffineTransformMakeScale(0.9, 0.9);
        }
        completion:^(BOOL finished) {
          [self removeFromSuperview];
        }];
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

@end
