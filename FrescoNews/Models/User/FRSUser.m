//
//  FRSUser.m
//  Fresco
//
//  Created by Moshe Berman on 2/2/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import "FRSUser.h"

@implementation FRSUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"userID" : @"user_id",
             @"firstName" : @"firstname",
             @"surname" : @"surname",
             @"username" : @"username",
             @"token" : @"access_token"
             };
}

- (NSString *)username
{
    return [_username length] ? _username : NSLocalizedString(@"Anonymous User", nil);
}

- (NSString *)displayName
{
    if ([[self firstName] length] && [[self surname] length]) {
        return [NSString stringWithFormat:@"%@ %@", [self firstName], [self surname]];
    }
    else {
        return [self username];
    }
}

@end
