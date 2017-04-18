//
//  FRSGalleryMediaVideoCollectionViewCell.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 4/13/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSPlayer.h"
#import "AVPlayerDemoPlaybackView.h"

@interface FRSGalleryMediaVideoCollectionViewCell : UICollectionViewCell
{
    NSURL* mURL;
    
    BOOL seekToZeroBeforePlay;
    id mTimeObserver;
    BOOL isSeeking;

}
@property (nonatomic, copy) NSURL* URL;
@property (readwrite, strong, setter=setPlayer:, getter=player) FRSPlayer* mPlayer;
@property (strong) AVPlayerItem* mPlayerItem;
@property (weak, nonatomic) IBOutlet AVPlayerDemoPlaybackView *mPlaybackView;

-(void)loadPost:(FRSPost *)post;

-(void)play;
-(void)pause;
-(void)tap;

@end
