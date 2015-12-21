//
//  FRSGallery+CoreDataProperties.h
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FRSGallery.h"

NS_ASSUME_NONNULL_BEGIN

@interface FRSGallery (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *byline;
@property (nullable, nonatomic, retain) NSString *caption;
@property (nullable, nonatomic, retain) NSDate *createdDate;
@property (nullable, nonatomic, retain) NSDate *editedDate;
@property (nullable, nonatomic, retain) NSString *uid;
@property (nullable, nonatomic, retain) NSString *visibility;
@property (nullable, nonatomic, retain) id articles;
@property (nullable, nonatomic, retain) id relatedStories;
@property (nullable, nonatomic, retain) id tags;
@property (nullable, nonatomic, retain) FRSUser *creator;
@property (nullable, nonatomic, retain) NSSet<FRSPost *> *posts;
@property (nullable, nonatomic, retain) NSSet<FRSStory *> *stories;

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

@end

NS_ASSUME_NONNULL_END
