//
//  GallleryPostViewController.h
//  Fresco
//
//  Created by Daniel Sun on 12/15/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSBaseViewController.h"

@class FRSGallery;

@interface GalleryPostViewController : FRSBaseViewController

@property (strong, nonatomic) FRSGallery *gallery;
@property (strong, nonatomic) NSArray *nearbyAssignments;



@end