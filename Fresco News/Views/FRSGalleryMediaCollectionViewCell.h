//
//  FRSGalleryMediaCollectionViewCell.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 4/10/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSGalleryMediaCollectionViewCell : UICollectionViewCell

-(void)loadPost:(FRSPost *)post;

-(void)play;
-(void)pause;

@end
