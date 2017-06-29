//
//  FRSUserStory+CoreDataClass.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 6/20/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSUserStory+CoreDataClass.h"
#import "FRSUser.h"
#import "FRSPost.h"
#import "FRSCoreData.h"
#import "FRSDateFormatter.h"
#import "MagicalRecord.h"
#import "FRSUserManager.h"
#import "NSString+Fresco.h"

@interface FRSUserStory () {
    
}
@property (nullable, nonatomic, retain) NSManagedObjectContext * currentContext;

@end

@implementation FRSUserStory

@synthesize postsCount = _postsCount, commentCount = _commentCOunt, sourceUser = _sourceUser, creator = _creator, curatorDict = _curatorDict, currentContext = _currentContext;

- (NSDictionary *)curatorDict {
    return _curatorDict;
}

- (void)setCuratorDict:(NSDictionary *)curatorDict {
    _curatorDict = curatorDict;
}

- (void)configureWithDictionary:(NSDictionary *)dict context:(NSManagedObjectContext *)context {
    _currentContext = context;
    
    save = TRUE;

    self.caption = dict[@"caption"];
    
    if ([dict valueForKey:@"created_at"] != nil && ![[dict valueForKey:@"created_at"] isEqual:[NSNull null]]) {
        self.createdDate = [NSString dateFromString:dict[@"created_at"]];
    }
    
//    if (dict[@"updated_at"] && ![dict[@"updated_at"] isEqual:[NSNull null]]) {
//        self.editedDate = [NSString dateFromString:dict[@"updated_at"]];
//    }
    
    self.title = dict[@"title"];
    self.uid = dict[@"id"];
    self.commentCount = (NSNumber *)dict[@"comment_count"];
//    self.imageURLs = [self imagesURLsFromThumbnails:dict[@"thumbnails"]];
//    self.postsCount = dict[@"galleries"];
    
//    if ([[dict valueForKey:@"reposted"] boolValue]) {
//        [self setValue:@(TRUE) forKey:@"reposted"];
//    } else {
//        [self setValue:@(FALSE) forKey:@"reposted"];
//    }
//    
//    if ([[dict valueForKey:@"liked"] boolValue]) {
//        [self setValue:@(TRUE) forKey:@"liked"];
//        
//    } else {
//        [self setValue:@(FALSE) forKey:@"liked"];
//    }
//    
//    NSNumber *reposts = [dict valueForKey:@"reposts"];
//    [self setValue:reposts forKey:@"reposts"];
//    
//    NSNumber *likes = [dict valueForKey:@"likes"];
//    [self setValue:likes forKey:@"likes"];
    
//    if (![dict[@"curator"] isEqual:[NSNull null]]) {
//        self.curatorDict = dict[@"curator"];
//    }
    
//    NSString *repostedBy = [dict valueForKey:@"reposted_by"];
//    
//    if (repostedBy != Nil && ![repostedBy isEqual:[NSNull null]]) {
//        [self setValue:repostedBy forKey:@"reposted_by"];
//        
//        NSArray *sources = (NSArray *)dict[@"sources"];
//        if ([[sources class] isSubclassOfClass:[NSArray class]] && sources.count > 0) {
//            
//            NSString *repostedBy = dict[@"reposted_by"];
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", repostedBy];
//            NSArray *results = [sources filteredArrayUsingPredicate:predicate];
//            NSDictionary *source = (NSDictionary *)[results firstObject];
//            NSString *userID = source[@"user_id"];
//            
//            [[FRSUserManager sharedInstance] getUserWithUID:userID
//                                                 completion:^(id responseObject, NSError *error) {
//                                                     FRSUser *user = [FRSUser nonSavedUserWithProperties:responseObject context:[[FRSUserManager sharedInstance] managedObjectContext]];
//                                                     self.sourceUser = user;
//                                                 }];
//        }
//    }
    
    if (!self.posts || self.posts.count == 0) {
        [self addPostsWithArray:dict[@"posts"]];
    }
    
    // DEBUG
    self.editedDate = [NSDate date];
    self.creator = [[FRSUserManager sharedInstance] authenticatedUser];
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

- (NSInteger)heightForUserStory {
    
    NSInteger imageViewHeight = IS_IPHONE_5 ? 192 : 240;
    
    if (self.caption.length == 0) {
        imageViewHeight = imageViewHeight - 12;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 32, 0)];
    label.text = self.caption;
    label.numberOfLines = 6;
    label.font = [UIFont systemFontOfSize:15 weight:-1];
    [label sizeToFit];
    
    // 44 is tab bar, 11 is top padding, 13 is bottom padding
    imageViewHeight += label.frame.size.height + 44 + 11 + 13;
    return imageViewHeight;
}

- (NSArray *)imagesURLsFromThumbnails:(NSArray *)thumbnails {
    NSMutableArray *mArr = [NSMutableArray new];
    
    for (NSDictionary *thumb in thumbnails) {
        NSString *stringURL = thumb[@"image"];
        if (!stringURL)
            continue;
        NSURL *url = [NSURL URLWithString:stringURL];
        
        if (url) {
            [mArr addObject:url];
        }
    }
    
    return [mArr copy];
}

//+ (instancetype)initWithProperties:(NSDictionary *)properties context:(NSManagedObjectContext *)context {
//    FRSUserStory *userStory = [NSEntityDescription insertNewObjectForEntityForName:@"FRSUserStory" inManagedObjectContext:context];
//    [userStory configureWithDictionary:properties context:<#(nonnull NSManagedObjectContext *)#>];
//    return userStory;
//}

- (NSDictionary *)jsonObject {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    
    return jsonObject;
}

@end
