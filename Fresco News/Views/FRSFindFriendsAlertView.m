//
//  FRSFindFriendsAlertView.m
//  Fresco
//
//  Created by Maurice Wu on 3/12/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFindFriendsAlertView.h"
#import "UIFont+Fresco.h"

@interface FRSFindFriendsAlertView()

@end

@implementation FRSFindFriendsAlertView

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
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

@end
