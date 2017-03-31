//
//  FRSSignUpAlertView.m
//  Fresco
//
//  Created by Maurice Wu on 3/8/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSSignUpAlertView.h"
#import "UIFont+Fresco.h"

@interface FRSSignUpAlertView()

@end

@implementation FRSSignUpAlertView

- (instancetype)initSignUpAlert {
    self = [super init];
    
    if (self) {
                
        /* Title Label */
        [self configureWithTitle:@"WAIT, DON'T GO"];
        
        /* Body Label */
        [self configureWithMessage:@"Are you sure you don’t want to sign up for Fresco?"];
        
        /* Action Shadow */
        [self configureWithLineViewAtYposition:self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 14.5];
        
        /* Actions */
        [self configureWithLeftActionTitle:@"CANCEL" withColor:[UIColor frescoDarkTextColor] andRightCancelTitle:@"DELETE" withColor:[UIColor frescoRedColor]];
        
        self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - ALERT_WIDTH / 2, [UIScreen mainScreen].bounds.size.height / 2 - 70, ALERT_WIDTH, 140);
        
    }
    return self;
}

- (void)returnToPreviousViewController {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"returnToPreviousViewController" object:self];
    
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:facebookName];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:facebookConnected];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:twitterConnected];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:twitterHandle];
}

#pragma mark - Overrides

- (void)rightCancelTapped {
    [super rightCancelTapped];
    [self returnToPreviousViewController];
}

@end
