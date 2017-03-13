//
//  FRSConnectivityAlertView.m
//  Fresco
//
//  Created by Maurice Wu on 3/11/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSConnectivityAlertView.h"
#import "UIFont+Fresco.h"

@interface FRSConnectivityAlertView()

@end

@implementation FRSConnectivityAlertView

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

- (void)settingsTapped {
    [self animateOut];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

@end
