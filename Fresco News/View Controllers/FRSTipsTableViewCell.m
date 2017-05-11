//
//  FRSTipsTableViewCell.m
//  Fresco
//
//  Created by Omar Elfanek on 5/11/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSTipsTableViewCell.h"

@implementation FRSTipsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
