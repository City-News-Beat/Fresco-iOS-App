//
//  FRSStoryTableViewCell.h
//  Fresco
//
//  Created by Omar Elfanek on 1/20/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSStoryView.h"
#import "FRSActionBar.h"

@class FRSStory;

static NSString *const storyCellIdentifier = @"story-cell";

@interface FRSStoryTableViewCell : UITableViewCell <FRSStoryViewDelegate>

@property (strong, nonatomic) FRSStoryView *storyView;
@property (strong, nonatomic) FRSStory *story;
@property (strong, nonatomic) FRSUserStory *userStory;
@property (strong, nonatomic) ActionButtonBlock actionBlock;
@property (strong, nonatomic) StoryImageBlock imageBlock;
@property (strong, nonatomic) ShareSheetBlock shareBlock;
@property (strong, nonatomic) ShareSheetBlock readMoreBlock;
@property (weak, nonatomic) UINavigationController *navigationController;
@property (weak, nonatomic) id<FRSStoryViewDelegate> delegate;

@property (nonatomic, readwrite) FRSTrackedScreen trackedScreen;

- (void)clearCell;
- (void)configureCell;

@end
