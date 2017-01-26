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
#import "FRSUser.h"

NS_ASSUME_NONNULL_BEGIN
@interface FRSGallery (CoreDataProperties)

@property (nullable, nonatomic, retain) FRSUser *creator;
@property (nonatomic) NSNumber *likes;
@property (nonatomic) NSNumber *liked;
@property (nonatomic) NSNumber *rating;
@end

NS_ASSUME_NONNULL_END
