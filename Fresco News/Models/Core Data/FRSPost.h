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

+(instancetype)postWithDictionary:(NSDictionary *)dict;
-(void)configureWithDictionary:(NSDictionary *)dict;
-(void)configureWithDictionary:(NSDictionary *)dict context:(NSManagedObjectContext *)context;
@property (nonatomic, weak) NSManagedObjectContext *currentContext;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) NSString *contentType;
@end

NS_ASSUME_NONNULL_END

#import "FRSPost+CoreDataProperties.h"
