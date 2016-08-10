//
//  FRSDefaultNotificationTableViewCell.m
//  Fresco
//
//  Created by Omar Elfanek on 8/10/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSDefaultNotificationTableViewCell.h"
#import "UIColor+Fresco.h"

@implementation FRSDefaultNotificationTableViewCell

-(void)awakeFromNib {
    [super awakeFromNib];

    
    self.backgroundColor = [UIColor frescoBackgroundColorLight];
    
    
    self.titleLabel.numberOfLines = 0;
    self.bodyLabel.numberOfLines  = 0;
    
    
    self.image.backgroundColor = [UIColor frescoLightTextColor];
    self.image.layer.cornerRadius = 20;
    
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
