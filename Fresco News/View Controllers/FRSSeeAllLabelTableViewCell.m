//
//  FRSSeeAllLabelTableViewCell.m
//  Fresco
//
//  Created by User on 2/12/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSSeeAllLabelTableViewCell.h"

@interface FRSSeeAllLabelTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *seeAllLabel;
@end

@implementation FRSSeeAllLabelTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setLabelText:(NSString *)labelText {
    self.seeAllLabel.text = labelText;
}

@end
