//
//  GalleryHeader.h
//  FrescoNews
//
//  Created by Jason Gresh on 3/17/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;
@class FRSGallery;

@interface GalleryHeader : UITableViewCell
+ (NSString *)identifier;
- (void)setGallery:(FRSGallery *)gallery;
@end
