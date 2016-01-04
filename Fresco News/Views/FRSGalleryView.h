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

-(NSInteger)heightForImageView;
-(NSInteger)numberOfLinesForTextView;


@end

@interface FRSGalleryView : UIView

@property (weak, nonatomic) NSObject <FRSGalleryViewDataSource> *dataSource;

@property (strong, nonatomic) FRSGallery *gallery;


-(instancetype)initWithFrame:(CGRect)frame gallery:(FRSGallery *)gallery dataSource:(id <FRSGalleryViewDataSource>)dataSource;

@end
