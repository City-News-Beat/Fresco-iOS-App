//
//  GalleryView.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/19/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "GalleryView.h"
#import "FRSGallery.h"
#import "FRSPost.h"
#import "FRSImage.h"
#import "PostCollectionViewCell.h"

@interface GalleryView () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

/*
** Index of cell that is currently playing a video
*/

@property (nonatomic) NSIndexPath *playingIndex;

@end

@implementation GalleryView

+ (AVPlayer *)sharedPlayer
{
    static AVPlayer *player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[AVPlayer alloc] init];
    });
    return player;
}

+ (AVPlayerLayer *)sharedLayer
{
    static AVPlayerLayer *layer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        layer = [[AVPlayerLayer alloc] init];
    });
    return layer;
}


- (void)awakeFromNib
{
    self.collectionPosts.scrollsToTop = NO;
    self.collectionPosts.dataSource = self;
    self.collectionPosts.delegate = self;
    self.pageControl.numberOfPages = 0;
}


- (void)setGallery:(FRSGallery *)gallery isInList:(BOOL)inList
{
    _gallery = gallery;
    
    self.labelCaption.text = self.gallery.caption;
    
    if([self.gallery.posts count] == 1)
        self.pageControl.hidden = YES;
    else
        self.pageControl.numberOfPages = [self.gallery.posts count];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionPosts reloadData];
        [self.collectionPosts layoutIfNeeded];
    });
    
    if(!inList){
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(self.collectionPosts.visibleCells.count){
        
                if(self.collectionPosts.visibleCells[0] != nil){
                    
                    PostCollectionViewCell *postCell = (PostCollectionViewCell *) self.collectionPosts.visibleCells[0];
                
                    //If the cell has a video
                    if([postCell.post isVideo]){
                
                        [self setUpPlayerWithUrl:postCell.post.video cell:postCell];
                
                    }
                
                    //If the cell doesn't have a video
                    else{
                
                        //If the Player is actually playing
                        if([self sharedPlayer] != nil){
                
                            //Stop the player
                
                            [[self sharedPlayer] pause];
                            
                            [[self sharedLayer] removeFromSuperlayer];
                            
                        }
                        
                    }
                    
                }
                
            }

        });
            
    }
    
    [self setAspectRatio];
    
}

- (void)setUpPlayerWithUrl:(NSURL *)url cell:(PostCollectionViewCell *)postCell
{
    
    [[self sharedPlayer] pause];
    
    [[self sharedLayer] removeFromSuperlayer];
    
    self.sharedPlayer = [AVPlayer playerWithURL:url];
    
    self.sharedPlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    
    self.sharedLayer = [AVPlayerLayer playerLayerWithPlayer:self.sharedPlayer];
    
    self.sharedLayer.videoGravity  = AVLayerVideoGravityResizeAspectFill;
    
    self.sharedLayer.frame = postCell.imageView.bounds;
    
    [self.sharedPlayer play];
    
    [self.sharedPlayer setMuted:NO];

    [postCell.imageView.layer addSublayer:self.sharedLayer];
    
    [postCell bringSubviewToFront:postCell.playPause];
    
}


- (void)setAspectRatio
{
    if ([self.gallery.posts count]) {
        
        FRSPost *post = [self.gallery.posts firstObject];
        
        CGFloat aspectRatio;
        if (post.image) {
            aspectRatio = [post.image.width floatValue] / [post.image.height floatValue];
            if (aspectRatio < 1.0f || !post.image.height /* shouldn't happen... */) {
                aspectRatio = 1.0f;
            }
        }
        else {
            aspectRatio = 600/800;
        }
        
        if (self.collectionPosts.constraints)
            [self.collectionPosts removeConstraints:self.collectionPosts.constraints];
        
        // make the aspect ratio 4:3
        [self.collectionPosts addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionPosts
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.collectionPosts
                                                                         attribute:NSLayoutAttributeHeight
                                                                        multiplier:aspectRatio
                                                                          constant:0]];
        [self updateConstraints];
    }
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.gallery.posts count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PostCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PostCollectionViewCell identifier] forIndexPath:indexPath];
    
    cell.post = [self.gallery.posts objectAtIndex:indexPath.item];
    cell.backgroundColor = [UIColor colorWithHex:[VariableStore sharedInstance].colorBackground];

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    PostCollectionViewCell *cell = (PostCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    //If the cell has a video
    if(cell.post.isVideo){
        
        if(self.sharedPlayer.rate > 0){
            
            [self.sharedPlayer pause];
            cell.playPause.image = [UIImage imageNamed:@"pause"];
            cell.playPause.transform = CGAffineTransformMakeScale(1, 1);
            [cell bringSubviewToFront:cell.playPause];

            cell.playPause.alpha = 1.0f;
            
            [UIView animateWithDuration:.5 animations:^{
                cell.playPause.alpha = 0.0f;
                cell.playPause.transform = CGAffineTransformMakeScale(2, 2);
            }
             completion:^(BOOL finished){
               
             }];

        }
        else{
            
            [self.sharedPlayer play];
            cell.playPause.image = [UIImage imageNamed:@"play"];
            cell.playPause.transform = CGAffineTransformMakeScale(1, 1);
            [cell bringSubviewToFront:cell.playPause];
            
            cell.playPause.alpha = 1.0f;
            
            [UIView animateWithDuration:.5 animations:^{
                cell.playPause.alpha = 0.0f;
                cell.playPause.transform = CGAffineTransformMakeScale(2, 2);
            }
             completion:^(BOOL finished){
                cell.playPause.transform = CGAffineTransformMakeScale(1, 1);
             }];

        }
        

    }

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.bounds.size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSIndexPath *index = [[self.collectionPosts indexPathsForVisibleItems] lastObject];
    
    self.pageControl.currentPage = index.item;
    
    CGRect visibleRect = (CGRect){.origin = self.collectionPosts.contentOffset, .size = self.collectionPosts.bounds.size};
    
    CGPoint visiblePoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect));
    
    NSIndexPath *visibleIndexPath = [self.collectionPosts indexPathForItemAtPoint:visiblePoint];
    
    PostCollectionViewCell *postCell = (PostCollectionViewCell *) [self.collectionPosts cellForItemAtIndexPath:visibleIndexPath];
    
    //If the cell has a video
    if([postCell.post isVideo]){
    
        [self setUpPlayerWithUrl:postCell.post.video cell:postCell];
    }
    //If the cell doesn't have a video
    else{
        
        //If the Player is actually playing
        if([self sharedPlayer] != nil){
            
            //Stop the player
            
            [[self sharedPlayer] pause];
            
            [[self sharedLayer] removeFromSuperlayer];
            
        }
        
    }

}

@end
