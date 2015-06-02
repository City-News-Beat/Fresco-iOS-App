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
    self.collectionPosts.dataSource = self;
    self.collectionPosts.delegate = self;
    self.pageControl.numberOfPages = 0;
}

- (void)setGallery:(FRSGallery *)gallery
{
    _gallery = gallery;
    self.labelCaption.text = self.gallery.caption;
    
    self.pageControl.numberOfPages = [self.gallery.posts count];
 
    [self.collectionPosts reloadData];

    [self setAspectRatio];
}

- (void)setAspectRatio
{
    if ([self.gallery.posts count]) {
        
        FRSPost *post = [self.gallery.posts firstObject];
        
        CGFloat aspectRatio;
        if (post.image) {
            aspectRatio = [post.image.width floatValue] / [post.image.height floatValue];
            if (aspectRatio < 1.0f)
                aspectRatio = 1.0f;
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

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
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

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
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
    
        [[self sharedPlayer] pause];
        
        [[self sharedLayer] removeFromSuperlayer];
        
        _sharedPlayer = [AVPlayer playerWithURL:[NSURL URLWithString:postCell.post.mediaURLString]];
        
        self.sharedPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
        self.sharedLayer = [AVPlayerLayer playerLayerWithPlayer:self.sharedPlayer];
        
        self.sharedLayer.frame = postCell.imageView.bounds;
        
        self.sharedLayer.videoGravity  = AVLayerVideoGravityResizeAspectFill;
        
        [_sharedPlayer play];
        
        [_sharedPlayer setMuted:NO];
        
        [postCell.imageView.layer addSublayer:self.sharedLayer];
        
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
