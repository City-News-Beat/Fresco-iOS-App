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
@dynamic externalAccountID;
@dynamic externalAccountName;
@dynamic externalID;
@dynamic externalSource;
@dynamic externalURL;

-(NSArray *)sorted {
    NSArray *sorted;
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:YES];
    sorted=[self.posts sortedArrayUsingDescriptors:@[sort]];

    return sorted;
}
-(void)configureWithDictionary:(NSDictionary *)dict{
    NSLog(@"THE DIC: %@", dict);
    self.tags = [[NSMutableDictionary alloc] init];
    self.uid = dict[@"id"];
    self.visibility = dict[@"visiblity"];
    self.createdDate = [FRSDateFormatter dateFromEpochTime:dict[@"time_created"] milliseconds:YES];
    self.caption = dict[@"caption"];
    if([dict valueForKey:@"owner"] != [NSNull null] && [[dict valueForKey:@"owner"] valueForKey:@"full_name"] != [NSNull null]){
        self.byline = dict[@"owner"][@"full_name"];
    }
    NSLog(@"BYLINE: %@", self.byline);

//    if ([dict valueForKey:@"curator"] != [NSNull null]) {
//        self.creator = [FRSUser MR_createEntity];
//        self.creator.uid = (dict[@"curator"][@"id"] != nil) ? dict[@"curator"][@"id"] : @"";
//        self.creator.username = (dict[@"curator"][@"username"] != nil) ? dict[@"curator"][@"username"] : @"";
//        self.creator.username = (dict[@"curator"][@"full_name"] != nil) ? dict[@"curator"][@"full_name"] : @"";
//        //blocked
//    }
    
    if ([dict valueForKey:@"external_account_id"] != [NSNull null]) {
        self.externalAccountID = [dict objectForKey:@"external_account_id"];
    }
    
    if ([dict valueForKey:@"external_account_name"] != [NSNull null]) {
        self.externalAccountName = [dict objectForKey:@"external_account_name"];
    }
    
    if ([dict valueForKey:@"external_account_id"] != [NSNull null]) {
        self.externalID = [dict objectForKey:@"external_account_id"];
    }
    
    if ([dict valueForKey:@"external_source"] != [NSNull null]) {
        self.externalSource = [dict objectForKey:@"external_source"];
    }
    
    if ([dict valueForKey:@"external_url"] != [NSNull null]) {
        self.externalURL = [dict objectForKey:@"external_url"];
    }
    
    if (!self.posts || self.posts.count == 0) {
        [self addPostsWithArray:dict[@"posts"]];
    }
    
    if (self.articles.count == 0) {
        [self addArticlesWithArray:dict[@"articles"]];        
    }
    
    [self setValue:@([dict[@"liked"] boolValue]) forKey:@"liked"];
    [self setValue:@([dict[@"likes"] integerValue]) forKey:@"likes"];
    
    NSString *repostedBy = dict[@"reposted_by"];
    
    if (repostedBy != Nil && repostedBy != (NSString *)[NSNull null] && ![repostedBy isEqualToString:@""]) {
        [self setValue:repostedBy forKey:@"reposted_by"];
    }
    
    int comments = [dict[@"comments"] intValue];
    [self setValue:@(comments) forKey:@"comments"];
    
    [self setValue:@([dict[@"reposts"] intValue]) forKey:@"reposts"];
    [self setValue:@([dict[@"reposted"] boolValue]) forKey:@"reposted"];
}

+(instancetype)initWithProperties:(NSDictionary *)properties context:(NSManagedObjectContext *)context {
    FRSGallery *gallery = [NSEntityDescription insertNewObjectForEntityForName:@"FRSGallery" inManagedObjectContext:context];
    gallery.currentContext = context;
//    [gallery configureWithDictionary:properties context:context];

    return gallery;
}

 
-(void)configureWithDictionary:(NSDictionary *)dict context:(NSManagedObjectContext *)context {
    _currentContext = context;
    save = TRUE;
    [self configureWithDictionary:dict];
    
//    self.creator = [FRSUser MR_createEntityInContext:context];
//    
//    if ([dict valueForKey:@"curator"] != [NSNull null]) {
//        self.creator = [FRSUser MR_createEntity];
//        self.creator.uid = (dict[@"curator"][@"id"] != nil) ? dict[@"curator"][@"id"] : @"";
//        self.creator.username = (dict[@"curator"][@"username"] != nil) ? dict[@"curator"][@"username"] : @"";
//        self.creator.username = (dict[@"curator"][@"full_name"] != nil) ? dict[@"curator"][@"full_name"] : @"";
//        //blocked
//    }

}

-(void)addPostsWithArray:(NSArray *)posts{
        
    for (NSDictionary *dict in posts){
        if (save) {
            FRSPost *post = [NSEntityDescription insertNewObjectForEntityForName:@"FRSPost" inManagedObjectContext:self.currentContext];
            [post configureWithDictionary:dict context:_currentContext];
            [self addPostsObject:post];
        }
        else {
            NSEntityDescription *galleryEntity = [NSEntityDescription entityForName:@"FRSPost" inManagedObjectContext:self.currentContext];
            FRSPost *post = (FRSPost *)[[NSManagedObject alloc] initWithEntity:galleryEntity insertIntoManagedObjectContext:nil];
            
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
    
    if ([self checkVal:[self valueForKey:@"caption"]]) {
        jsonObject[@"caption"] = [self valueForKey:@"caption"];
    }
    
    NSMutableArray *posts = [[NSMutableArray alloc] init];
    
    for (FRSPost *post in self.posts.allObjects) {
        [posts addObject:[post jsonObject]];
    }
    
    jsonObject[@"posts_new"] = posts;
    
    return jsonObject;
}

-(BOOL)checkVal:(id)val {
    if (val && ![val isEqual:[NSNull null]]) {
        return TRUE;
    }
    
    return FALSE;
}

@end
