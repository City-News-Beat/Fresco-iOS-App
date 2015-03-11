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


+ (NSAttributedString *)attributedStringForCaption:(NSString *)caption :(NSString *)date
{
    NSMutableAttributedString *relativeDate = [[NSMutableAttributedString alloc] initWithString:
                                               [NSString stringWithFormat:@"%@ ~ ",date]
                                                                                     attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.20 green:0.63 blue:0.79 alpha:1.00]}];
    NSMutableAttributedString *attrCaption = [[NSMutableAttributedString alloc] initWithString:caption attributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    
    [relativeDate appendAttributedString:attrCaption];
    
    return relativeDate;
}

- (void)dealloc
{
    [[self imageView] cancelImageRequestOperation];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [[self imageView] cancelImageRequestOperation];
}

- (void)setPost:(FRSPost *)post{
    
    _post = post;

    [[self captionLabel] setAttributedText:[[self class] attributedStringForCaption:self.post.caption :[MTLModel relativeDateStringFromDate:self.post.date]]];
    self.authorLabel.text = self.post.byline;
    self.timePlaceLabel.text = [MTLModel relativeDateStringFromDate:self.post.date];

    [[self imageView] setImageWithURL:post.largeImage.URL];
}

+ (NSString *)identifier
{
    return kCellIdentifier;
}
@end

