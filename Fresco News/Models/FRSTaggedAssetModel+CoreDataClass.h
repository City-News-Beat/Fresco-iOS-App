//
//  FRSTaggedAssetModel+CoreDataClass.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 6/14/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface FRSTaggedAssetModel : NSManagedObject

+ (NSPredicate *)predicateWithLocalIdentifier:(NSString *)localIdentifier;
+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "FRSTaggedAssetModel+CoreDataProperties.h"
