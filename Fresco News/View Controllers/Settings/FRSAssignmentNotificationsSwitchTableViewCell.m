//
//  FRSAssignmentNotificationsSwitchTableViewCell.m
//  Fresco
//
//  Created by Maurice Wu on 2/18/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSAssignmentNotificationsSwitchTableViewCell.h"

@interface FRSAssignmentNotificationsSwitchTableViewCell ()

@property (nonatomic, weak) IBOutlet UISwitch *notificationSwitch;

@end

@implementation FRSAssignmentNotificationsSwitchTableViewCell

- (void)notificationsEnabled:(BOOL)enabled {
    [self.notificationSwitch setOn:enabled animated:NO];
}

- (IBAction)notificationToggle:(id)sender {
    [self.delegate didToggleNotifications:sender];
}

@end
