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

+(FRSUser *)loggedInUser {
    FRSUser *user = [FRSUser MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"isLoggedIn == %@", @(TRUE)]];
    return user;
}

+(instancetype)initWithProperties:(NSDictionary *)properties context:(NSManagedObjectContext *)context {
    FRSAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    FRSUser *user = [NSEntityDescription insertNewObjectForEntityForName:@"FRSUser" inManagedObjectContext:delegate.managedObjectContext];
    user.uid = properties[@"id"];
    user.firstName = (properties[@"full_name"] != Nil && ![properties[@"full_name"] isEqual:[NSNull null]] && [[properties[@"full_name"] class] isSubclassOfClass:[NSString class]]) ? properties[@"full_name"] : @"";;
    user.username = (properties[@"username"] != Nil) ? properties[@"username"] : @"";
    user.isLoggedIn = @(FALSE);
    user.bio = (properties[@"bio"] != Nil) ? properties[@"bio"] : @"";
    
    if ([[properties objectForKey:@"following"] boolValue]) {
        [user setValue:@(TRUE) forKey:@"following"];
    }
    else {
        [user setValue:@(FALSE) forKey:@"following"];
    }
    
    return user;
}

+(instancetype)nonSavedUserWithProperties:(NSDictionary *)properties context:(NSManagedObjectContext *)context {
    
    NSEntityDescription *userEntity = [NSEntityDescription entityForName:@"FRSUser" inManagedObjectContext:context];
    FRSUser *user = (FRSUser *)[[NSManagedObject alloc] initWithEntity:userEntity insertIntoManagedObjectContext:nil];
    user.uid = properties[@"id"];
    user.firstName = (properties[@"full_name"] != Nil && ![properties[@"full_name"] isEqual:[NSNull null]] && [[properties[@"full_name"] class] isSubclassOfClass:[NSString class]]) ? properties[@"full_name"] : @"";;
    user.username = (properties[@"username"] != Nil && ![properties[@"username"] isEqual:[NSNull null]]) ? properties[@"username"] : @"";
    user.isLoggedIn = @(FALSE);
    user.bio = (properties[@"bio"] != Nil) ? properties[@"bio"] : @"";
    
    if ([[properties objectForKey:@"following"] boolValue]) {
        [user setValue:@(TRUE) forKey:@"following"];
    }
    else {
        [user setValue:@(FALSE) forKey:@"following"];
    }
    
    if (properties[@"avatar"] && ![properties[@"avatar"] isEqual:[NSNull null]]) {
        user.profileImage = properties[@"avatar"];
    }

    return user;
}


-(NSDictionary *)jsonObject {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    
    if (self.uid) {
        jsonObject[@"id"] = self.uid;
    }
    if (self.bio) {
        jsonObject[@"bio"] = self.bio;
    }
    if (self.username) {
        jsonObject[@"username"] = self.username;
    }
    if (self.firstName) {
        jsonObject[@"full_name"] = self.firstName;
    }
    
    return jsonObject;
}



@end
