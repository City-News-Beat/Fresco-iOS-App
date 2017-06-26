//
//  FRSUserStoryDetailHeaderTableViewCell.m
//  Fresco
//
//  Created by Omar Elfanek on 6/21/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSUserStoryDetailHeaderTableViewCell.h"
#import "FRSDateFormatter.h"

@interface FRSUserStoryDetailHeaderTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;

@property (strong, nonatomic) FRSUserStoryDetailHeaderCellViewModel *userStoryDetailHeaderCellViewModel;

@end

@implementation FRSUserStoryDetailHeaderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithStoryHeaderCellViewModel:(FRSUserStoryDetailHeaderCellViewModel *)viewModel {
    
    self.userStoryDetailHeaderCellViewModel = viewModel;
    
    self.userImageView.image = viewModel.creator.profileImage; // Needs to be formatted
    self.userNameLabel.text = viewModel.creator.firstName != nil ? viewModel.creator.firstName : viewModel.creator.username;
    self.captionTextView.text = viewModel.caption;
    self.titleLabel.attributedText = [self formattedTitleLabelAttributedString];
    self.timestampLabel.text = [self formattedTimestampString];
}

#pragma mark - Private
- (NSAttributedString *)formattedTitleLabelAttributedString {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    return [[NSAttributedString alloc] initWithString:self.userStoryDetailHeaderCellViewModel.title attributes: @{ NSParagraphStyleAttributeName: paragraphStyle }];
}

- (NSString *)formattedTimestampString {
    
    if (self.userStoryDetailHeaderCellViewModel.editedDate) {
        return [NSString stringWithFormat:@"%@ • Updated %@", [FRSDateFormatter timestampStringFromDate:self.userStoryDetailHeaderCellViewModel.createdDate], [FRSDateFormatter timestampStringFromDate:self.userStoryDetailHeaderCellViewModel.editedDate]];
    } else {
        return [FRSDateFormatter timestampStringFromDate:self.userStoryDetailHeaderCellViewModel.createdDate];
    }
}

@end
