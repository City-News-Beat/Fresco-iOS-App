//
//  FRSFileSourcePickerTableViewCell.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/12/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFileSourcePickerTableViewCell.h"

@interface FRSFileSourcePickerTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;

@property (strong, nonatomic) FRSFileSourcePickerViewModel *viewModel;

@end

@implementation FRSFileSourcePickerTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor frescoBackgroundColorLight];
    
}

- (void)updateWithViewModel:(FRSFileSourcePickerViewModel *)viewModel {
    self.viewModel = viewModel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
    self.checkmarkImageView.image = selected ? self.viewModel.selectedImage : self.viewModel.unSelectedImage;
}

@end
