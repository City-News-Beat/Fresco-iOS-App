//
//  FRSAssignmentNotificationTableViewCell.m
//  Fresco
//
//  Created by Omar Elfanek on 8/12/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSAssignmentNotificationTableViewCell.h"

@implementation FRSAssignmentNotificationTableViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    
}

-(void)configureCell {
    self.titleLabel.numberOfLines = 0;
    self.bodyLabel.numberOfLines  = 0;
    self.assignmentButton.tintColor = [UIColor blackColor];
}

@end
