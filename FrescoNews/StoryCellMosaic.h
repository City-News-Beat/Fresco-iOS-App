//
//  StoryCellMosaic.h
//  FrescoNews
//
//  Created by Fresco News on 3/6/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;

@class FRSStory;

@protocol StoryThumbnailViewTapHandler

- (void)tappedStoryThumbnail:(FRSStory *)story atIndex:(NSInteger)index;

@end

@interface StoryCellMosaic : UITableViewCell

@property (strong, nonatomic) FRSStory *story;

@property (strong, nonatomic) id <StoryThumbnailViewTapHandler> tapHandler;

@property (strong, nonatomic) NSArray *imageArray;

+ (NSString *)identifier;

- (void)configureImages;

@end

