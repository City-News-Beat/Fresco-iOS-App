//
//  FRSUser.h
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FRSGallery, FRSPost, FRSStory;

NS_ASSUME_NONNULL_BEGIN

@interface FRSUser : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

+(FRSUser *)loggedInUser;




@end

NS_ASSUME_NONNULL_END

#import "FRSUser+CoreDataProperties.h"
