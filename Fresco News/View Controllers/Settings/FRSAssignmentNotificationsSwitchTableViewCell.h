//
//  FRSAssignmentNotificationsSwitchTableViewCell.h
//  Fresco
//
//  Created by Maurice Wu on 2/18/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const assignmentNotficationsSwitchCellIdentifier = @"assignment-notfications-switch-cell";
static CGFloat const assignmentNotficationsSwitchCellHeight = 62;

@protocol FRSAssignmentNotificationsSwitchTableViewCellDelegate <NSObject>

- (void)didToggleNotifications:(id)sender;

@end

@interface FRSAssignmentNotificationsSwitchTableViewCell : UITableViewCell

@property (weak, nonatomic) id<FRSAssignmentNotificationsSwitchTableViewCellDelegate> delegate;

- (void)notificationsEnabled:(BOOL)enabled;

@end
