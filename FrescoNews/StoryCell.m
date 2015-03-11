//
//  StoryCell.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/6/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "StoryCell.h"
#import "StoryThumbnailView.h"
#import "FRSStory.h"
#import "FRSGallery.h"
#import "FRSPost.h"
#import "FRSImage.h"

static NSString * const kCellIdentifier = @"StoryCell";

static CGFloat const kImageHeight = 100.0f;
static CGFloat const kImageWidthDefault = 80.0f;
static CGFloat const kInterImageGap = 1.0f;

@implementation StoryCell
+ (NSString *)identifier
{
    return kCellIdentifier;
}

- (void)setStory:(FRSStory *)story
{
    _story = story;
    
    self.imagesArray = [[NSMutableArray alloc] initWithCapacity:5];

    CGRect frame;
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    
    self.constraintHeight.constant = kImageHeight;
    
    for (FRSGallery *gallery in story.galleries) {
        int thumbIndex = 0;
        for (FRSPost *post in gallery.posts) {
            CGFloat scale = kImageHeight / [post.largeImage.height floatValue];
            CGFloat imageWidth = [post.largeImage.width floatValue] * scale;
            // make the image view
            frame = CGRectMake(x, y, imageWidth, kImageHeight);
            
            // check for wrap
            if (x > self.frame.size.width) {
                y += kImageHeight;
                self.constraintHeight.constant += kImageHeight;
                x = 0.0f;
            }
            // only calculate a new width when NOT wrapping
            // in target implementation this will keep current image
            else 
                // set offsets for the next iteration
                x += imageWidth + kInterImageGap;
            
            // lay the view down
            StoryThumbnailView *thumbnailView = [[StoryThumbnailView alloc] initWithFrame:frame];
            [thumbnailView setImageWithURL:post.largeImage.URL];
            [self.contentView addSubview:thumbnailView];
            
            thumbnailView.story_id = [story.storyID integerValue];
            thumbnailView.thumbSequence = thumbIndex;
            ++thumbIndex;
            
            [self setupTapHandlingForThumbnail:thumbnailView];
        }
    }
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];

    self.contentView.backgroundColor = [UIColor whiteColor];
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
}
@end
