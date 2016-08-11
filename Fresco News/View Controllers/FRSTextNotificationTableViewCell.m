//
//  FRSTextNotificationTableViewCell.m
//  Fresco
//
//  Created by Omar Elfanek on 8/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSTextNotificationTableViewCell.h"
#import "UIColor+Fresco.h"

@implementation FRSTextNotificationTableViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureCell {
    
    self.bodyLabel.numberOfLines = 0;
    self.backgroundColor = [UIColor frescoBackgroundColorDark];
}

@end
