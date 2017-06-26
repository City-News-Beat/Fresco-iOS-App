//
//  FRSUserStoryDetailHeaderTableViewCell.m
//  Fresco
//
//  Created by Omar Elfanek on 6/21/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSUserStoryDetailHeaderTableViewCell.h"

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
    
//    self.titleLabel.text = viewModel.title;
//    self.userImageView.image = viewModel.creator.profileImage; // Needs to be formatted
//    self.userNameLabel.text = viewModel.creator.username;
//    self.timestampLabel.text = [NSString stringWithFormat:@"%@", viewModel.createdDate]; // Needs to be formatted
//    [self configureCaptionTextViewFromString:viewModel.caption];
    
    // DEBUG
    self.titleLabel.text = @"Hungry Elephant is Denied Service From Local NYC Diner";
    self.userNameLabel.text = @"First Last";
    self.timestampLabel.text = @"1 day ago • Updated 12:03 a.m";
    [self configureCaptionTextViewFromString: @"The wait is nearly over: after just over two weeks of voting, Vancouver is set to announce its official city bird on Thursday. There are four west coast species in the running to be named official spokesbird: Anna’s hummingbird, the varied thrush, the spotted towhee and the northern flicker, each of which is thought to embody the spirit of Vancouver in some way.\n\nThe wait is nearly over: after just over two weeks of voting, Vancouver is set to announce its official city bird on Thursday. There are four west coast species in the running to be named official spokesbird: Anna’s hummingbird, the varied thrush, the spotted towhee and the northern flicker, each of which is thought to embody the spirit of Vancouver in some way."];
}

#pragma mark - Private
- (void)configureCaptionTextViewFromString:(NSString *)caption {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10;
    self.captionTextView.attributedText = [[NSAttributedString alloc] initWithString:caption attributes: @{ NSParagraphStyleAttributeName: paragraphStyle }];
}

@end
