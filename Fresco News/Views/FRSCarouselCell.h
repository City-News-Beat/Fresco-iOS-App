//
//  FRSCarouselCell.h
//  Fresco
//
//  Created by Philip Bernstein on 6/20/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "FRSPlayer.h"

@interface FRSCarouselCell : UICollectionViewCell
{
    UIImageView *imageView;
    FRSPlayer *videoView;
}

-(void)loadImage:(PHAsset *)asset;
-(void)loadVideo:(PHAsset *)asset;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@property (strong, nonatomic) NSArray *assets;
@property (nonatomic, retain) NSMutableArray *players;

@end
