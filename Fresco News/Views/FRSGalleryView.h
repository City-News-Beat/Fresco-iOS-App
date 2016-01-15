//
//  FRSGalleryView.h
//  Fresco
//
//  Created by Daniel Sun on 1/4/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FRSGallery;


@protocol FRSGalleryViewDelegate <NSObject>

-(BOOL)shouldHaveActionBar;
-(BOOL)shouldHaveTextLimit;

@end

@interface FRSGalleryView : UIView

@property (weak, nonatomic) NSObject <FRSGalleryViewDelegate> *delegate;

@property (strong, nonatomic) FRSGallery *gallery;



-(instancetype)initWithFrame:(CGRect)frame gallery:(FRSGallery *)gallery delegate:(id <FRSGalleryViewDelegate>)delegate;


//Should probably have a resize method that adjusts the size of the entire view. Still haven't out the best way to do this.

@end
