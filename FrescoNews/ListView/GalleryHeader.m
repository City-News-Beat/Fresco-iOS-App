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

static NSString * const kCellIdentifier = @"StoryCellHeader";

@implementation GalleryHeader
+ (NSString *)identifier
{
    return kCellIdentifier;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setPost:(FRSPost *)post
{
    self.labelTimeAndPlace.text = [MTLModel relativeDateStringFromDate:post.date];
    self.labelByLine.text = post.byline;
}

- (void)setGallery:(FRSGallery *)gallery
{
    self.labelTimeAndPlace.text = [MTLModel relativeDateStringFromDate:gallery.createTime];
    self.labelByLine.text = gallery.byline;
}
@end
