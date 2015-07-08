//
//  FRSStoriesInterfaceController.m
//  Fresco
//
//  Created by Elmir Kouliev on 3/26/15.
//  Copyright (c) 2015 Fresco News, Inc. All rights reserved.
//

#import "FRSStoriesInterfaceController.h"
#import "FRSStoryRowController.h"
#import "FRSWKGalleryDetail.h"
#import "NSRelativeDate.h"
#import <AFNetworking/AFNetworking.h>

@implementation FRSStoriesInterfaceController

- (void)awakeWithContext:(id)context {
    
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    
    NSURL *baseURL = [NSURL URLWithString:@"https://api.fresconews.com/v1/"];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:@"story/recent?limit=4" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *stories = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil][@"data"];
        
        self.stories = stories;
        
        if(self.stories != nil){
            
            [self populateStories];
        
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
    
}

- (void)populateStories{

    [self.storyTable setNumberOfRows:[_stories count] withRowType:@"storyRow"];
    
    for (NSInteger i = 0; i < _stories.count; i++) {
        
        FRSStoryRowController* row = [self.storyTable rowControllerAtIndex:i];
        
        [row.storyTitle setText:self.stories[i][@"title"]];
        
        [row.storyLocation setText:self.stories[i][@"thumbnails"][0][@"location"][@"address"]];
        
        NSDate *date = [[NSDate date]
                        initWithTimeIntervalSince1970:([(NSNumber *)self.stories[i][@"thumbnails"][0][@"time_created"] integerValue] / 1000)];

        [row.storyTime setText:[NSRelativeDate relativeDateString:date]];
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            //Background Thread
            if([((NSArray *)self.stories[i][@"thumbnails"]) count] > 0)
                
                [row.storyImage1 setImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.stories[i][@"thumbnails"][0][@"image"]]]];
            
            if([((NSArray *)self.stories[i][@"thumbnails"]) count] > 1)
                
                [row.storyImage2 setImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_stories[i][@"thumbnails"][1][@"image"]]]];
            
        });
        
        
    }

}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex{
    
    NSDictionary *galleries = [_stories objectAtIndex:rowIndex][@"galleries"];
    
    [self pushControllerWithName:@"galleries" context:galleries];
    
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



