//
//  FRSTaggedAssetModel+CoreDataProperties.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 6/14/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSTaggedAssetModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface FRSTaggedAssetModel (CoreDataProperties)

+ (NSFetchRequest<FRSTaggedAssetModel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *localIdentifier;
@property (nullable, nonatomic, copy) NSNumber *captureMode;

@end

NS_ASSUME_NONNULL_END
