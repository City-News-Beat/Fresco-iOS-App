//
//  GalleryViewController.h
//  FrescoNews
//
//  Created by Jason Gresh on 3/25/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FRSStory;
@interface GalleryViewController : UIViewController
@property (nonatomic, weak) FRSStory *story;
@end
