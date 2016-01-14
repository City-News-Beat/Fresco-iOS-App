//
//  FRSGalleryView.h
//  Fresco
//
//  Created by Daniel Sun on 1/4/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FRSGallery;


@protocol FRSGalleryViewDataSource <NSObject>

-(BOOL)shouldHaveActionBar;
-(BOOL)shouldHaveTextLimit;
-(BOOL)shouldHaveBottomPadding;

@end

@interface FRSGalleryView : UIView

@property (weak, nonatomic) NSObject <FRSGalleryViewDataSource> *dataSource;

@property (strong, nonatomic) FRSGallery *gallery;



-(instancetype)initWithFrame:(CGRect)frame gallery:(FRSGallery *)gallery dataSource:(id <FRSGalleryViewDataSource>)dataSource;


//Should probably have a resize method that adjusts the size of the entire view. Still haven't out the best way to do this.

@end
