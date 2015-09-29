//
//  FRSGlanceInterfaceController.m
//  Fresco
//
//  Created by Fresco News on 3/31/15.
//  Copyright (c) 2015 Fresco News, Inc. All rights reserved.
//

#import "WKGlanceInterfaceController.h"
#import "WKImagePath.h"
#import <AFNetworking/AFNetworking.h>

@implementation WKGlanceInterfaceController

- (instancetype)init {
    
    self = [super init];
    
    if (self){
        // Initialize variables here.
        // Configure interface objects here.

        NSURL *baseURL = [NSURL URLWithString:@"https://api.fresconews.com/v1/"];
        
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager GET:@"gallery/highlights" parameters:@{@"limit" : @3} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSArray *galleries = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil][@"data"];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                
                NSInteger count = 0;
                
                //Loop through the galleries
                for (NSDictionary *gallery in galleries) {
                    
                    if(count == 0)
                        [self.firstImage setImageData:[NSData
                                                       dataWithContentsOfURL:[WKImagePath CDNImageURL:gallery[@"posts"][0][@"image"] withSize:SmallImageSize]]];
                    else if(count == 1)
                        [self.secondImage setImageData:[NSData
                                                       dataWithContentsOfURL:[WKImagePath CDNImageURL:gallery[@"posts"][0][@"image"] withSize:SmallImageSize]]];
                    else if(count == 2)
                        [self.thirdImage setImageData:[NSData
                                                       dataWithContentsOfURL:[WKImagePath CDNImageURL:gallery[@"posts"][0][@"image"] withSize:SmallImageSize]]];
                    
                    NSLog(@"%@",[WKImagePath CDNImageURL:gallery[@"posts"][0][@"image"] withSize:SmallImageSize].absoluteString);
                    
                    count++;
                    
                    
                }
            
            });
        
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
        
    }
    return self;
}

- (void)awakeWithContext:(id)context {
    
    [super awakeWithContext:context];
    
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



