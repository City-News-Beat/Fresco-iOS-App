//
//  FRSUserStoryDetailCommentsTableViewCell.m
//  Fresco
//
//  Created by Omar Elfanek on 6/22/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSUserStoryDetailCommentsTableViewCell.h"
#import "FRSUserStoryDetailCommentsTableView.h"

@interface FRSUserStoryDetailCommentsTableViewCell ()
@property (weak, nonatomic) IBOutlet FRSUserStoryDetailCommentsTableView *tableView;
@end


@implementation FRSUserStoryDetailCommentsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor frescoBackgroundColorDark];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)configureWithStory:(FRSUserStory *)userStory {
    [self.tableView configureCommentsTableViewWithUserStory:userStory];
}

@end
