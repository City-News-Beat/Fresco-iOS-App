//
//  StoryCellHeader.m
//  FrescoNews
//
//  Created by Jason Gresh on 3/17/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "StoryCellHeader.h"
#import "FRSPost.h"
#import "FRSGallery.h"

@interface StoryCellHeader ()
@property (weak, nonatomic) IBOutlet UILabel *labelTimeAndPlace;
@property (weak, nonatomic) IBOutlet UILabel *labelByLine;
@end

static NSString * const kCellIdentifier = @"StoryCellHeader";

@implementation StoryCellHeader
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
