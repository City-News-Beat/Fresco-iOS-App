//
//  FRSTaggedAssetModel+CoreDataClass.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 6/14/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSTaggedAssetModel+CoreDataClass.h"

@implementation FRSTaggedAssetModel

+ (NSPredicate *)predicateWithLocalIdentifier:(NSString *)localIdentifier {
    NSPredicate *assetModelPredicate = [NSPredicate predicateWithFormat:@"localIdentifier == %@", localIdentifier];
    return assetModelPredicate;
}

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"FRSTaggedAssetModel"
                                         inManagedObjectContext:context];
}

@end
