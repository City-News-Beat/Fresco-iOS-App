//
//  GalleryTableViewCell.h
//  FrescoNews
//
//  Created by Jason Gresh on 3/25/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;

@class FRSGallery, GalleryView;

@protocol GalleryTableViewCellDelegate

- (void)readMoreTapped:(FRSGallery *)gallery;

- (void)shareTapped:(FRSGallery *)gallery;

@end

@interface GalleryTableViewCell : UITableViewCell

@property (weak, nonatomic) FRSGallery *gallery;

@property (strong, nonatomic) id<GalleryTableViewCellDelegate> galleryTableViewCellDelegate;

@property (weak, nonatomic) IBOutlet GalleryView *galleryView;

+ (NSString *)identifier;

@end
