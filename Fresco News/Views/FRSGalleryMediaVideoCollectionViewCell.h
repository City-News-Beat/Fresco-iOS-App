//
//  FRSGalleryMediaVideoCollectionViewCell.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 4/13/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSPlayer.h"

@interface FRSGalleryMediaVideoCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) FRSPlayer *videoPlayer;

-(void)loadPost:(FRSPost *)post;

-(void)play;
-(void)pause;
-(void)tap;

@end
