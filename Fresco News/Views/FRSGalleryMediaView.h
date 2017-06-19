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

-(void)mediaDidChangeToPage:(NSInteger)page;
-(void)mediaShouldShowMuteIcon:(BOOL)show;
@end

@interface FRSGalleryMediaView : PSCustomViewFromXib

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

-(instancetype)initWithFrame:(CGRect)frame posts:(NSArray *)posts delegate:(id<FRSGalleryMediaViewDelegate>)delegate;
-(void)loadPosts:(NSArray *)posts;

-(void)play;
-(void)pause;
-(void)offScreen;

@end
