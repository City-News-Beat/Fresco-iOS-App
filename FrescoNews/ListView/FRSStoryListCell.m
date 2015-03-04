//
//  FRSStoryListCell.m
//  Fresco
//
//  Created by Team Fresco on 2/9/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import "FRSStoryListCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
//#import "FRSCacheManager.h"
#import "FRSUser.h"

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

    [[self captionLabel] setAttributedText:[[self class] attributedStringForCaption:[self post].caption :[self post].relativeDateString]];
    self.authorLabel.text = self.post.byline;
    self.timePlaceLabel.text = [self.post relativeDateString];
    /*UIImage *cachedImage = [[FRSCacheManager sharedManager] cachedImageForURL:[_post largeImageURL]];
    
    if (cachedImage) {
        [[self imageView] setImage:cachedImage];
    }
    else {*/
        [[self imageView] setImageWithURL:[_post largeImageURL]];
   // }

    
}

+ (NSString *)identifier
{
    return kCellIdentifier;
}
@end

