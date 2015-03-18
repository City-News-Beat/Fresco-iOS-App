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

static NSString * const kCellIdentifier = @"StoryCellMosaic";

static CGFloat const kImageHeight = 96.0;
static CGFloat const kInterImageGap = 1.0f;

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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                    message:[NSString stringWithFormat:@"Pressed id %d - image %d", (int)storyThumbnail.story_id, (int)storyThumbnail.thumbSequence]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
                          
    [alert show];
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
