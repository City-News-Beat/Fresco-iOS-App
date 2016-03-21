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
#import "FRSCoreData.h"

#import "FRSDateFormatter.h"

#import "FRSDataValidator.h"
#import <MagicalRecord/MagicalRecord.h>

@import UIKit;

@implementation FRSGallery
@synthesize currentContext = _currentContext;

-(void)configureWithDictionary:(NSDictionary *)dict{
    self.uid = dict[@"_id"];
    self.visibility = dict[@"visiblity"];
    self.createdDate = [FRSDateFormatter dateFromEpochTime:dict[@"time_created"] milliseconds:YES];
    self.caption = dict[@"caption"];
    self.byline = dict[@"byline"];
    [self addPostsWithArray:dict[@"posts"]];
    [self addArticlesWithArray:dict[@"articles"]];
}

-(void)configureWithDictionary:(NSDictionary *)dict context:(NSManagedObjectContext *)context {
    _currentContext = context;
    [self configureWithDictionary:dict];
}

-(void)addPostsWithArray:(NSArray *)posts{
    for (NSDictionary *dict in posts){
        
        if (_currentContext) {
            FRSPost *post = [FRSPost MR_createEntityInContext:_currentContext];
            [post configureWithDictionary:dict];
            if (dict[@"owner"]) {
                if (!dict[@"owner"][@"avatar"]) {
                    return;
                }
                post.creator.profileImage = dict[@"owner"][@"avatar"];
            }
            
            [self addPostsObject:post];
        }
        else {
            FRSPost *post = [FRSPost postWithDictionary:dict];            
            if (dict[@"owner"] != [NSNull null]) {
                if (!dict[@"owner"][@"avatar"]) {
                    return;
                }
                post.creator.profileImage = dict[@"owner"][@"avatar"];
            }
            
            [self addPostsObject:post];
        }
    }
}

-(void)addArticlesWithArray:(NSArray *)articles{
    for (NSDictionary * dict in articles){
        if (_currentContext) {
            FRSArticle *article = [FRSArticle MR_createEntityInContext:_currentContext];
            [article configureWithDictionary:dict];
            [self addArticlesObject:article];
        }
        else {
            FRSArticle *article = [FRSArticle articleWithDictionary:dict];
            [self addArticlesObject:article];
        }
    }
    
}

-(NSInteger)heightForGallery{
    
    NSInteger totalHeight = 0;
    
    for (FRSPost *post in self.posts){
        NSInteger rawHeight = [post.meta[@"image_height"] integerValue];
        NSInteger rawWidth = [post.meta[@"image_width"] integerValue];
        
        if (rawHeight == 0 || rawWidth == 0){
            totalHeight += [UIScreen mainScreen].bounds.size.width;
        }
        else {
            NSInteger scaledHeight = rawHeight * ([UIScreen mainScreen].bounds.size.width/rawWidth);
            totalHeight += scaledHeight;
        }
    }
    
    NSInteger averageHeight = totalHeight/self.posts.count;
    
    averageHeight = MIN(averageHeight, [UIScreen mainScreen].bounds.size.width * 4/3);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 32, 0)];
    
    label.font = [UIFont systemFontOfSize:15 weight:-1];
    label.text = self.caption;
    label.numberOfLines = 6;
    
    [label sizeToFit];
    
    averageHeight += label.frame.size.height + 12 + 44 + 20;
    
    return averageHeight;
}


// Insert code here to add functionality to your managed object subclass

@end
