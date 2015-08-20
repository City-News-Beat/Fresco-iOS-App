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

@property (nonatomic, assign) NSInteger thumbSequence;

@property (nonatomic, copy) NSString *galleryID;

@end

