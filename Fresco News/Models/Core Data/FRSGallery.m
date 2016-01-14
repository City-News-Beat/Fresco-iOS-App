//
//  FRSGallery.m
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSGallery.h"
#import "FRSPost.h"
#import "FRSArticle.h"
#import "FRSStory.h"
#import "FRSUser.h"

#import "FRSDateFormatter.h"

#import "FRSDataValidator.h"

@implementation FRSGallery

-(void)configureWithDictionary:(NSDictionary *)dict{
    self.uid = dict[@"_id"];
    self.visibility = dict[@"visiblity"];
    self.createdDate = [FRSDateFormatter dateFromEpochTime:dict[@"time_created"] milliseconds:YES];
    self.caption = dict[@"caption"];
    self.byline = dict[@"byline"];
    [self addPostsWithArray:dict[@"posts"]];
    [self addArticlesWithArray:dict[@"articles"]];
}

-(void)addPostsWithArray:(NSArray *)posts{
    for (NSDictionary *dict in posts){
        FRSPost *post = [FRSPost postWithDictionary:dict];
        [self addPostsObject:post];
    }
}

-(void)addArticlesWithArray:(NSArray *)articles{
    for (NSDictionary * dict in articles){
        FRSArticle *article = [FRSArticle articleWithDictionary:dict];
        [self addArticlesObject:article];
    }
    
}


// Insert code here to add functionality to your managed object subclass

@end
