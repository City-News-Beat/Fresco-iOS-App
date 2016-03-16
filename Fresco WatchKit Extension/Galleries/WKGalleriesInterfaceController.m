//
//  FRSGalleriesInterfaceController.m
//  Fresco
//
//  Created by Fresco News on 3/26/15.
//  Copyright (c) 2015 Fresco News, Inc. All rights reserved.
//

#import "WKGalleriesInterfaceController.h"
#import "WKGalleryRowController.h"
#import "WKRelativeDate.h"
#import "WKImagePath.h"
#import "Fresco.h"
#import <AFNetworking/AFNetworking.h>

@implementation WKGalleriesInterfaceController

- (void)awakeWithContext:(id)context {
    
    [super awakeWithContext:context];
    
    if(context == nil){
        
        NSURL *baseURL = [NSURL URLWithString:BASE_API];
        
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager GET:@"gallery/highlights" parameters:@{@"limit" : @7} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSArray *galleries = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil][@"data"];
            
            self.galleries = galleries;
            
            [self populateGalleries];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
    
    }
    //Context is sent i.e. pushed from Stories View
    else{
        
        [self setTitle:@"Story"];
        
        NSString *storyId = context;
    
        NSURL *baseURL = [NSURL URLWithString:BASE_API];
        
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager GET:@"story/galleries" parameters:@{@"id" : storyId, @"limit" : @7} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSArray *galleries = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil][@"data"];
            
            self.galleries = galleries;
            
            [self populateGalleries];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
    
        
    }
    

}

-(void)populateGalleries{

    //Populate table
    if(self.galleries){
        
        [self.postTable setNumberOfRows:[self.galleries count] withRowType:@"postRow"];
        
        for (NSInteger i = 0; i < self.galleries.count; i++) {
            
            WKGalleryRowController* row = [self.postTable rowControllerAtIndex:i];
            
            NSArray *posts = self.galleries[i][@"posts"];
            
            NSDate *date = [[NSDate date] initWithTimeIntervalSince1970:([(NSNumber *)self.galleries[i][@"time_created"] integerValue] / 1000)];
            
            [row.galleryTime setText:[WKRelativeDate relativeDateString:date]];
            
            [row.galleryLocation setText:self.galleries[i][@"caption"]];
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                
                //Background Thread
                [row.galleryGroup setBackgroundImageData:[NSData dataWithContentsOfURL:[WKImagePath CDNImageURL:posts[0][@"image"] withSize:SmallImageSize]]];
                
            });

        }
        
    }

}


- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex{
    
    NSDictionary *galleryData = [self.galleries objectAtIndex:rowIndex];
    
    [self pushControllerWithName:@"postDetail" context:galleryData];
    
}

@end



