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
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:10];

    for (FRSGallery *gallery in self.story.galleries) {
        for (FRSPost *post in gallery.posts) {
            [tempArray addObject:post.image];
        }
    }
    [self shuffle:tempArray];
    
    _imageArray = [[NSArray alloc]initWithArray:tempArray];
    return _imageArray;
}

- (void)shuffle:(NSMutableArray *)array
{
    NSUInteger count = [array count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [array exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
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
        
        /*
        NSString *format = [NSString stringWithFormat:@"H:|-(%f)-view-(%f)-|", frame.origin.x, frame.origin.x + frame.size.width
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:nil]]*/
        
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
