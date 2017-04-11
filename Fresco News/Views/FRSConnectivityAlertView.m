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
        
        /* Title Label */
        [self configureWithTitle:@"NO CONNECTION"];
        
        /* Body Label */
        [self configureWithMessage:@"Please check your internet connection."];
        
        /* Action Shadow */
        [self configureWithLineViewAtYposition:self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 14.5];
        
        /* Actions */
        [self configureWithLeftActionTitle:@"SETTINGS" withColor:nil andRightCancelTitle:@"OK" withColor:nil];

        [self adjustFrame];
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
    [self dismiss];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

#pragma mark - Overrides

- (void)leftActionTapped {
    [super leftActionTapped];
    [self settingsTapped];
}



@end
