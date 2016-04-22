//
//  FRSArticle+CoreDataProperties.h
//  Fresco
//
//  Created by Daniel Sun on 1/14/16.
//  Copyright © 2016 Fresco. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FRSArticle.h"
#import "FRSGallery.h"

NS_ASSUME_NONNULL_BEGIN

@interface FRSArticle (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *articleStringURL;
@property (nullable, nonatomic, retain) NSString *imageStringURL;
@property (nullable, nonatomic, retain) NSString *source;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *uid;
@property (nullable, nonatomic, retain) NSDate *createdDate;
@property (nullable, nonatomic, retain) FRSGallery *gallery;

@end

NS_ASSUME_NONNULL_END
