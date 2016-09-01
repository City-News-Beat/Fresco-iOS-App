//
//  FRSTextNotificationTableViewCell.m
//  Fresco
//
//  Created by Omar Elfanek on 8/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSTextNotificationTableViewCell.h"
#import "UIColor+Fresco.h"

@interface FRSTextNotificationTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *line;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;

@end

@implementation FRSTextNotificationTableViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    //UITableViewCell subviews' background colors turn to clearColor when selecting/highlighting.
    //Setting the background color overrides this
    self.line.backgroundColor = [UIColor frescoLightTextColor];
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    //UITableViewCell subviews' background colors turn to clearColor when selecting/highlighting.
    //Setting the background color overrides this
    self.line.backgroundColor = [UIColor frescoLightTextColor];
}

-(void)configureTextCell:(NSString *)text {
    
    self.bodyLabel.text = text;
    self.bodyLabel.numberOfLines = 0;
}

@end
