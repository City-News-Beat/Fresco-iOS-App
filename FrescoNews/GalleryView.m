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
@property (weak, nonatomic) IBOutlet UICollectionView *collectionPosts;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *labelCaption;
@end

@implementation GalleryView

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
        
        post.largeImage.width = [NSNumber numberWithFloat:800.0f];
        post.largeImage.height = [NSNumber numberWithFloat:600.0f];
        CGFloat aspectRatio = [post.largeImage.width floatValue] / [post.largeImage.height floatValue];
        if (aspectRatio < 1.0f)
            aspectRatio = 1.0f;
        
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
}

@end
