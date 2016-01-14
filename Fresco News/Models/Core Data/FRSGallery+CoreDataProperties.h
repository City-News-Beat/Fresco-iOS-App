//
//  FRSGallery+CoreDataProperties.h
//  Fresco
//
//  Created by Daniel Sun on 1/14/16.
//  Copyright © 2016 Fresco. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FRSGallery.h"
#import "FRSArticle.h"

NS_ASSUME_NONNULL_BEGIN

@interface FRSGallery (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *byline;
@property (nullable, nonatomic, retain) NSString *caption;
@property (nullable, nonatomic, retain) NSDate *createdDate;
@property (nullable, nonatomic, retain) NSDate *editedDate;
@property (nullable, nonatomic, retain) id relatedStories;
@property (nullable, nonatomic, retain) id tags;
@property (nullable, nonatomic, retain) NSString *uid;
@property (nullable, nonatomic, retain) NSString *visibility;
@property (nullable, nonatomic, retain) FRSUser *creator;
@property (nullable, nonatomic, retain) NSSet<FRSPost *> *posts;
@property (nullable, nonatomic, retain) NSSet<FRSStory *> *stories;
@property (nullable, nonatomic, retain) NSSet<FRSArticle *> *articles;

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

@end

NS_ASSUME_NONNULL_END
