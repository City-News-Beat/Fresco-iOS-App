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

#import "MagicalRecord.h"
#import "FRSAppDelegate.h"

@implementation FRSUser

// Insert code here to add functionality to your managed object subclass

+(FRSUser *)loggedInUser{
    FRSUser *user = [FRSUser MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"isLoggedIn == %@", @1]];
    return user;
}

+(instancetype)initWithProperties:(NSDictionary *)properties context:(NSManagedObjectContext *)context {
    FRSAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    FRSUser *user = [NSEntityDescription insertNewObjectForEntityForName:@"FRSUser" inManagedObjectContext:delegate.managedObjectContext];
    return user;
}

+(instancetype)nonSavedUserWithProperties:(NSDictionary *)properties context:(NSManagedObjectContext *)context {
    NSEntityDescription *userEntity = [NSEntityDescription entityForName:@"FRSUser" inManagedObjectContext:context];
    FRSUser *user = (FRSUser *)[[NSManagedObject alloc] initWithEntity:userEntity insertIntoManagedObjectContext:nil];
    return user;
}




@end
