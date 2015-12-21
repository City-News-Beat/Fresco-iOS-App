//
//  FRSArticle+CoreDataProperties.h
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FRSArticle.h"

NS_ASSUME_NONNULL_BEGIN

@interface FRSArticle (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *faviconStringUrl;
@property (nullable, nonatomic, retain) NSString *stringUrl;

@end

NS_ASSUME_NONNULL_END
