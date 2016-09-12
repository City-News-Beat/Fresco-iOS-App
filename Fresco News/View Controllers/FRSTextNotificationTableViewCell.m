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
@property (nonatomic) NSInteger generatedHeight;

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

-(NSInteger)heightForCell {
    
    if (_generatedHeight) {
        return _generatedHeight;
    }

    _generatedHeight = 0;
    
    int topPadding   = 10;
    int leftPadding  = 72;
    int rightPadding = 16;
    
    self.label.numberOfLines = 0;
    [self.label sizeToFit];
    self.label.frame = CGRectMake(leftPadding, topPadding, self.frame.size.width -leftPadding -rightPadding, 22);
    
    topPadding = 33;
    
    [self.label sizeToFit];
    
    _generatedHeight += self.label.frame.size.height;
    _generatedHeight += 8; //spacing
    
    return _generatedHeight;
}

@end
