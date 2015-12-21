//
//  FRSAssignment+CoreDataProperties.h
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FRSAssignment.h"

NS_ASSUME_NONNULL_BEGIN

@interface FRSAssignment (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *uid;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *caption;
@property (nullable, nonatomic, retain) NSNumber *active;
@property (nullable, nonatomic, retain) id location;
@property (nullable, nonatomic, retain) NSNumber *radius;
@property (nullable, nonatomic, retain) NSDate *createdDate;
@property (nullable, nonatomic, retain) NSDate *editedDate;
@property (nullable, nonatomic, retain) NSDate *expirationDate;

@end

NS_ASSUME_NONNULL_END
