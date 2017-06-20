//
//  FRSUserStory+CoreDataProperties.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 6/20/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSUserStory+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface FRSUserStory (CoreDataProperties)

+ (NSFetchRequest<FRSUserStory *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *caption;
@property (nullable, nonatomic, copy) NSDate *createdDate;
@property (nullable, nonatomic, copy) NSDate *editedDate;
@property (nullable, nonatomic, retain) NSObject *imageURLs;
@property (nullable, nonatomic, copy) NSNumber *index;
@property (nullable, nonatomic, copy) NSNumber *liked;
@property (nullable, nonatomic, copy) NSNumber *likes;
@property (nullable, nonatomic, copy) NSNumber *reposted;
@property (nullable, nonatomic, copy) NSString *reposted_by;
@property (nullable, nonatomic, copy) NSNumber *reposts;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *uid;
@property (nullable, nonatomic, retain) FRSUser *creator;

@end

NS_ASSUME_NONNULL_END
