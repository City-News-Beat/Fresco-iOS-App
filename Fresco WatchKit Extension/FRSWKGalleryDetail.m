//
//  FRSWatchPostDetail.m
//  Fresco
//
//  Created by Fresco News on 3/16/15.
//  Copyright (c) 2015 Fresco News, Inc. All rights reserved.
//

#import "FRSWKGalleryDetail.h"
#import "NSRelativeDate.h"

@implementation FRSWKGalleryDetail

- (void)awakeWithContext:(id)context{
    
    self.gallery = context;
    
    NSDictionary *post = self.gallery[@"posts"][0];
    
    [self updateUserActivity:@"com.fresconews.galleryView" userInfo:@{@"gallery" : [self.gallery objectForKey:@"_id"] }webpageURL:nil];
    
    [self.galleryLocation setText:post[@"location"][@"address"]];
    
    NSDate *date = [[NSDate date] initWithTimeIntervalSince1970:([(NSNumber *)self.gallery[@"time_created"] integerValue] / 1000)];
    
    [self.galleryTime setText:[NSRelativeDate relativeDateString:date]];

    [self.galleryCaption setText:context[@"caption"]];
    
    [self.galleryByline setText:post[@"byline"]];
    
    [self.galleryImage setImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:post[@"image"]]]];

}




@end
