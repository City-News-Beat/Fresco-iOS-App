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
#import "FRSTag.h"

static NSString * const kCellIdentifier = @"StoryCell";

static CGFloat const kImageHeight = 100.0f;
static CGFloat const kImageWidthDefault = 80.0f;
static CGFloat const kInterImageGap = 1.0f;

@implementation StoryCell
+ (NSString *)identifier
{
    return kCellIdentifier;
}

- (void)setFRSTag:(FRSTag *)tag
{
    _frsTag = tag;
    
    self.imagesArray = [[NSMutableArray alloc] initWithCapacity:5];

    CGRect frame;
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    CGFloat imageWidth = kImageWidthDefault + arc4random_uniform(100);
    int count = 3 + arc4random_uniform(5);
    for (int i = 0; i < count; ++i) {
        // make the image view
        frame = CGRectMake(x, y, imageWidth, kImageHeight);

        // check for wrap
        if (x > self.frame.size.width) {
            y += kImageHeight;
            x = -(imageWidth - (x - self.frame.size.width));
        }
        // only calculate a new width when NOT wrapping
        // in target implementation this will keep current image
        else {
            // set offsets for the next iteration
            x += imageWidth + kInterImageGap;

            imageWidth = kImageWidthDefault + arc4random_uniform(100);
        }
        
        // lay the view down
        StoryThumbnailView *thumbnailView = [[StoryThumbnailView alloc] initWithFrame:frame];
        [thumbnailView setImageWithURL:tag.smallImagePath];
        [self.contentView addSubview:thumbnailView];

        thumbnailView.story_id = arc4random_uniform(10000);
        thumbnailView.thumbSequence = i;
        [self setupTapHandlingForThumbnail:thumbnailView];
    }

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
