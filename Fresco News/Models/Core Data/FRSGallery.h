//
//  FRSGallery.h
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FRSCoreData.h"
#import "FRSPost.h"
#import "FRSArticle.h"
#import "FRSCoreData.h"

#import "FRSDateFormatter.h"
#import "MagicalRecord.h"

@class FRSPost, FRSStory, FRSUser;

NS_ASSUME_NONNULL_BEGIN

@interface FRSGallery : NSManagedObject <FRSManagedObject> {
    BOOL save;
}
// Insert code here to declare functionality of your managed object subclass
- (void)configureWithDictionary:(NSDictionary *)dict;
- (void)configureWithDictionary:(NSDictionary *)dict context:(NSManagedObjectContext *)context;
@property (nullable, nonatomic, retain) NSString *byline;
@property (nullable, nonatomic, retain) NSString *caption;
@property (nullable, nonatomic, retain) NSString *comments;
@property (nullable, nonatomic, retain) NSDate *createdDate;
@property (nullable, nonatomic, retain) NSDate *editedDate;
@property (nullable, nonatomic, retain) id relatedStories;
@property (nullable, nonatomic, retain) NSString *uid;
@property (nullable, nonatomic, retain) NSString *visibility;
@property (nullable, nonatomic, retain) NSSet<FRSPost *> *posts;
@property (nullable, nonatomic, retain) NSSet<FRSStory *> *stories;
@property (nullable, nonatomic, retain) NSSet<FRSArticle *> *articles;
@property (nullable, nonatomic, retain) NSMutableDictionary *tags;
@property (nullable, nonatomic, retain) NSString *externalAccountID;
@property (nullable, nonatomic, retain) NSString *externalAccountName;
@property (nullable, nonatomic, retain) NSString *externalID;
@property (nullable, nonatomic, retain) NSString *externalSource;
@property (nullable, nonatomic, retain) NSString *externalURL;
@property (nullable, nonatomic, retain) FRSUser *sourceUser;

@property (nonatomic, assign) BOOL isLiked;
@property (nonatomic, assign) NSInteger numberOfLikes;
@property (nonatomic, assign) NSInteger numberOfReposts;
@property (nonatomic, assign) NSInteger verificationRating;
@property (nonatomic, assign) NSNumber *rating;
@property (nonatomic) NSInteger generatedHeight;
- (NSInteger)heightForGallery;
@property (nonatomic, weak) NSManagedObjectContext *currentContext;

@end

@interface FRSGallery (CoreDataGeneratedAccessors)

- (void)addPostsObject:(FRSPost *)value;
- (void)removePostsObject:(FRSPost *)value;
- (void)addPosts:(NSSet<FRSPost *> *)values;
- (void)removePosts:(NSSet<FRSPost *> *)values;

- (void)addStoriesObject:(FRSStory *)value;
- (void)removeStoriesObject:(FRSStory *)value;
- (void)addStories:(NSSet<FRSStory *> *)values;
- (void)removeStories:(NSSet<FRSStory *> *)values;

- (void)addArticlesObject:(FRSArticle *)value;
- (void)removeArticlesObject:(FRSArticle *)value;
- (void)addArticles:(NSSet<FRSArticle *> *)values;
- (void)removeArticles:(NSSet<FRSArticle *> *)values;
- (NSArray *)sorted;
- (NSDictionary *)jsonObject;
@end

NS_ASSUME_NONNULL_END

#import "FRSGallery+CoreDataProperties.h"
