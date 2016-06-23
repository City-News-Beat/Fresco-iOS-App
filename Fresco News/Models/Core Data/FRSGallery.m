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
@import UIKit;

@implementation FRSGallery
@synthesize currentContext = _currentContext, generatedHeight = _generatedHeight;

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
    
    [self setValue:@([dict[@"liked"] boolValue]) forKey:@"liked"];
    [self setValue:@([dict[@"likes"] integerValue]) forKey:@"likes"];
    
    NSString *repostedBy = dict[@"source"];
    
    if (repostedBy != Nil && repostedBy != (NSString *)[NSNull null] && ![repostedBy isEqualToString:@""]) {
        [self setValue:repostedBy forKey:@"reposted_by"];
    }
    
    [self setValue:@([dict[@"reposts"] intValue]) forKey:@"reposts"];
    [self setValue:@([dict[@"reposted"] boolValue]) forKey:@"reposted"];
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
            NSLog(@"SAVE");
            FRSPost *post = [NSEntityDescription insertNewObjectForEntityForName:@"FRSPost" inManagedObjectContext:self.currentContext];
            [post configureWithDictionary:dict context:_currentContext];
            [self addPostsObject:post];
        }
        else {
            NSEntityDescription *galleryEntity = [NSEntityDescription entityForName:@"FRSPost" inManagedObjectContext:self.currentContext];
            FRSPost *post = (FRSPost *)[[NSManagedObject alloc] initWithEntity:galleryEntity insertIntoManagedObjectContext:nil];
            
            if (dict[@"owner"] != [NSNull null]) {
                if (!dict[@"owner"][@"avatar"]) {
                    return;
                }
                post.creator.profileImage = dict[@"owner"][@"avatar"];
            }
            [post configureWithDictionary:dict context:self.currentContext save:FALSE];
            [self addPostsObject:post];
        }
    }
}

-(void)addArticlesWithArray:(NSArray *)articles{
    for (NSDictionary * dict in articles){
        if (save) {
            FRSArticle *article = [NSEntityDescription insertNewObjectForEntityForName:@"FRSArticle" inManagedObjectContext:self.currentContext];
            [article configureWithDictionary:dict];
            [self addArticlesObject:article];
        }
        else {
            NSEntityDescription *galleryEntity = [NSEntityDescription entityForName:@"FRSArticle" inManagedObjectContext:self.currentContext];
            FRSArticle *article = (FRSArticle *)[[NSManagedObject alloc] initWithEntity:galleryEntity insertIntoManagedObjectContext:nil];
            [self addArticlesObject:article];
        }
    }
    
}

-(NSInteger)heightForGallery{
    
    if (self.generatedHeight) {
        return self.generatedHeight;
    }
    
    float totalHeight = 0;
    
    for (FRSPost *post in self.posts){
        float rawHeight = [post.meta[@"image_height"] integerValue];
        float rawWidth = [post.meta[@"image_width"] integerValue];
        
        if (rawHeight <= 0 || rawWidth <= 0){
            totalHeight += [UIScreen mainScreen].bounds.size.width;
            continue;
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
    
    self.generatedHeight = averageHeight;
    
    return averageHeight;
}

-(NSDictionary *)jsonObject {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    
    
    return jsonObject;
}

// Insert code here to add functionality to your managed object subclass

@end
