//
//  FRSFileTagOptionsTableViewCell.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/31/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFileTagOptionsTableViewCell.h"

@interface FRSFileTagOptionsTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation FRSFileTagOptionsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateWithViewModel:(FRSFileTagOptionsViewModel *)viewModel {
    self.nameLabel.text = viewModel.nameText;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
