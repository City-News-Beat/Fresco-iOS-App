//
//  FullPageGalleryViewController.h
//  FrescoNews
//
//  Created by Jason Gresh on 3/19/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;
#import "FRSBaseViewController.h"

@class FRSStory;

@interface StoryViewController : FRSBaseViewController
@property (nonatomic) FRSStory *story;
@end
