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
    
    user.email = (properties[@"email"] != nil) ? properties[@"email"] : @"";
    
    if (properties[@"location"] != Nil && ![properties[@"location"] isEqual:[NSNull null]]) {
        [user setValue:properties[@"location"] forKey:@"location"];
        NSLog(@"USER LOC: %@",properties[@"location"]);
    }
    
    if (properties[@"followed_count"] != Nil && ![properties[@"followed_count"] isEqual:[NSNull null]]) {
        [user setValue:properties[@"followed_count"] forKey:@"followedCount"];
    }
    if (properties[@"following_count"] != Nil && ![properties[@"following_count"] isEqual:[NSNull null]]) {
        [user setValue:properties[@"following_count"] forKey:@"followingCount"];
    }
    
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

+(instancetype)nonSavedUserWithProperties:(NSDictionary *)properties context:(NSManagedObjectContext *)context {
    
    NSEntityDescription *userEntity = [NSEntityDescription entityForName:@"FRSUser" inManagedObjectContext:context];
    FRSUser *user = (FRSUser *)[[NSManagedObject alloc] initWithEntity:userEntity insertIntoManagedObjectContext:nil];
    
    if ([properties isEqual:[NSNull null]]) {
        return user;
    }
    
    user.uid = (properties[@"id"] != nil ? properties[@"id"] : @"");
    
    if (!properties || [properties isEqual:[NSNull null]]){
        return user;
    }
    
    user.firstName = (properties[@"full_name"] != Nil && ![properties[@"full_name"] isEqual:[NSNull null]] && [[properties[@"full_name"] class] isSubclassOfClass:[NSString class]]) ? properties[@"full_name"] : @"";;
    user.username = (properties[@"username"] != Nil && ![properties[@"username"] isEqual:[NSNull null]]) ? properties[@"username"] : @"";
    user.isLoggedIn = @(FALSE);
    user.bio = (properties[@"bio"] != Nil) ? properties[@"bio"] : @"";
    user.following = (properties[@"following"] != Nil) ? properties[@"following"] : 0;
    
    user.email = (properties[@"email"] != nil) ? properties[@"email"] : @"";
    
    if (properties[@"location"] != Nil && ![properties[@"location"] isEqual:[NSNull null]]) {
        [user setValue:properties[@"location"] forKey:@"location"];
        NSLog(@"USER LOC: %@",properties[@"location"]);
    }
    
    if (properties[@"followed_count"] != Nil && ![properties[@"followed_count"] isEqual:[NSNull null]]) {
        [user setValue:properties[@"followed_count"] forKey:@"followedCount"];
    }
    if (properties[@"following_count"] != Nil && ![properties[@"following_count"] isEqual:[NSNull null]]) {
        [user setValue:properties[@"following_count"] forKey:@"followingCount"];
    }

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
