//
//  FRSNotification.m
//  FrescoNews
//
//  Created by Elmir Kouliev on 5/25/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "FRSNotification.h"
#import "MTLModel+Additions.h"

@implementation FRSNotification

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"notificaitonId": @"_id",
             @"title" : @"title",
             @"event" : @"event",
             @"notificationDescription" : @"description",
             @"date" : @"timestamp",
             @"type" : @"type",
             @"notificationData": @"notificationData"
             };
}

+ (NSValueTransformer *)dateJSONTransformer
{
    return [MTLModel dateJSONTransformer];
}


@end
