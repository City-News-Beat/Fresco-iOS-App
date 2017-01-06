//
//  FRSUser.h
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FRSCoreData.h"

@class FRSGallery, FRSPost, FRSStory;

NS_ASSUME_NONNULL_BEGIN

@interface FRSUser : NSManagedObject <FRSManagedObject>

// Insert code here to declare functionality of your managed object subclass
@property (nullable, nonatomic, retain) NSString *dueBy;
@property (nonatomic, retain) NSArray *requiredFields;
+ (FRSUser *)loggedInUser;
+ (instancetype)nonSavedUserWithProperties:(NSDictionary *)properties context:(NSManagedObjectContext *)context;
- (NSDictionary *)jsonObject;
- (void)configureWithDictionary:(NSDictionary *)properties;
@end

NS_ASSUME_NONNULL_END

#import "FRSUser+CoreDataProperties.h"
