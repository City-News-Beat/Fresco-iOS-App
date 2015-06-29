//
//  GalleryHeader.m
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
    FRSPost *post = (FRSPost *)[gallery.posts firstObject];
    self.labelTimeAndPlace.text = [MTLModel relativeDateStringFromDate:gallery.createTime];

    if(post.address){
        self.labelTimeAndPlace.text = [NSString stringWithFormat:@"%@, %@", post.address, self.labelTimeAndPlace.text];
    }

    self.labelByLine.text = post.byline;
}

@end
