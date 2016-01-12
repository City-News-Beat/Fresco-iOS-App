//
//  FRSArticle+CoreDataProperties.h
//  Fresco
//
//  Created by Daniel Sun on 1/12/16.
//  Copyright © 2016 Fresco. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FRSArticle.h"

NS_ASSUME_NONNULL_BEGIN

@interface FRSArticle (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *articleStringURL;
@property (nullable, nonatomic, retain) NSString *source;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *imageStringURL;

@end

NS_ASSUME_NONNULL_END
