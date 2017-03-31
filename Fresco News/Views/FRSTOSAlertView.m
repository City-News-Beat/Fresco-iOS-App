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

@interface FRSTOSAlertView () <UITextFieldDelegate, UIScrollViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) UIView *actionLine;

@property (strong, nonatomic) UIButton *expandTOSButton;
@property (strong, nonatomic) UITextView *TOSTextView;
@property (strong, nonatomic) UIView *topLine;

@end

@implementation FRSTOSAlertView

- (instancetype)initWithTOS:(NSString *)tos {
    self = [super init];

    if (self) {
        if (![FRSUserManager sharedInstance].authenticatedUser) {
            return nil;
        }

        /* Title Label */
        [self configureWithTitle:@"UPDATED TERMS"];

        /* TOS Text View */
        self.TOSTextView = [[UITextView alloc] initWithFrame:CGRectMake((self.frame.size.width - MESSAGE_WIDTH) / 2, 44, MESSAGE_WIDTH, 320)];
        self.TOSTextView.textColor = [UIColor frescoMediumTextColor];
        self.TOSTextView.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        self.TOSTextView.textAlignment = NSTextAlignmentLeft;
        self.TOSTextView.backgroundColor = [UIColor clearColor];
        self.TOSTextView.editable = NO;
        self.TOSTextView.delegate = self;
        [self addSubview:self.TOSTextView];

        NSString *TOS = tos;
        TOS = [TOS stringByReplacingOccurrencesOfString:@"�" withString:@"\""];
        self.TOSTextView.text = TOS;

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

        /* Actions */
        [self configureWithLeftActionTitle:@"LOG OUT" withColor:[UIColor frescoRedColor] andRightCancelTitle:@"ACCEPT" withColor:nil];
        
        self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - ALERT_WIDTH / 2, [UIScreen mainScreen].bounds.size.height / 2 - 408 / 2, ALERT_WIDTH, 408);
        self.actionLine.frame = CGRectMake(0, self.frame.size.height - 43.5, ALERT_WIDTH, 0.5);
        
        /* Left Action */
        self.actionButton.frame = CGRectMake(self.actionButton.frame.origin.x, self.TOSTextView.frame.origin.y + self.TOSTextView.frame.size.height, 54, 44);
        
        /* Right Action */
        self.cancelButton.frame = CGRectMake(self.frame.size.width - 49 - 16, self.actionButton.frame.origin.y, 49, 44);

    }
    return self;
}

- (void)expandTOS {
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
}

- (void)acceptTapped {
    [[FRSUserManager sharedInstance] acceptTermsWithCompletion:^(id responseObject, NSError *error) {
      if (!error) {
          [self dismiss];
      } else {
          FRSAlertView *alert = [[FRSAlertView alloc] initWithTitle:@"OOPS" message:@"Something’s wrong on our end. Sorry about that!" actionTitle:@"CANCEL" cancelTitle:@"TRY AGAIN" cancelTitleColor:nil delegate:nil];
          [alert show];
      }
    }];
}

- (void)logoutTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(logoutAlertAction)]) {
        [self.delegate logoutAlertAction];
    }
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

#pragma mark - Overrides

- (void)leftActionTapped {
    [super leftActionTapped];
    [self logoutTapped];
}

- (void)rightCancelTapped {
    [super rightCancelTapped];
    [self acceptTapped];
}

@end
