//
//  GalleryViewController.h
//  FrescoNews
//
//  Created by Fresco News on 5/29/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

@import UIKit;

#import "FRSBaseViewController.h"
#import "FRSGallery.h"

@interface GalleryViewController : FRSBaseViewController

@property (nonatomic, strong) FRSGallery *gallery;

- (void)setGallery:(FRSGallery *)gallery;

- (void)openGalleryWithId:(NSString *)galleryId;

@end

