//
//  FRSPost+CoreDataProperties.h
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FRSPost.h"

NS_ASSUME_NONNULL_BEGIN

@interface FRSPost (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *byline;
@property (nullable, nonatomic, retain) NSDate *createdDate;
@property (nullable, nonatomic, retain) id image;
@property (nullable, nonatomic, retain) NSString *imageUrl;
@property (nullable, nonatomic, retain) NSNumber *mediaType;
@property (nullable, nonatomic, retain) NSString *source;
@property (nullable, nonatomic, retain) NSString *uid;
@property (nullable, nonatomic, retain) NSString *videoUrl;
@property (nullable, nonatomic, retain) NSString *visibility;
@property (nullable, nonatomic, retain) FRSUser *creator;
@property (nullable, nonatomic, retain) FRSGallery *gallery;



@end

NS_ASSUME_NONNULL_END
