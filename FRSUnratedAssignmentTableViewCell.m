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
    UIColor *color = self.indicatorCircle.backgroundColor;
    [super setSelected:selected animated:animated];
    
    if (selected){
        self.indicatorCircle.backgroundColor = color;
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    UIColor *color = self.indicatorCircle.backgroundColor;
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted){
        self.indicatorCircle.backgroundColor = color;
    }
}

@end
