//
//  FRSGalleriesInterfaceController.m
//  Fresco
//
//  Created by Elmir Kouliev on 3/26/15.
//  Copyright (c) 2015 Fresco News, Inc. All rights reserved.
//

#import "FRSGalleriesInterfaceController.h"
#import "FRSGalleryRowController.h"
#import <AFNetworking/AFNetworking.h>
#import "MTLModel+Additions.h"

@implementation FRSGalleriesInterfaceController

- (void)awakeWithContext:(id)context {
    
    [super awakeWithContext:context];
    
    if(context == nil){
        
        NSURL *baseURL = [NSURL URLWithString:@"https://api.fresconews.com/v1/"];
        
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager GET:@"gallery/highlights" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSArray *galleries = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil][@"data"];
            
            self.galleries = galleries;
            
            [self populateGalleries];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
    
    }
    else{
    
        // Configure interface objects here.
        self.galleries = context;
        
        [self setTitle:@"Story"]; 
        
        [self populateGalleries];
        
    }
    

}

-(void)populateGalleries{

    //Populate table
    if(self.galleries){
        
        [self.postTable setNumberOfRows:[self.galleries count] withRowType:@"postRow"];
        
        for (NSInteger i = 0; i < self.galleries.count; i++) {
            
            FRSGalleryRowController* row = [self.postTable rowControllerAtIndex:i];
            
            NSArray *posts = self.galleries[i][@"posts"];
            
//            NSDate *date = [[NSDate date] initWithTimeIntervalSince1970:([(NSNumber *)self.galleries[i][@"time_created"] integerValue] / 1000)];
//            
//            NSString *test = [MTLModel relativeDateStringFromDate:date];
            
            [row.galleryLocation setText:self.galleries[i][@"caption"]];
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                //Background Thread
                [row.galleryGroup setBackgroundImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:posts[0][@"image"]]]];
                
            });

        }
        
    }

}


- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex{
    
    NSDictionary *galleryData = [self.galleries objectAtIndex:rowIndex];
    
    [self pushControllerWithName:@"postDetail" context:galleryData];
    
}

- (void)willActivate {
    
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];

    
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



