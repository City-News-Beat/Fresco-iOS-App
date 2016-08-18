//
//  FRSAssignmentNotificationTableViewCell.h
//  Fresco
//
//  Created by Omar Elfanek on 8/12/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSAssignmentNotificationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel  *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel  *bodyLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

-(void)configureCell;

@end
