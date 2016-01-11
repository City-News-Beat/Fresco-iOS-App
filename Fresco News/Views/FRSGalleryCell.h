//
//  FRSGalleryCell.h
//  Fresco
//
//  Created by Daniel Sun on 1/4/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSGalleryView.h"

@class FRSGallery;

@interface FRSGalleryCell : UITableViewCell <FRSGalleryViewDataSource>

@property (strong, nonatomic) FRSGalleryView *galleryView;

@property (strong, nonatomic) FRSGallery *gallery;

-(void)clearCell;
-(void)configureCell;

@end
