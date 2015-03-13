//
//  FRSStoryListCell.m
//  Fresco
//
//  Created by Team Fresco on 2/9/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import "FRSStoryListCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "FRSUser.h"
#import "FRSImage.h"

static NSString * const kCellIdentifier = @"Story List Cell Identifer";

@implementation FRSStoryListCell

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
    self.bylineLabel.text = self.post.byline;
    self.timeAndPlaceLabel.text = [MTLModel relativeDateStringFromDate:self.post.date];

    [[self imageView] setImageWithURL:[post largeImageURL]];
}

+ (NSString *)identifier
{
    return kCellIdentifier;
}

@end
