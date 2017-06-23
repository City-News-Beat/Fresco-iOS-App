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

- (void)configureWithStory:(FRSUserStoryDetailHeaderCellViewModel *)userStoryDetailHeaderCellViewModel{

//    self.titleLabel.text = userStory.title;
//    self.userImageView.image = userStory.creator.profileImage;
//    self.userNameLabel.text = userStory.creator.firstName;
//    self.timestampLabel.text = [NSString stringWithFormat:@"%@", userStory.createdDate];
//    self.captionTextView.text = userStory.caption;
    
    
    
    // DEBUG
    
//    [[FRSAPIClient sharedClient] get:@"story/highlights" withParameters:@{@"rating" : @2, @"sortBy" : @"highlighted"} completion:^(id responseObject, NSError *error) {
//
//    }];
    
    self.titleLabel.text = userStoryDetailHeaderCellViewModel.title;
    self.userNameLabel.text = userStoryDetailHeaderCellViewModel.userName;
    self.timestampLabel.text = @"1 day ago • Updated 12:03 a.m";
    self.captionTextView.text = @"The wait is nearly over: after just over two weeks of voting, Vancouver is set to announce its official city bird on Thursday. There are four west coast species in the running to be named official spokesbird: Anna’s hummingbird, the varied thrush, the spotted towhee and the northern flicker, each of which is thought to embody the spirit of Vancouver in some way.\n\nThe wait is nearly over: after just over two weeks of voting, Vancouver is set to announce its official city bird on Thursday. There are four west coast species in the running to be named official spokesbird: Anna’s hummingbird, the varied thrush, the spotted towhee and the northern flicker, each of which is thought to embody the spirit of Vancouver in some way.";
    self.titleLabel.text = @"Wild Elephant Eats Small Bird Without Fork";
    self.userNameLabel.text = @"First Last";
    self.timestampLabel.text = @"1 day ago • Updated 12:03 a.m";
    self.captionTextView.text = @"The wait is nearly over: after just over two weeks of voting, Vancouver is set to announce its official city bird on Thursday. There are four west coast species in the running to be named official spokesbird: Anna’s hummingbird, the varied thrush, the spotted towhee and the northern flicker, each of which is thought to embody the spirit of Vancouver in some way.\n\nThe wait is nearly over: after just over two weeks of voting, Vancouver is set to announce its official city bird on Thursday. There are four west coast species in the running to be named official spokesbird: Anna’s hummingbird, the varied thrush, the spotted towhee and the northern flicker, each of which is thought to embody the spirit of Vancouver in some way.";
}

@end
