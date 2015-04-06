//
//  StoryCellMosaic.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/6/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "StoryCellMosaic.h"
#import "StoryThumbnailView.h"
#import "FRSStory.h"
#import "FRSGallery.h"
#import "FRSPost.h"
#import "FRSImage.h"
#import "StoryViewController.h"

static NSString * const kCellIdentifier = @"StoryCellMosaic";

static CGFloat const kImageHeight = 96.0;
static CGFloat const kInterImageGap = 1.0f;

@interface StoryCellMosaic()
@property (nonatomic, strong) NSArray *imageArray;
@end

@implementation StoryCellMosaic
+ (NSString *)identifier
{
    return kCellIdentifier;
}

- (void)awakeFromNib
{
    self.constraintHeight.constant = kImageHeight;
    self.contentView.backgroundColor = [UIColor whiteColor];
}

- (NSArray *)imageArray
{
    if (_imageArray)
        return _imageArray;
    
    CGFloat totalWidth = 0.0;
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    // keep track of the position we're in in each gallery so we can
    // insert into the irregular output array at the correct position
    int galleryPositionIndices[[self.story.galleries count]];
    memset(galleryPositionIndices, 0, sizeof(galleryPositionIndices));
    
    // loop through galleries and posts first taking the first post
    // from each gallery and then filling back
    //int index = 0;
    for (int i = 0; i < 10; ++i) {
        if (totalWidth > self.frame.size.width * 2)
            break;
        
        for (int j = 0; j < [self.story.galleries count]; ++j) {
            FRSGallery *gallery = [self.story.galleries objectAtIndex:j];
            
            // the initial placement for each gallery is in the first j positions of the array
            if (galleryPositionIndices[j] == 0)
                galleryPositionIndices[j] = j;

            if (i < [gallery.posts count]) {
                FRSPost *post = [gallery.posts objectAtIndex:i];
                
                CGFloat scale = kImageHeight / [post.largeImage.height floatValue];
                CGFloat imageWidth = [post.largeImage.width floatValue] * scale;
                
                totalWidth += imageWidth;
                
                //index = j;
                [tempArray insertObject:post.largeImage atIndex:galleryPositionIndices[j]];
                //++index;
                galleryPositionIndices[j] = galleryPositionIndices[j] + 1;
                
                for (int k = 0; k < [self.story.galleries count]; k++) {
                    NSLog(@"Gallery %d index: %d", k, galleryPositionIndices[k]);
                }
            }
            ++i;
        }
    }
    _imageArray = [[NSArray alloc]initWithArray:tempArray];
    return _imageArray;
}

- (void)layoutSubviews
{
    for (UIView *view in self.contentView.subviews) {
        if ([view isKindOfClass:[StoryThumbnailView class]]) {
            [view removeFromSuperview];
            //NSLog(@"Removing view -- we could optimize this to resize views");
        }
    }
    
    CGRect frame;
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    int rows = 1;
    
    self.constraintHeight.constant = kImageHeight;
    
    int i = 0;
    for (FRSImage *image in self.imageArray) {
        // we don't want more than two rows of images
        if (rows > 2)
            break;
        
        CGFloat scale = kImageHeight / [image.height floatValue];
        CGFloat imageWidth = [image.width floatValue] * scale;
        
        // make the image view
        frame = CGRectMake(x, y, imageWidth, kImageHeight);
        
        // lay the view down
        StoryThumbnailView *thumbnailView = [[StoryThumbnailView alloc] initWithFrame:frame];
        [thumbnailView setImageWithURL:[image cdnImageURL]];
        [self.contentView addSubview:thumbnailView];
        
        thumbnailView.story_id = [self.story.storyID integerValue];
        thumbnailView.thumbSequence = i;
        [self setupTapHandlingForThumbnail:thumbnailView];
        
        // calculate offsets for the next iteration
        x += imageWidth + kInterImageGap;
        
        // check for wrap
        if (x > self.frame.size.width) {
            ++rows;
            y += kImageHeight + kInterImageGap;
            self.constraintHeight.constant = kImageHeight * 2 + kInterImageGap;
            [self updateConstraints];
            x = 0.0f;
            
            // we almost always want to redo this image on the next row
            // but check the edge case where the image is wider than the
            // whole frame which would cause an endless loop
            if (imageWidth + kInterImageGap < self.frame.size.width)
                --i;
        }
        
        ++i;
    }
}

- (void)layoutSubviewsOld
{
    for (UIView *view in self.contentView.subviews) {
        if ([view isKindOfClass:[StoryThumbnailView class]]) {
            [view removeFromSuperview];
            //NSLog(@"Removing view -- we could optimize this to resize views");
        }
    }
    
    CGRect frame;
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    int rows = 1;
    
    self.constraintHeight.constant = kImageHeight;
    
    for (FRSGallery *gallery in self.story.galleries) {
        for (int i = 0; i < [gallery.posts count]; ++i) {
            // we don't want more than two rows of images
            if (rows > 2)
                break;
            
            FRSPost *post = [gallery.posts objectAtIndex:i];
            CGFloat scale = kImageHeight / [post.largeImage.height floatValue];
            CGFloat imageWidth = [post.largeImage.width floatValue] * scale;
            
            // make the image view
            frame = CGRectMake(x, y, imageWidth, kImageHeight);
            
            // lay the view down
            StoryThumbnailView *thumbnailView = [[StoryThumbnailView alloc] initWithFrame:frame];
            [thumbnailView setImageWithURL:[post.largeImage cdnImageURL]];
            [self.contentView addSubview:thumbnailView];
            
            thumbnailView.story_id = [self.story.storyID integerValue];
            thumbnailView.thumbSequence = i;
            [self setupTapHandlingForThumbnail:thumbnailView];
            
            // calculate offsets for the next iteration
            x += imageWidth + kInterImageGap;
            
            // check for wrap
            if (x > self.frame.size.width) {
                ++rows;
                y += kImageHeight + kInterImageGap;
                self.constraintHeight.constant = kImageHeight * 2 + kInterImageGap;
                [self updateConstraints];
                x = 0.0f;
                
                // we almost always want to redo this image on the next row
                // but check the edge case where the image is wider than the
                // whole frame which would cause an endless loop
                if (imageWidth + kInterImageGap < self.frame.size.width)
                    --i;
            }
        }
    }
}

- (void)setupTapHandlingForThumbnail:(StoryThumbnailView *)thumbnailView
{
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    gesture.numberOfTapsRequired = 1;
    [thumbnailView addGestureRecognizer:gesture];
}

- (void)handleTapGesture:(id)sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    StoryThumbnailView *storyThumbnail = (StoryThumbnailView *) gesture.view;
    
    [self.tapHandler story:self.story tappedAtGalleryIndex:storyThumbnail.thumbSequence];
}

- (void)prepareForReuse
{
    // get rid of all the image views
    // we might optimize this for reuse if need be
    for (UIView *v in [self.contentView subviews]) {
        if ([v isKindOfClass:[StoryThumbnailView class]])
            [v removeFromSuperview];
    }
    self.constraintHeight.constant = kImageHeight;
}
@end
