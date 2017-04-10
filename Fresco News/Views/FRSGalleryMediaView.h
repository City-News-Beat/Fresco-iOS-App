//
//  FRSGalleryItemsView.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 4/10/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSCustomViewFromXib.h"
@class FRSGallery;

@interface FRSGalleryMediaView : PSCustomViewFromXib

-(instancetype)initWithFrame:(CGRect)frame andGallery:(FRSGallery *)gallery;
-(void)loadGallery:(FRSGallery *)gallery;

@end
