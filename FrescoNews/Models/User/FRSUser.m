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
