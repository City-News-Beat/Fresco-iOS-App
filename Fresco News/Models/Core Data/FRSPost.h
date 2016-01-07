//
//  FRSPost.h
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FRSGallery, FRSUser;

NS_ASSUME_NONNULL_BEGIN

@interface FRSPost : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

-(void)configureWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

#import "FRSPost+CoreDataProperties.h"
