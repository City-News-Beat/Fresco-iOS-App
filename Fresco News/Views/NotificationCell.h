//
//  AssignmentNotificationCell.h
//  FrescoNews
//
//  Created by Fresco News on 5/21/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;

#import "FRSNotification.h"

@interface NotificationCell : UITableViewCell

typedef enum : NSUInteger {
    NotificationTypeContent,
    NotificationTypeAssignment,
    NotificationTypePayment
} NotificationType;


@property (strong, nonatomic) FRSNotification *notification;

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *notificationDescription;
@property (weak, nonatomic) IBOutlet UILabel *eventName;
@property (weak, nonatomic) IBOutlet UILabel *timeElapsed;
@property (weak, nonatomic) IBOutlet UIButton *firstButton;
@property (weak, nonatomic) IBOutlet UIButton *secondButton;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintDescriptionBottom;

@end