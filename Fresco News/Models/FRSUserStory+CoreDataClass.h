//
//  FRSUserStory+CoreDataClass.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 6/20/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FRSUser, NSObject;

NS_ASSUME_NONNULL_BEGIN

@interface FRSUserStory : NSManagedObject {
    BOOL save;
}

@property (nonatomic, retain) NSNumber *postsCount;
@property (nonatomic, retain) NSNumber *commentCount;
@property (strong, nonatomic, retain) NSDictionary *curatorDict;
@property (nullable, nonatomic, retain) FRSUser *sourceUser;
@property (nullable, nonatomic, retain) FRSUser *creator;

- (void)configureWithDictionary:(NSDictionary *)dict context:(NSManagedObjectContext *)context;
- (NSDictionary *)jsonObject;
- (NSInteger)heightForUserStory;

@end

NS_ASSUME_NONNULL_END

#import "FRSUserStory+CoreDataProperties.h"
