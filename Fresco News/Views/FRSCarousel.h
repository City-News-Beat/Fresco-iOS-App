//
//  FRSCarousel.h
//  Fresco
//
//  Created by Philip Bernstein on 6/20/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSCarouselCell.h"
#import <Photos/Photos.h>

@interface FRSCarousel : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource>
{
    
}

@property (nonatomic, weak) NSArray *media;
@end
