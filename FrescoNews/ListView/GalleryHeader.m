//
//  StoryCellHeader.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/17/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "GalleryHeader.h"
#import "FRSPost.h"
#import "FRSGallery.h"

@interface GalleryHeader ()
@property (weak, nonatomic) IBOutlet UILabel *labelTimeAndPlace;
@property (weak, nonatomic) IBOutlet UILabel *labelByLine;
@end

static NSString * const kCellIdentifier = @"GalleryHeader";

@implementation GalleryHeader
+ (NSString *)identifier
{
    return kCellIdentifier;
}

- (void)setGallery:(FRSGallery *)gallery
{
    self.labelTimeAndPlace.text = [NSString stringWithFormat:@"%@, %@", ((FRSPost *)[gallery.posts firstObject]).address,
                                                                        [MTLModel relativeDateStringFromDate:gallery.createTime]];
    self.labelByLine.text = ((FRSPost *)[gallery.posts firstObject]).byline;
}
@end
