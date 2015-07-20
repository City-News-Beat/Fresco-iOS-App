//
//  FullPageGalleryViewController.h
//  FrescoNews
//
//  Created by Fresco News on 3/19/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;
#import "FRSBaseViewController.h"
#import "GalleriesViewController.h"

typedef void(^FRSRefreshResponseBlock)(BOOL success, NSError *error);

@class FRSStory;

@interface StoryViewController : FRSBaseViewController

@property (nonatomic) FRSStory *story;

@property (weak, nonatomic) GalleriesViewController *galleriesViewController;

@property (nonatomic, assign) NSInteger selectedThumbnail;

- (void)performNecessaryFetch:(FRSRefreshResponseBlock)responseBlock;

@end
