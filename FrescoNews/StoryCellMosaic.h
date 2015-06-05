//
//  StoryCellMosaic.h
//  FrescoNews
//
//  Created by Jason Gresh on 3/6/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FRSStory;

@protocol StoryThumbnailViewTapHandler
- (void)story:(FRSStory *)story tappedAtGalleryIndex:(NSInteger)index;
@end

@interface StoryCellMosaic : UITableViewCell
@property (strong, nonatomic) FRSStory *story;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeight;
@property (strong, nonatomic) id <StoryThumbnailViewTapHandler> tapHandler;

+ (NSString *)identifier;
@end

