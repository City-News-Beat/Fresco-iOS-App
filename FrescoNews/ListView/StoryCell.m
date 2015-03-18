//
//  StoryCell.m
//  Fresco
//
//  Created by Team Fresco on 2/9/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import "StoryCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "FRSUser.h"
#import "FRSImage.h"

static NSString * const kCellIdentifier = @"StoryCell";

@implementation StoryCell

+ (NSAttributedString *)attributedStringForCaption:(NSString *)caption date:(NSString *)date
{
    return [[NSMutableAttributedString alloc] initWithString:caption attributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
}

- (void)dealloc
{
    [[self imageView] cancelImageRequestOperation];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.imageView cancelImageRequestOperation];
    self.imageView.image = nil;
}

- (void)setPost:(FRSPost *)post
{
    _post = post;

    [[self captionLabel] setAttributedText:[[self class] attributedStringForCaption:self.post.caption date:[MTLModel relativeDateStringFromDate:self.post.date]]];
    //self.bylineLabel.text = self.post.byline;

   // self.timeAndPlaceLabel.text = [self.post relativeDateString];
    /*UIImage *cachedImage = [[FRSCacheManager sharedManager] cachedImageForURL:[_post largeImageURL]];
    
    if (cachedImage) {
        [[self imageView] setImage:cachedImage];
    }
    else {*/
    //[self.postImageView setImageWithURL:[_post largeImageURL]];
    __weak StoryCell *weakSelf = self;
    [self.postImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[_post largeImageURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        self.postImageView.image = image;
        [weakSelf updateConstraints];
        [weakSelf layoutIfNeeded];
        [weakSelf setNeedsLayout];
        [weakSelf setNeedsDisplay];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [weakSelf updateConstraints];
    }];
   // }
    //self.timeAndPlaceLabel.text = [MTLModel relativeDateStringFromDate:self.post.date];

    //[[self imageView] setImageWithURL:[post largeImageURL]];
}

+ (NSString *)identifier
{
    return kCellIdentifier;
}

@end
