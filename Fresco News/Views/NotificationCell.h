//
//  AssignmentNotificationCell.h
//  FrescoNews
//
//  Created by Fresco News on 5/21/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;

@interface NotificationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *notificationDescription;
@property (weak, nonatomic) IBOutlet UILabel *eventName;
@property (weak, nonatomic) IBOutlet UILabel *timeElapsed;
@property (weak, nonatomic) IBOutlet UIButton *firstButton;
@property (weak, nonatomic) IBOutlet UIButton *secondButton;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintNotificationDescription;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintButton1Width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTimeElapsedTrailing;

@end