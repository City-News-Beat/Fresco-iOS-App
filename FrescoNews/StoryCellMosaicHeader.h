//
//  StoryCellMosaicHeader.h
//  FrescoNews
//
//  Created by Fresco News on 3/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;

@class FRSStory;

@protocol StoryHeaderViewTapHandler

- (void)tappedStoryHeader:(FRSStory *)story;

@end

@interface StoryCellMosaicHeader : UITableViewCell

+ (NSString *)identifier;

@property (strong, nonatomic) FRSStory *story;

@property (strong, nonatomic) id <StoryHeaderViewTapHandler> tapHandler;

@end
