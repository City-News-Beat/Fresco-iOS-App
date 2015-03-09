//
//  FRSPost.m
//  Fresco
//
//  Created by Moshe Berman on 2/2/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import "FRSPost.h"
#import "FRSUser.h"
#import "FRSTradionalSource.h"
#import "NSDate+RelativeDate.h"

@interface FRSPost ()

+ (NSDateFormatter *)sharedFormatter;

@end

@implementation FRSPost

+ (NSDateFormatter *)sharedFormatter
{
    static NSDateFormatter *sharedFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFormatter = [[NSDateFormatter alloc] init];
        [sharedFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [sharedFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

    });
    
    return sharedFormatter;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"postID": @"post_id",
             @"caption" : @"caption",
             @"imageURL" : @"small_path",
             @"largeImageURL" : @"large_path",
             @"user" : @"user",
             @"date" : @"timestamp",
             @"sources" : @"sources",
             @"tags" : @"tags",
             @"byline" : @"byline"
             };
}

+ (NSValueTransformer *)tagsJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[FRSTag class]];
}

+ (NSValueTransformer *)sourcesJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[FRSTradionalSource class]];
}

+ (NSValueTransformer *)imageURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)largeImageURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)userJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[FRSUser class]];
}

+ (NSValueTransformer *)dateJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSDate *(NSString *dateString) {

       return[[self sharedFormatter] dateFromString:dateString];

    } reverseBlock:^NSString *(NSDate *date) {
        return [[self sharedFormatter] stringFromDate:date];
    }];
}

- (NSString *)caption
{
    return [_caption length] ? _caption : NSLocalizedString(@"No Caption", nil);
}

- (NSString *)relativeDateString
{
    double ti = [[NSDate date] timeIntervalSince1970] - [self.date timeIntervalSince1970];

    if(ti < 60){
        return @"less than a minute ago";
    }
    else if(ti < 3600){
        int diff = round(ti / 60);
        if(diff == 1)
            return[NSString stringWithFormat:@"%d minute ago", diff];
        else
            return[NSString stringWithFormat:@"%d minutes ago", diff];

    }
    else if(ti<86400){
        int diff = round(ti / 60 / 60);
        if(diff == 1)
            return[NSString stringWithFormat:@"%d hour ago", diff];
        else
            return[NSString stringWithFormat:@"%d hours ago", diff];
    }
    else if(ti < 172800){
        
        int diff = round(ti / 60 / 60 / 24);
        
        if(diff == 1)
            return[NSString stringWithFormat:@"%d day ago", diff];
        else
            return[NSString stringWithFormat:@"%d days ago", diff];
            
    }
    else if(ti >= 172800){
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateStyle:NSDateFormatterLongStyle];
        
        return [format stringFromDate:self.date];
    }
    else
        return @"Never";
    
    return 0;
}

- (NSURL *)largeImageURL
{
    return [NSURL URLWithString:[@"http://res.cloudinary.com/dnd5ngsax/image/fetch/w_375,h_375/" stringByAppendingString:[_largeImageURL absoluteString]]];
}

@end
