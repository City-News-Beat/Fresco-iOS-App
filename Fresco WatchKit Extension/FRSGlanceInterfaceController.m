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
        
        NSURL *baseURL = [NSURL URLWithString:@"https://api.fresconews.com/v1/"];
        
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager GET:@"gallery/highlights" parameters:@{@"limit" : @5} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSArray *galleries = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil][@"data"];
            
            //Loop through the galleries
            for (NSDictionary *gallery in galleries) {
                
                //Find a gallery with more than 3 images
                if([gallery[@"posts"] count] > 2){
                    
                    NSInteger count = 0;
                    
                    for (NSDictionary *post in gallery[@"posts"]) {
                        
                        NSString *image = post[@"image"];
                        
                        if (!([image rangeOfString:@"cloudfront"].location == NSNotFound)){
                            
                            NSMutableString *mu = [NSMutableString stringWithString:image];
                            
                            NSRange range = [mu rangeOfString:@"/images/"];
                            
                            if (!(range.location == NSNotFound)) {
                                
                                [mu insertString:@"small/" atIndex:(range.location + range.length)];
                                
                                image = mu;
                                
                            }
                            
                        }

                        if(count == 0)
                            [self.firstImage setImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:image]]];
                        else if(count == 1)
                            [self.secondImage setImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:image]]];
                        else if(count == 2)
                            [self.thirdImage setImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:image]]];
                        
                        count++;
                        
                    }
                    
                    return;
                    
                }
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];

        
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



