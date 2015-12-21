//
//  FRSStory+CoreDataProperties.h
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FRSStory.h"

NS_ASSUME_NONNULL_BEGIN

@interface FRSStory (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *caption;
@property (nullable, nonatomic, retain) NSDate *createdDate;
@property (nullable, nonatomic, retain) NSDate *editedDate;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *uid;
@property (nullable, nonatomic, retain) FRSUser *creator;
@property (nullable, nonatomic, retain) NSSet<FRSGallery *> *galleries;

@end

@interface FRSStory (CoreDataGeneratedAccessors)

- (void)addGalleriesObject:(FRSGallery *)value;
- (void)removeGalleriesObject:(FRSGallery *)value;
- (void)addGalleries:(NSSet<FRSGallery *> *)values;
- (void)removeGalleries:(NSSet<FRSGallery *> *)values;

@end

NS_ASSUME_NONNULL_END
