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
    AVPlayerLayer *playerLayer;
}

-(void)loadImage:(PHAsset *)asset;
-(void)loadVideo:(PHAsset *)asset;

-(void)pausePlayer;
-(void)playPlayer;
-(void)removePlayers;

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) NSArray *assets;
@property (strong, nonatomic) UIImageView *muteImageView;

@property BOOL didUnmute;
@property (strong, nonatomic) PHAsset *asset;


@end
