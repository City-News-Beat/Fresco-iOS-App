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
                
        /* Title Label */
        [self configureWithTitle:@"NOT SURE WHO TO FOLLOW?"];
        
        /* Body Label */
        [self configureWithMessage:@"Connect your address book to find your friends on Fresco."];
        
        /* Action Shadow */
        [self configureWithLineViewAtYposition:self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 14.5];
        
        /* Actions */
        [self configureWithLeftActionTitle:@"NO THANKS" withColor:nil andRightCancelTitle:@"FIND FRIENDS" withColor:[UIColor frescoRedColor]];

        self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - ALERT_WIDTH / 2, [UIScreen mainScreen].bounds.size.height / 2 - 70, ALERT_WIDTH, 140);
    }
    return self;
}

- (void)requestContacts {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

#pragma mark - Overrides

- (void)rightCancelTapped {
    [super rightCancelTapped];
    [self requestContacts];
}

@end
