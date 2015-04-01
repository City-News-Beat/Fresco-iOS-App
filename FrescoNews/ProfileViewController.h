//
//  FullPageGalleryViewController.h
//  FrescoNews
//
//  Created by Jason Gresh on 3/19/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GalleryView, FRSStory;
@interface ProfileViewController : UIViewController
@property (weak, nonatomic) IBOutlet GalleryView *galleryView;
@property (weak, nonatomic) FRSStory *story;
@end
