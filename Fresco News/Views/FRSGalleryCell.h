//
//  FRSGalleryCell.h
//  Fresco
//
//  Created by Daniel Sun on 1/4/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSGalleryView.h"

@interface FRSGalleryCell : UITableViewCell <FRSGalleryViewDataSource>

@property (strong, nonatomic) FRSGalleryView *galleryView;

-(void)configureCell;

@end
