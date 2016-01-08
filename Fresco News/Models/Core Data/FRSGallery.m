//
//  FRSGallery.m
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSGallery.h"
#import "FRSPost.h"
#import "FRSStory.h"
#import "FRSUser.h"

#import "FRSDateFormatter.h"

#import "FRSDataValidator.h"

@implementation FRSGallery

-(void)configureWithDictionary:(NSDictionary *)dict{
    self.uid = dict[@"_id"];
    self.visibility = dict[@"visiblity"];
    self.createdDate = [FRSDateFormatter dateFromEpochTime:dict[@"time_created"]];
    self.caption = dict[@"caption"];
    self.byline = dict[@"byline"];
    [self addPostsWithArray:dict[@"posts"]];
}

-(void)addPostsWithArray:(NSArray *)posts{
    for (NSDictionary *dict in posts){
        FRSPost *post = [FRSPost postWithDictionary:dict];
        [self addPostsObject:post];
    }
}


// Insert code here to add functionality to your managed object subclass

@end
