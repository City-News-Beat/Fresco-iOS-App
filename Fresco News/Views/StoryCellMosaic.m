//
//  StoryCellMosaic.m
//  FrescoNews
//
//  Created by Fresco News on 3/6/15.
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

@implementation StoryCellMosaic

+ (NSString *)identifier
{
    return kCellIdentifier;
}

- (void)prepareForReuse
{
    // get rid of all the image views
    // we might optimize this for reuse if need be
    for (UIView *v in [self.contentView subviews]) {
        if ([v isKindOfClass:[StoryThumbnailView class]])
            [((StoryThumbnailView *) v) cancelImageRequestOperation];
    }
//    self.imageArray = nil;
}

- (void)configureImages
{
    for (UIView *view in self.contentView.subviews) {
        if ([view isKindOfClass:[StoryThumbnailView class]]) {
            [view removeFromSuperview];
            //NSLog(@"Removing view -- we could optimize this to resize views");
        }
    }
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    int rows = 1;
    
    int i = 0;
    
    for (FRSImage *image in self.imageArray) {
        
        // we don't want more than two rows of images
        if (rows > 2)
            break;
        
        CGFloat scale = kImageHeight / [image.height floatValue];
        CGFloat imageWidth = [image.width floatValue] * scale;
        
        // lay the view down
        StoryThumbnailView *thumbnailView = [[StoryThumbnailView alloc] initWithFrame:CGRectMake(x, y, imageWidth, kImageHeight)];
        
        thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
        // 3x is for retina displays
        [thumbnailView setImageWithURL:[image smallImageUrl]];

        
//        dispatch_async (dispatch_get_main_queue(), ^{
//            
//            __weak StoryThumbnailView *weakSelf = thumbnailView;
//            

//            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[image smallImageUrl]];
//            [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
//            
//            [thumbnailView setImageWithURLRequest:request placeholderImage:nil
//                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *requestedImage) {
//
//                                              if (request) {
//                                                  
//                                                  [UIView transitionWithView:weakSelf
//                                                                    duration:0.8f
//                                                                     options:UIViewAnimationOptionTransitionCrossDissolve
//                                                                  animations:^{
//                                                                      
//                                                                      [weakSelf setImage:requestedImage];
//                                                                  
//                                                                  }
//                                                                  completion:NULL];
//                                              }
//                                              else{
//                                                  NSLog(@"ok");
//                                                  [weakSelf setImageWithURL:[image smallImageUrl]];
//                                                  
//                                              }
//                                          }
//                                          failure:NULL];
//        });
        
        thumbnailView.thumbSequence = i;
        
        [self.contentView addSubview:thumbnailView];
        [self setupTapHandlingForThumbnail:thumbnailView];
        
        // calculate offsets for the next iteration
        x += imageWidth + kInterImageGap;
        
        // check for wrap and that the cell height is greater
        if (x > self.frame.size.width && self.frame.size.height > 96.0f) {
            ++rows;
            y += kImageHeight + kInterImageGap;
            x = 0.0f;
//            
//            // we almost always want to redo this image on the next row
//            // but check the edge case where the image is wider than the
//            // whole frame which would cause an endless loop
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
    
    [self.tapHandler tappedStoryThumbnail:self.story atIndex:storyThumbnail.thumbSequence];
}

@end
