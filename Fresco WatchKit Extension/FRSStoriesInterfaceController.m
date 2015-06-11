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
#import "MTLModel+Additions.h"
#import <AFNetworking/AFNetworking.h>

@implementation FRSStoriesInterfaceController

- (void)awakeWithContext:(id)context {
    
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:@"http://www.fresconews.com/api/frs-query.php?type=getTagsWithPosts&watch=true" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *stories = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        _stories = stories;
        
        if(_stories != nil){
            
            [self populateStories];
        
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
    
}

- (void)populateStories{

    [_storyTable setNumberOfRows:[_stories count] withRowType:@"storyRow"];
    
    for (NSInteger i = 0; i < _stories.count; i++) {
        
        FRSStoryRowController* row = [self.storyTable rowControllerAtIndex:i];
        
        [row.storyTitle setText:_stories[i][@"identifier"]];
        
        [row.storyLocation setText:_stories[i][@"location"]];
        
#warning Set to relative date
//        [row.storyTime setText:[NSRelativeDate relativeDateString:[MTLModel relativeDateStringFromDate:gallery.createTime]]];
//        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            //Background Thread
            if([((NSArray *)_stories[i][@"posts"]) count] > 0)
                
                [row.storyImage1 setImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_stories[i][@"posts"][0][@"small_path"]]]];
            
            if([((NSArray *)_stories[i][@"posts"]) count] > 1)
                
                [row.storyImage2 setImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_stories[i][@"posts"][1][@"small_path"]]]];
            
        });
        
        
    }

}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex{
    
    NSDictionary *posts = [_stories objectAtIndex:rowIndex][@"posts"];
    
    [self pushControllerWithName:@"posts" context:posts];
    
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



