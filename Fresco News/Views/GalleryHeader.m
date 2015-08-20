//
//  GalleryHeader.m
//  FrescoNews
//
//  Created by Fresco News on 3/17/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "GalleryHeader.h"
#import "FRSPost.h"
#import "FRSGallery.h"
#import <FXBlurView.h>

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
    
    if([post.address isKindOfClass:[NSString class]] && ![post.address isEqualToString:@"No Location"]){
    
        self.labelTimeAndPlace.text =  post.address;
        [self.labelTimeAndPlace sizeToFit];
        
    }
    else
        self.labelTimeAndPlace.text = @"";
    
    self.labelByLine.text =  [NSString stringWithFormat:@"%@  %@", post.byline, [MTLModel relativeDateStringFromDate:gallery.createTime]];

    
    self.backgroundColor = [UIColor whiteColor];
}

@end
