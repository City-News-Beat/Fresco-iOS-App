//
//  FRSUploadFailAlertView.m
//  Fresco
//
//  Created by Omar Elfanek on 3/29/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSUploadFailAlertView.h"
#import "UIFont+Fresco.h"
#import "FRSModerationManager.h"

@implementation FRSUploadFailAlertView

- (instancetype)initUploadFailAlertViewWithError:(NSError *)error {
    self = [super init];
    
    if (self) {
        /* Title Label */
        [self configureWithTitle:@"UPLOAD ERROR"];
        
        /* Body Label */
        [self configureWithMessage:error.localizedDescription != nil ? error.localizedDescription : @"Unable to upload gallery. Please try again later."];
        
        /* Action Shadow */
        [self configureWithLineViewAtYposition:self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 14.5];
        
        /* Actions */
        [self configureWithLeftActionTitle:@"CANCEL" withColor:nil andRightCancelTitle:@"GET HELP" withColor:[UIColor frescoBlueColor]];
        
        self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - ALERT_WIDTH / 2, [UIScreen mainScreen].bounds.size.height / 2 - 70, ALERT_WIDTH, 140);
    }
    
    return self;
}

- (void)getHelp {
    [self dismiss];
    [[FRSModerationManager sharedInstance] presentSmooch];
}

#pragma mark - Overrides

- (void)rightCancelTapped {
    [super rightCancelTapped];
    [self getHelp];
}

@end
