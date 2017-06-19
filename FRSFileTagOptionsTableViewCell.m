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
@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;

@property (strong, nonatomic) FRSFileTagOptionsViewModel *viewModel;

@end

@implementation FRSFileTagOptionsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor frescoBackgroundColorLight];
}

- (void)updateWithViewModel:(FRSFileTagOptionsViewModel *)viewModel {
    self.viewModel = viewModel;
    [self configureTitle];
    [self configureCheckMarkImageView];
}

-(void)configureCheckMarkImageView {
    self.checkmarkImageView.image = self.viewModel.isSelected ? self.viewModel.selectedImage : self.viewModel.unSelectedImage;
}

-(void)configureTitle {
    self.nameLabel.text = self.viewModel.nameText;
    self.nameLabel.font = self.viewModel.isSelected ? self.viewModel.selectedTitleFont : self.viewModel.unSelectedTitleFont;
}

@end
