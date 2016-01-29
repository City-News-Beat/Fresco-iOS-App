//
//  GallleryPostViewController.h
//  Fresco
//
//  Created by Daniel Sun on 12/15/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSBaseViewController.h"

@class FRSGallery;
@class FRSAssignment;

@interface GalleryPostViewController : FRSBaseViewController

@property (strong, nonatomic) FRSGallery *gallery;
@property (strong, nonatomic) NSArray *nearbyAssignments;
@property (strong, nonatomic) FRSAssignment *selectedAssignment;

@property (strong, nonatomic) NSDictionary *socialOptions;



@end