//
//  FRSGalleryMediaCollectionViewCell.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 4/10/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSPlayer.h"

@interface FRSGalleryMediaCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) FRSPlayer *videoPlayer;

-(void)loadPost:(FRSPost *)post isCasualCall:(BOOL)isCausal;

-(void)play;
-(void)pause;
-(void)tap;

@end
