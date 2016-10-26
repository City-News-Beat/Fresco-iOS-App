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
@synthesize dueBy = _dueBy, requiredFields = _requiredFields;

// Insert code here to add functionality to your managed object subclass

+(FRSUser *)loggedInUser {
    FRSUser *user = [FRSUser MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"isLoggedIn == %@", @(TRUE)]];
    return user;
}

+(instancetype)initWithProperties:(NSDictionary *)properties context:(NSManagedObjectContext *)context {
    FRSAppDelegate *delegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    FRSUser *user = [NSEntityDescription insertNewObjectForEntityForName:@"FRSUser" inManagedObjectContext:delegate.managedObjectContext];
    user.uid = properties[@"id"];
    user.firstName = (properties[@"full_name"] != Nil && ![properties[@"full_name"] isEqual:[NSNull null]] && [[properties[@"full_name"] class] isSubclassOfClass:[NSString class]]) ? properties[@"full_name"] : @"";;
    user.username = (properties[@"username"] != Nil) ? properties[@"username"] : @"";
    user.isLoggedIn = @(FALSE);
    user.bio = (properties[@"bio"] != Nil) ? properties[@"bio"] : @"";
    
    user.email = (properties[@"email"] != nil) ? properties[@"email"] : @"";
    
    if (properties[@"external_account_name"] != Nil && ![properties[@"external_account_name"] isEqual:[NSNull null]]) {
        [user setValue:properties[@"external_account_name"] forKey:@"external_name"];
    }
    
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
    
    if (properties[@"due_by"] && ![properties[@"due_by"] isEqual:[NSNull null]]) {
        user.dueBy = properties[@"due_by"];
    }
    
    if (properties[@"fields_needed"] && ![properties[@"fields_needed"] isEqual:[NSNull null]]) {
        user.fieldsNeeded = properties[@"fields_needed"];
    }
    
    if (properties[@"disabled_reason"] && ![properties[@"disabled_reason"] isEqual:[NSNull null]]) {
        user.disabledReason = properties[@"disabled_reason"];
    }
    
    if (properties[@"blocked"] && ![properties[@"blocked"] isEqual:[NSNull null]]) {
        user.blocked = [properties[@"blocked"] boolValue];
    }
    
    if (properties[@"blocking"] && ![properties[@"blocking"] isEqual:[NSNull null]]) {
        user.blocking = [properties[@"blocking"] boolValue];
    }
    
    if (properties[@"suspended_until"] && ![properties[@"suspended_until"] isEqual:[NSNull null]]) {
        user.suspended = YES;
    } else {
        user.suspended = NO;
    }
    
    if (properties[@"disabled"] && ![properties[@"disabled"] isEqual:[NSNull null]]) {
        user.disabled = [properties[@"disabled"] boolValue];
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
    user.bio = (properties[@"bio"] != Nil && ![properties[@"bio"] isEqual:[NSNull null]]) ? properties[@"bio"] : @"";
    user.following = (properties[@"following"] != Nil && ![properties[@"following"] isEqual:[NSNull null]]) ? properties[@"following"] : 0;
    
    user.email = (properties[@"email"] != nil && ![properties[@"email"] isEqual:[NSNull null]]) ? properties[@"email"] : @"";
    
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
    
    if (properties[@"blocked"] && ![properties[@"blocked"] isEqual:[NSNull null]]) {
        user.blocked = [properties[@"blocked"] boolValue];
    }
    
    if (properties[@"blocking"] && ![properties[@"blocking"] isEqual:[NSNull null]]) {
        user.blocking = [properties[@"blocking"] boolValue];
    }
    
    if (properties[@"suspended_until"] && ![properties[@"suspended_until"] isEqual:[NSNull null]]) {
        user.suspended = YES;
    } else {
        user.suspended = NO;
    }
    
    if (properties[@"disabled"] && ![properties[@"disabled"] isEqual:[NSNull null]]) {
        user.disabled = [properties[@"disabled"] boolValue];
    }

    return user;
}


-(void)configureWithDictionary:(NSDictionary *)properties {
    
    if ([properties isEqual:[NSNull null]]) {
        return;
    }
    
    self.uid = (properties[@"id"] != nil ? properties[@"id"] : @"");
    
    if (!properties || [properties isEqual:[NSNull null]]){
        return;
    }
    
    self.firstName = (properties[@"full_name"] != Nil && ![properties[@"full_name"] isEqual:[NSNull null]] && [[properties[@"full_name"] class] isSubclassOfClass:[NSString class]]) ? properties[@"full_name"] : @"";;
    self.username = (properties[@"username"] != Nil && ![properties[@"username"] isEqual:[NSNull null]]) ? properties[@"username"] : @"";
    self.isLoggedIn = @(FALSE);
    self.bio = (properties[@"bio"] != Nil) ? properties[@"bio"] : @"";
    self.following = (properties[@"following"] != Nil) ? properties[@"following"] : 0;
    
    self.email = (properties[@"email"] != nil) ? properties[@"email"] : @"";
    
    if (properties[@"location"] != Nil && ![properties[@"location"] isEqual:[NSNull null]]) {
        [self setValue:properties[@"location"] forKey:@"location"];
        NSLog(@"USER LOC: %@",properties[@"location"]);
    }
    
    if (properties[@"followed_count"] != Nil && ![properties[@"followed_count"] isEqual:[NSNull null]]) {
        [self setValue:properties[@"followed_count"] forKey:@"followedCount"];
    }
    if (properties[@"following_count"] != Nil && ![properties[@"following_count"] isEqual:[NSNull null]]) {
        [self setValue:properties[@"following_count"] forKey:@"followingCount"];
    }
    
    if ([[properties objectForKey:@"following"] boolValue]) {
        [self setValue:@(TRUE) forKey:@"following"];
    }
    else {
        [self setValue:@(FALSE) forKey:@"following"];
    }
    
    if (properties[@"avatar"] && ![properties[@"avatar"] isEqual:[NSNull null]]) {
        self.profileImage = properties[@"avatar"];
    }
    
    if (properties[@"blocked"] && ![properties[@"blocked"] isEqual:[NSNull null]]) {
        self.blocked = [properties[@"blocked"] boolValue];
    }
    
    if (properties[@"blocking"] && ![properties[@"blocking"] isEqual:[NSNull null]]) {
        self.blocking = [properties[@"blocking"] boolValue];
    }
    
    if (properties[@"suspended_until"] && ![properties[@"suspended_until"] isEqual:[NSNull null]]) {
        self.suspended = YES;
    } else {
        self.suspended = NO;
    }
    
    if (properties[@"disabled"] && ![properties[@"disabled"] isEqual:[NSNull null]]) {
        self.disabled = [properties[@"disabled"] boolValue];
    }
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
