//
//  FRSAssignment+CoreDataProperties.h
//  Fresco
//
//  Created by Daniel Sun on 1/19/16.
//  Copyright © 2016 Fresco. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FRSAssignment.h"

NS_ASSUME_NONNULL_BEGIN

@interface FRSAssignment (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *active;
@property (nullable, nonatomic, retain) NSString *caption;
@property (nullable, nonatomic, retain) NSDate *createdDate;
@property (nullable, nonatomic, retain) NSDate *editedDate;
@property (nullable, nonatomic, retain) NSDate *expirationDate;
@property (nullable, nonatomic, retain) id location;
@property (nullable, nonatomic, retain) NSNumber *radius;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *uid;
@property (nullable, nonatomic, retain) NSString *address;

@end

NS_ASSUME_NONNULL_END
