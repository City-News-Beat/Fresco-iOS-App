//
//  FRSWatchPostDetail.m
//  Fresco
//
//  Created by Fresco News on 3/16/15.
//  Copyright (c) 2015 Fresco News, Inc. All rights reserved.
//

#import "WKGalleryDetailController.h"
#import "WKImageRowController.h"
#import "WKRelativeDate.h"
#import "WKImagePath.h"

@implementation WKGalleryDetailController

- (void)awakeWithContext:(id)context{
    
    self.gallery = context;
    
    NSDictionary *post = self.gallery[@"posts"][0];
    
    [self updateUserActivity:@"com.fresconews.galleryView" userInfo:@{@"gallery" : [self.gallery objectForKey:@"_id"] }webpageURL:nil];
    
    [self.galleryLocation setText:post[@"location"][@"address"]];
    
    NSDate *date = [[NSDate date] initWithTimeIntervalSince1970:([(NSNumber *)self.gallery[@"time_created"] integerValue] / 1000)];
    
    [self.galleryTime setText:[WKRelativeDate relativeDateString:date]];

    [self.galleryCaption setText:context[@"caption"]];
    
    [self.galleryByline setText:post[@"byline"]];
    
    [self populateImages];

}

- (void)populateImages{
    
    NSInteger count = [self.gallery[@"posts"] count];
    
    [self.galleryImages setNumberOfRows:count withRowType:@"imageRow"];
    
    for (NSInteger i = 0; i < count; i++) {
        
        WKImageRowController* imageRow = [self.galleryImages rowControllerAtIndex:i];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){

            
            //Background Thread
            [imageRow.postImage setImageData:[NSData dataWithContentsOfURL:[WKImagePath
                                                                            CDNImageURL:self.gallery[@"posts"][i][@"image"]
                                                                            withSize:SmallImageSize]]];
        
        });
    }
}




@end
