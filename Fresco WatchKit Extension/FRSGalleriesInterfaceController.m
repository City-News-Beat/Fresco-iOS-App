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
        
        [manager GET:@"http://www.fresconews.com/api/frs-query.php?type=getPosts&limit=8" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSArray *posts = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            
            _posts = posts;
            
            [self populatePosts];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
    
    }
    else{
    
        // Configure interface objects here.
        _posts = context;
        
        [self setTitle:@"Story"]; 
        
        [self populatePosts];
        
    }
    

}

-(void)populatePosts{

    //Populate table
    if(_posts){
        
        [_postTable setNumberOfRows:[_posts count] withRowType:@"postRow"];
        
        for (NSInteger i = 0; i < _posts.count; i++) {
            
            FRSGalleryRowController* row = [self.postTable rowControllerAtIndex:i];
            
#warning Set to relative
            
            [row.galleryTime setText:_posts[i][@"timestamp"]];
            
            [row.galleryLocation setText:_posts[i][@"caption"]];
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                //Background Thread
                [row.galleryGroup setBackgroundImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_posts[i][@"small_path"]]]];
                
            });

        }
        
    }

}


- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex{
    
    NSDictionary *postData = [_posts objectAtIndex:rowIndex];
    
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



