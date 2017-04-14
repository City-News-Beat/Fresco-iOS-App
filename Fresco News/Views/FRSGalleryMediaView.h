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

@protocol FRSGalleryMediaViewDelegate <NSObject>
//TODO: Scroll - Need to remove these two scroll delegate methods
-(void)mediaScrollViewDidScroll:(UIScrollView *)scrollView;
-(void)mediaScrollViewDidEndDecelerating:(UIScrollView *)scrollView;

-(void)mediaDidChangeToPage:(NSInteger)page;
@end

@interface FRSGalleryMediaView : PSCustomViewFromXib

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

-(instancetype)initWithFrame:(CGRect)frame gallery:(FRSGallery *)gallery delegate:(id<FRSGalleryMediaViewDelegate>)delegate;
-(void)loadGallery:(FRSGallery *)gallery;

-(void)play;
-(void)pause;
-(void)offScreen;

@end
