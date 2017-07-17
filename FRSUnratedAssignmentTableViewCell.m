//
//  FRSUnratedAssignmentTableViewCell.m
//  Fresco
//
//  Created by Omar Elfanek on 7/11/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSUnratedAssignmentTableViewCell.h"

@implementation FRSUnratedAssignmentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.indicatorCircle.layer.cornerRadius = self.indicatorCircle.frame.size.width/2;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
