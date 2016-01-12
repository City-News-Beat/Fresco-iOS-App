//
//  FRSAssignment.h
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface FRSAssignment : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

+(instancetype)assignmentWithDictionary:(NSDictionary *)dictionary;

-(void)configureWithDictionary:(NSDictionary *)dictionary;


@end

NS_ASSUME_NONNULL_END

#import "FRSAssignment+CoreDataProperties.h"
