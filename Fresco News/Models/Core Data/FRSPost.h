//
//  FRSPost.h
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class FRSGallery, FRSUser;

NS_ASSUME_NONNULL_BEGIN

@interface FRSPost : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

+ (instancetype)postWithDictionary:(NSDictionary *)dict;
- (void)configureWithDictionary:(NSDictionary *)dict;
- (void)configureWithDictionary:(NSDictionary *)dict context:(NSManagedObjectContext *)context;
- (void)configureWithDictionary:(NSDictionary *)dict context:(NSManagedObjectContext *)context save:(BOOL)save;
@property (nonatomic, weak) NSManagedObjectContext *currentContext;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) NSString *contentType;
- (NSDictionary *)jsonObject;

/**
 Handles all fallback on the byline on a post`

 @param post FRSPost object
 @return NSString formatted with expected byline fall back
 */
+ (NSString *)bylineForPost:(FRSPost *)post;

@end

NS_ASSUME_NONNULL_END

#import "FRSPost+CoreDataProperties.h"
