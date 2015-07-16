//
//  StoryThumbnailView.h
//  FrescoNews
//
//  Created by Fresco News on 3/9/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;

@class FRSStory;
@interface StoryThumbnailView : UIImageView
@property (nonatomic, assign) NSInteger story_id;
@property (nonatomic, assign) NSInteger thumbSequence;
@end

