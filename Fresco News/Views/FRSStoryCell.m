//
//  FRSStoryTableViewCell.m
//  Fresco
//
//  Created by Omar Elfanek on 1/20/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSStoryCell.h"
#import "FRSStory.h"
#import "UIView+Helpers.h"
#import "UIColor+Fresco.h"

@implementation FRSStoryCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configureCell {
    self.backgroundColor = [UIColor frescoBackgroundColorDark];

    self.storyView = [[FRSStoryView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 13) story:self.story delegate:self];

    if (self.story.caption.length == 0) {
        self.storyView.backgroundColor = [UIColor greenColor];
    }

    self.storyView.actionBlock = self.actionBlock;
    [self addSubview:self.storyView];

    __weak typeof(self) weakSelf = self;

    self.storyView.shareBlock = ^void(NSArray *sharedContent) {
      weakSelf.shareBlock(sharedContent);
    };

    self.storyView.readMoreBlock = ^void(NSArray *sharedContent) {
      if (weakSelf.readMoreBlock) {
          weakSelf.readMoreBlock(Nil);
      }
    };
}

- (void)clearCell {
    [self.storyView removeFromSuperview];
}

#pragma mark - DataSource For Action Bar
- (BOOL)shouldHaveActionBar {
    return YES;
}

- (BOOL)shouldHaveTextLimit {
    return YES;
}

@end
