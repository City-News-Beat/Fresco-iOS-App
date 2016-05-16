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

#import "MagicalRecord.h"

@import UIKit;

@implementation FRSGallery
@synthesize currentContext = _currentContext;

@dynamic byline;
@dynamic caption;
@dynamic createdDate;
@dynamic editedDate;
@dynamic relatedStories;
@dynamic tags;
@dynamic uid;
@dynamic visibility;
@dynamic creator;
@dynamic posts;
@dynamic stories;
@dynamic articles;
@dynamic isLiked;
@dynamic numberOfLikes;
@dynamic repostedBy;

-(void)configureWithDictionary:(NSDictionary *)dict{
    self.tags = [[NSMutableDictionary alloc] init];
    self.uid = dict[@"id"];
    self.visibility = dict[@"visiblity"];
    self.createdDate = [FRSDateFormatter dateFromEpochTime:dict[@"time_created"] milliseconds:YES];
    self.caption = dict[@"caption"];
    self.byline = dict[@"byline"];
    [self addPostsWithArray:dict[@"posts"]];
    [self addArticlesWithArray:dict[@"articles"]];
    
    [self setValue:@([dict[@"liked"] boolValue]) forKey:@"isLiked"];
    [self setValue:@([dict[@"likes"] integerValue]) forKey:@"numberOfLikes"];
    
    NSString *repostedBy = dict[@"reposted_by"];
    
    if (repostedBy != Nil && repostedBy != (NSString *)[NSNull null] && ![repostedBy isEqualToString:@""]) {
        [self setValue:repostedBy forKey:@"repostedBy"];
    }
}

+(instancetype)initWithProperties:(NSDictionary *)properties context:(NSManagedObjectContext *)context {
    FRSGallery *gallery = [NSEntityDescription insertNewObjectForEntityForName:@"FRSGallery" inManagedObjectContext:context];
    gallery.currentContext = context;
    [gallery configureWithDictionary:properties];
    return gallery;
}


-(void)configureWithDictionary:(NSDictionary *)dict context:(NSManagedObjectContext *)context {
    _currentContext = context;
    save = TRUE;
    [self configureWithDictionary:dict];
}

-(void)addPostsWithArray:(NSArray *)posts{
    for (NSDictionary *dict in posts){
        if (save) {
            FRSPost *post = [NSEntityDescription insertNewObjectForEntityForName:@"FRSPost" inManagedObjectContext:self.currentContext];
            [post configureWithDictionary:dict context:_currentContext];
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
            FRSArticle *article = [NSEntityDescription insertNewObjectForEntityForName:@"FRSArticle" inManagedObjectContext:self.currentContext];
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
    
    float totalHeight = 0;
    
    for (FRSPost *post in self.posts){
        float rawHeight = [post.meta[@"image_height"] integerValue];
        float rawWidth = [post.meta[@"image_width"] integerValue];
        
        if (rawHeight == 0 || rawWidth == 0){
            totalHeight += [UIScreen mainScreen].bounds.size.width;
        }
        else {
            float scaledHeight = rawHeight * ([UIScreen mainScreen].bounds.size.width/rawWidth);
            totalHeight += scaledHeight;
        }
    }
    
    NSInteger averageHeight = ceilf(totalHeight/self.posts.count);
    
    averageHeight = MIN(averageHeight, [UIScreen mainScreen].bounds.size.width * 4/3);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 32, 0)];
    
    label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    label.text = self.caption;
    label.numberOfLines = 6;
    
    averageHeight += [label sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width-32, INT_MAX)].height + 12 + 44 + 20;
    
    return averageHeight;
}


// Insert code here to add functionality to your managed object subclass

@end
