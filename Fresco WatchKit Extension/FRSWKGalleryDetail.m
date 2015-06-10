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
    
    self.post = context;
    
    [self updateUserActivity:@"com.fresconews.postView" userInfo:@{@"postId" : [_post objectForKey:@"post_id"] }webpageURL:nil];
    
    [self.galleryLocation setText:context[@"location"]];
    
    #warning Set to relative
    //[self.postTime setText:[NSRelativeDate relativeDateString:context[@"timestamp"]]];

    [self.galleryCaption setText:context[@"caption"]];
    
    [self.galleryByline setText:context[@"byline"]];
    
    [self.galleryImage setImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:context[@"small_path"]]]];

}




@end
