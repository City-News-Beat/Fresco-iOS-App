//
//  FRSTaggedAssetModel+CoreDataProperties.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 6/14/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSTaggedAssetModel+CoreDataProperties.h"

@implementation FRSTaggedAssetModel (CoreDataProperties)

+ (NSFetchRequest<FRSTaggedAssetModel *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"FRSTaggedAssetModel"];
}

@dynamic localIdentifier;
@dynamic captureMode;

@end
