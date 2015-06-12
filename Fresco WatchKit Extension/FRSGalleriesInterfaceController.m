//
//  FRSPostsInterfaceController.m
//  Fresco
//
//  Created by Elmir Kouliev on 3/26/15.
//  Copyright (c) 2015 Fresco News, Inc. All rights reserved.
//

#import "FRSGalleriesInterfaceController.h"
#import "FRSGalleryRowController.h"
#import <AFNetworking/AFNetworking.h>


@implementation FRSGalleriesInterfaceController



- (void)awakeWithContext:(id)context {
    
    [super awakeWithContext:context];
    
    if(context == nil){
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager GET:@"http://52.6.231.245/v1/gallery/highlights?stories=true" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSArray *galleries = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            
            self.galleries = galleries;
            
            [self populateGalleries];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
    
    }
    else{
    
        // Configure interface objects here.
        _galleries = context;
        
        [self setTitle:@"Story"]; 
        
        [self populateGalleries];
        
    }
    

}

-(void)populateGalleries{

    //Populate table
    if(_galleries){
        
        [_postTable setNumberOfRows:[_galleries count] withRowType:@"postRow"];
        
        for (NSInteger i = 0; i < self.galleries.count; i++) {
            
            FRSGalleryRowController* row = [self.postTable rowControllerAtIndex:i];
            
            #warning Set to relative
            [row.galleryTime setText:self.galleries[i][@"timestamp"]];
            
            [row.galleryLocation setText:self.galleries[i][@"caption"]];
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                //Background Thread
                [row.galleryGroup setBackgroundImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.galleries[i][@"small_path"]]]];
                
            });

        }
        
    }

}


- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex{
    
    NSDictionary *postData = [self.galleries objectAtIndex:rowIndex];
    
    [self pushControllerWithName:@"postDetail" context:postData];
    
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



