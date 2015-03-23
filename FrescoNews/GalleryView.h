//
//  GalleryView.h
//  FrescoNews
//
//  Created by Jason Gresh on 3/19/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GalleryView : UIView
@property (weak, nonatomic) IBOutlet UICollectionView *collectionPosts;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *labelCaption;

@end
