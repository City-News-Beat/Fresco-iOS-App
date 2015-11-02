//
//  GalleryTableViewCell.m
//  FrescoNews
//
//  Created by Fresco News on 3/25/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "GalleryTableViewCell.h"
#import "GalleryView.h"
#import "FRSGallery.h"

static NSString * const kCellIdentifier = @"GalleryTableViewCell";

@implementation GalleryTableViewCell

+ (NSString *)identifier
{
    return kCellIdentifier;
}


- (void)prepareForReuse
{
    self.gallery = nil;
    self.galleryView.pageControl.hidden = NO;
}

- (void)setGallery:(FRSGallery *)gallery
{
    _gallery = gallery;
    
    self.labelCaption.text = self.gallery.caption;
    
    [self.galleryView setGallery:gallery shouldBeginPlaying:NO withDynamicAspectRatio:NO];
    
    [self.shareButtonView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareGallery:)]];
}

#pragma mark - UIButtons Actions

- (IBAction)readMore:(id)sender {
    
    [self.galleryTableViewCellDelegate readMoreTapped:self.gallery];
    
}

- (IBAction)shareGallery:(id)sender {
    
    [self.galleryTableViewCellDelegate shareTapped:self.gallery];
    
}

@end
