//
//  FRSUser.m
//  Fresco
//
//  Created by Moshe Berman on 2/2/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import "FRSUser.h"
#import <Parse/Parse.h>

@implementation FRSUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"first" : @"first",
             @"last" : @"last",
             @"email" : @"email",
             @"userID" : @"_id"
             };
}

+ (NSString *)loggedInUserId;
{
#warning Need to add logout support
    static NSString *loggedInUserId = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        [[PFUser currentUser] fetch];
        loggedInUserId = [[PFUser currentUser] objectForKey:@"frescoUserId"];
    });
    
    return loggedInUserId;
}

- (NSString *)displayName
{
    if ([[self first] length] && [[self last] length]) {
        return [NSString stringWithFormat:@"%@ %@", [self first], [self last]];
    }
    // this shouldn't happen
    else {
        return @"No display name";
    }
}

@end
