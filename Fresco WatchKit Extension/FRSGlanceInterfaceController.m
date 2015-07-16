//
//  FRSGlanceInterfaceController.m
//  Fresco
//
//  Created by Fresco News on 3/31/15.
//  Copyright (c) 2015 Fresco News, Inc. All rights reserved.
//

#import "FRSGlanceInterfaceController.h"
#import <AFNetworking/AFNetworking.h>

@implementation FRSGlanceInterfaceController

- (instancetype)init {
    self = [super init];
    if (self){
        // Initialize variables here.
        // Configure interface objects here.
      
        
    }
    return self;
}

- (void)awakeWithContext:(id)context {
    
    [super awakeWithContext:context];
    
    //Check if there is context, if there isn't, get the posts from the app
    if(context == nil){
        
//        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        
//        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//        
//        [manager GET:@"http://www.fresconews.com/api/frs-query.php?type=getPosts&limit=4" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            
//            _posts = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
//            
//            if(_posts != nil){
//            
//                [self.firstImage setImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_posts[0][@"small_path"]]]];
//                
//                [self.secondImage setImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_posts[1][@"small_path"]]]];
//                
//                [self.thirdImage setImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_posts[2][@"small_path"]]]];
//                
//            }
//            
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"%@", error);
//        }];

        
    }
    
    
    [self.firstImage setImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:context[@"image1"]]]];
    
    
    // Configure interface objects here.
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



