//
//  FRSUser+CoreDataProperties.h
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FRSUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface FRSUser (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *associatedPromoCode;
@property (nullable, nonatomic, retain) NSString *bio;
@property (nullable, nonatomic, retain) NSString *creditCardDigits;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) NSNumber *isLoggedIn;
@property (nullable, nonatomic, retain) NSString *lastName;
@property (nullable, nonatomic, retain) NSNumber *loginType;
@property (nullable, nonatomic, retain) NSNumber *notificationRadius;
@property (nullable, nonatomic, retain) NSString *password;
@property (nullable, nonatomic, retain) id profileImage;
@property (nullable, nonatomic, retain) NSString *uid;
@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *galleries;
@property (nullable, nonatomic, retain) NSSet<FRSPost *> *posts;
@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *stories;

@end

@interface FRSUser (CoreDataGeneratedAccessors)

- (void)addGalleriesObject:(NSManagedObject *)value;
- (void)removeGalleriesObject:(NSManagedObject *)value;
- (void)addGalleries:(NSSet<NSManagedObject *> *)values;
- (void)removeGalleries:(NSSet<NSManagedObject *> *)values;

- (void)addPostsObject:(FRSPost *)value;
- (void)removePostsObject:(FRSPost *)value;
- (void)addPosts:(NSSet<FRSPost *> *)values;
- (void)removePosts:(NSSet<FRSPost *> *)values;

- (void)addStoriesObject:(NSManagedObject *)value;
- (void)removeStoriesObject:(NSManagedObject *)value;
- (void)addStories:(NSSet<NSManagedObject *> *)values;
- (void)removeStories:(NSSet<NSManagedObject *> *)values;

@end

NS_ASSUME_NONNULL_END
