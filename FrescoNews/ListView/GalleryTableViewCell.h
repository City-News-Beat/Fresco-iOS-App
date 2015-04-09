//
//  StoryTableViewCell.h
//  FrescoNews
//
//  Created by Jason Gresh on 3/25/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FRSGallery, GalleryView;
@interface GalleryTableViewCell : UITableViewCell
@property (weak, nonatomic) FRSGallery *gallery;
@property (weak, nonatomic) IBOutlet GalleryView *galleryView;
+ (NSString *)identifier;
@end
