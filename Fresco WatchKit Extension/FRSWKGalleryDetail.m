//
//  FRSWatchPostDetail.m
//  Fresco
//
//  Created by Elmir Kouliev on 3/16/15.
//  Copyright (c) 2015 Fresco News, Inc. All rights reserved.
//

#import "FRSWKGalleryDetail.h"

@implementation FRSWKGalleryDetail

- (void)awakeWithContext:(id)context{
    
    self.gallery = context;
    
    NSDictionary *post = self.gallery[@"posts"][0];
    
    [self updateUserActivity:@"com.fresconews.galleryView" userInfo:@{@"gallery" : [self.gallery objectForKey:@"_id"] }webpageURL:nil];
    
    [self.galleryLocation setText:post[@"location"][@"address"]];
    
#warning Set to relative
    //[self.postTime setText:[NSRelativeDate relativeDateString:context[@"timestamp"]]];

    [self.galleryCaption setText:context[@"caption"]];
    
    [self.galleryByline setText:post[@"byline"]];
    
    [self.galleryImage setImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:post[@"image"]]]];

}




@end
