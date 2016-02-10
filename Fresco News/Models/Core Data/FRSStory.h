//
//  FRSStory.h
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FRSGallery, FRSUser;

NS_ASSUME_NONNULL_BEGIN






@interface FRSStory : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

-(void)configureWithDictionary:(NSDictionary *)dict;

-(NSInteger)heightForStory;

@end

NS_ASSUME_NONNULL_END

#import "FRSStory+CoreDataProperties.h"
