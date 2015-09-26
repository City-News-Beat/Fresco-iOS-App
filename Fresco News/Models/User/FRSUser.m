//
//  FRSUser.m
//  Fresco
//
//  Created by Moshe Berman on 2/2/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import "FRSUser.h"
#import "MTLModel+Additions.h"
@import Parse;

@implementation FRSUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"first" : @"firstname",
             @"last" : @"lastname",
             @"email" : @"email",
             @"notificationRadius" : @"settings.radius",
             @"userID" : @"_id",
             @"avatar" : @"avatar",
             @"payable" : @"payment_status.card"
             };
}

- (NSString *)displayName
{
    if (self.first.length && self.last.length) {
        return [NSString stringWithFormat:@"%@ %@", self.first, self.last];
    }
    else {
        // this shouldn't happen
        return @"No display name";
    }
}

- (NSString *)asJSONString
{
    NSString *jsonString;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[MTLJSONAdapter JSONDictionaryFromModel:self]
                                                       options:0
                                                         error:&error];
    if (jsonData)
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    return jsonString;
}

- (NSURL *)avatarUrl
{
    if (self.avatar != nil) {
        
        return [NSURL URLWithString:self.avatar];
        
    }
    
    return nil;
}

@end
