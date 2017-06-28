//
//  FRSUserStoryDetailMediaTableViewCell.m
//  Fresco
//
//  Created by Omar Elfanek on 6/22/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSUserStoryDetailMediaTableViewCell.h"

@implementation FRSUserStoryDetailMediaTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithStory:(FRSUserStory *)userStory {
    self.backgroundColor = [UIColor redColor];
}

@end
