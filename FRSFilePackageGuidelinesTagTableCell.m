//
//  FRSFilePackageGuidelinesTagTableCell.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 6/9/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFilePackageGuidelinesTagTableCell.h"

@interface FRSFilePackageGuidelinesTagTableCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;

@property (strong, nonatomic) FRSFileTagOptionsViewModel *viewModel;

@end

@implementation FRSFilePackageGuidelinesTagTableCell

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
}

@end
