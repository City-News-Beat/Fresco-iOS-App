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


}

-(void)configureCell {
    if (self.backgroundViewColor == nil) {
        self.backgroundColor = [UIColor frescoBackgroundColorLight];
    }
    
    self.titleLabel.numberOfLines = 0;
    self.bodyLabel.numberOfLines  = 0;
    
    self.image.backgroundColor = [UIColor frescoLightTextColor];
    self.image.layer.cornerRadius = 20;
    
    self.annotationView.layer.cornerRadius = 12;
    
    if (self.count <= 1) {
        self.annotationView.alpha = 0;
    } else if (self.count <= 9) {
        self.annotationLabel.text = [NSString stringWithFormat:@"+%ld", self.count];
    } else {
        self.annotationLabel.text = @"+";
    }
}


-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

@end
