//
//  FRSUser.m
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSUser.h"
#import "FRSGallery.h"
#import "FRSPost.h"
#import "FRSStory.h"

#import <MagicalRecord/MagicalRecord.h>


@implementation FRSUser

// Insert code here to add functionality to your managed object subclass

+(FRSUser *)loggedInUser{
    FRSUser *user = [FRSUser MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"isLoggedIn == %@", @1]];
    return user;
}

+(instancetype)initWithProperties:(NSDictionary *)properties context:(NSManagedObjectContext *)context {
    FRSUser *user = [FRSUser MR_createEntityInContext:context];
    return user;
}




@end
