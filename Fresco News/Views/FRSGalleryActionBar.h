//
//  FRSGalleryActionBar.h
//  Fresco
//
//  Created by Omar Elfanek on 3/2/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSActionBar.h"
#import "FRSGallery.h"

@interface FRSGalleryActionBar : FRSActionBar

-(instancetype)initWithFrame:(CGRect)frame gallery:(FRSGallery *)gallery;
@property (strong, nonatomic) FRSGallery *gallery;

@end
