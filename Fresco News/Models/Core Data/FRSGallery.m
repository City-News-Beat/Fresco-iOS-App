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
#import "FRSUserManager.h"
#import "NSString+Fresco.h"

@import UIKit;

@implementation FRSGallery
@synthesize currentContext = _currentContext, generatedHeight = _generatedHeight, sourceUser = _sourceUser;

@dynamic byline;
@dynamic caption;
@dynamic comments;
@dynamic createdDate;
@dynamic editedDate;
@dynamic highlightedDate;
@dynamic relatedStories;
@dynamic tags;
@dynamic uid;
@dynamic visibility;
@dynamic posts;
@dynamic stories;
@dynamic articles;
@dynamic isLiked;
@dynamic verificationRating;
@dynamic numberOfLikes;
@dynamic numberOfReposts;
@dynamic externalAccountID;
@dynamic externalAccountName;
@dynamic externalID;
@dynamic externalSource;
@dynamic externalURL;
@dynamic rating;

- (NSArray *)sorted {
    NSArray *sorted;

    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
    sorted = [self.posts sortedArrayUsingDescriptors:@[ sort ]];

    return sorted;
}

- (void)configureWithDictionary:(NSDictionary *)dict {
    self.tags = [[NSMutableDictionary alloc] init];
    self.uid = dict[@"id"];
    self.visibility = dict[@"visiblity"];
    self.createdDate = [NSString dateFromString:dict[@"time_created"]];

    if (dict[@"updated_at"] && ![dict[@"updated_at"] isEqual:[NSNull null]]) {
        self.editedDate = [NSString dateFromString:dict[@"updated_at"]];
    }

    if (dict[@"captured_at"] && ![dict[@"captured_at"] isEqual:[NSNull null]]) {
        self.createdDate = [NSString dateFromString:dict[@"captured_at"]];
    } else if (dict[@"created_at"] && ![dict[@"created_at"] isEqual:[NSNull null]]) {
        self.createdDate = [NSString dateFromString:dict[@"created_at"]];
    }
    
    
    if (dict[@"highlighted_at"] && ![dict[@"highlighted_at"] isEqual:[NSNull null]]) {
        self.highlightedDate = [NSString dateFromString:dict[@"highlighted_at"]];
    }


    if (dict[@"rating"] && ![dict[@"rating"] isEqual:[NSNull null]]) {
        self.rating = dict[@"rating"];
    }

    if (dict[@"byline"] && ![dict[@"byline"] isEqual:[NSNull null]]) {
        self.byline = dict[@"byline"];
    }

    if (dict[@"caption"] && ![dict[@"caption"] isEqual:[NSNull null]]) {
        self.caption = dict[@"caption"];
    }

    NSArray *sources = (NSArray *)dict[@"sources"];
    if ([[sources class] isSubclassOfClass:[NSArray class]] && sources.count > 0) {

        NSString *repostedBy = dict[@"reposted_by"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", repostedBy];
        NSArray *results = [sources filteredArrayUsingPredicate:predicate];
        NSDictionary *source = (NSDictionary *)[results firstObject];
        NSString *userID = source[@"user_id"];

        if(userID != nil) {
            [[FRSUserManager sharedInstance] getUserWithUID:userID
                                                 completion:^(id responseObject, NSError *error) {
                                                     FRSUser *user = [FRSUser nonSavedUserWithProperties:responseObject context:[[FRSUserManager sharedInstance] managedObjectContext]];
                                                     self.sourceUser = user;
                                                 }];
        }
    }

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

    if ([dict valueForKey:@"rating"] != [NSNull null]) {
        self.verificationRating = [[dict objectForKey:@"rating"] integerValue];
    }

    if (!self.posts || self.posts.count == 0) {
        [self addPostsWithArray:dict[@"posts"]];
    }

    if (self.articles.count == 0) {
        [self addArticlesWithArray:dict[@"articles"]];
    }

    [self setValue:@([dict[@"liked"] boolValue]) forKey:@"liked"];
    [self setValue:@([dict[@"likes"] integerValue]) forKey:@"likes"];

    [self setValue:@([dict[@"reposted"] boolValue]) forKey:@"reposted"];
    [self setValue:@([dict[@"reposts"] integerValue]) forKey:@"reposts"];

    NSString *repostedBy = dict[@"reposted_by"];

    if (repostedBy != Nil && repostedBy != (NSString *)[NSNull null] && ![repostedBy isEqualToString:@""]) {
        [self setValue:repostedBy forKey:@"reposted_by"];
    }

    int comments = [dict[@"comments"] intValue];
    [self setValue:@(comments) forKey:@"comments"];
    self.comments = dict[@"comments"];

    [self setValue:@([dict[@"reposts"] intValue]) forKey:@"reposts"];
    [self setValue:@([dict[@"reposted"] boolValue]) forKey:@"reposted"];
}

+ (instancetype)initWithProperties:(NSDictionary *)properties context:(NSManagedObjectContext *)context {
    FRSGallery *gallery = [NSEntityDescription insertNewObjectForEntityForName:@"FRSGallery" inManagedObjectContext:context];
    gallery.currentContext = context;
    return gallery;
}

- (void)configureWithDictionary:(NSDictionary *)dict context:(NSManagedObjectContext *)context {
    _currentContext = context;
    save = TRUE;
    
    // Configure the gallery
    [self configureWithDictionary:dict];
    
    // User configuration needs to happen once the gallery has completed configuring
    // to avoid a nil entity name 'FRSUser'
    [self configureCreatorWithDictionary:dict];
}

- (void)configureCreatorWithDictionary:(NSDictionary *)dict {

    NSString *dictKey = @"";

    // Default to the the gallerys owner, fall back on the curator if the owner is not found
    if (dict[@"owner"] != [NSNull null] && dict[@"owner"] != nil) {
        dictKey = @"owner";
    } else if (dict[@"curator"] != [NSNull null] && dict[@"curator"] != nil) {
        dictKey = @"curator";
    } else {
        NSLog(@"Unable to find owner or curator on gallery");
        return;
    }

    // Create and save new user on gallery only if creator has changed
    if (!self.creator) {
        self.creator = [NSEntityDescription insertNewObjectForEntityForName:@"FRSUser" inManagedObjectContext:[self managedObjectContext]];
        [self.creator configureWithDictionary:dict[dictKey]];
    }
}

- (void)addPostsWithArray:(NSArray *)posts {

    int i = 0;
    for (NSDictionary *dict in posts) {
        if (save) {
            FRSPost *post = [NSEntityDescription insertNewObjectForEntityForName:@"FRSPost" inManagedObjectContext:self.currentContext];
            [post setValue:@(i) forKey:@"index"];
            [post configureWithDictionary:dict context:_currentContext];
            [self addPostsObject:post];
        } else {
            NSEntityDescription *galleryEntity = [NSEntityDescription entityForName:@"FRSPost" inManagedObjectContext:self.currentContext];
            FRSPost *post = (FRSPost *)[[NSManagedObject alloc] initWithEntity:galleryEntity insertIntoManagedObjectContext:nil];
            [post setValue:@(i) forKey:@"index"];
            [post configureWithDictionary:dict context:self.currentContext save:FALSE];
            [self addPostsObject:post];
        }
        i++;
    }
}

- (void)addArticlesWithArray:(NSArray *)articles {
    for (NSDictionary *dict in articles) {
        if (save) {
            FRSArticle *article = [NSEntityDescription insertNewObjectForEntityForName:@"FRSArticle" inManagedObjectContext:self.currentContext];
            [article configureWithDictionary:dict];
            [self addArticlesObject:article];
        } else {
            NSEntityDescription *galleryEntity = [NSEntityDescription entityForName:@"FRSArticle" inManagedObjectContext:self.currentContext];
            FRSArticle *article = (FRSArticle *)[[NSManagedObject alloc] initWithEntity:galleryEntity insertIntoManagedObjectContext:nil];
            [article configureWithDictionary:dict];
            [self addArticlesObject:article];
        }
    }
}

- (NSInteger)heightForGallery {

    if (self.generatedHeight) {
        return self.generatedHeight;
    }

    float totalHeight = 0;

    for (FRSPost *post in self.posts) {
        NSInteger rawHeight = [post.meta[@"image_height"] integerValue];
        NSInteger rawWidth = [post.meta[@"image_width"] integerValue];

        if (rawHeight == 0 || rawWidth == 0) {
            totalHeight += [UIScreen mainScreen].bounds.size.width;
        } else {
            NSInteger scaledHeight = rawHeight * ([UIScreen mainScreen].bounds.size.width / rawWidth);
            totalHeight += scaledHeight;
        }
    }

    float divider = self.posts.count;
    if (divider == 0) {
        divider = 1;
    }

    NSInteger averageHeight = totalHeight / divider;

    averageHeight = MIN(averageHeight, [UIScreen mainScreen].bounds.size.width * 4 / 3);

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 32, 0)];

    label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    label.text = self.caption;
    label.numberOfLines = 6;

    averageHeight += [label sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 32, INT_MAX)].height + 12 + 44 + 20;

    self.generatedHeight = averageHeight;

    return averageHeight;
}

- (NSDictionary *)jsonObject {
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

- (BOOL)checkVal:(id)val {
    if (val && ![val isEqual:[NSNull null]]) {
        return TRUE;
    }

    return FALSE;
}

@end
