//
//  MTLModel+Additions.m
//  Fresco
//
//  Created by Fresco News on 3/11/15.
//  Copyright (c) 2015 TapMedia LLC. All rights reserved.
//

#import "MTLModel+Additions.h"
#import "FRSTag.h"
#import "FRSArticle.h"
#import "FRSUser.h"
#import "FRSGallery.h"
#import "FRSPost.h"
#import "FRSImage.h"
#import "FRSAssignment.h"
#import "FRSNotification.h"

@implementation MTLModel (Additions)

// some default transformers
// if we stick to these naming conventions for fields they will be picked up

+ (NSValueTransformer *)sourcesJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[FRSArticle class]];
}

+ (NSValueTransformer *)postsJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[FRSPost class]];
}

+ (NSValueTransformer *)galleriesJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[FRSGallery class]];
}

+ (NSValueTransformer *)imageJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[FRSImage class]];
}

+ (NSValueTransformer *)URLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)userJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[FRSUser class]];
}

+ (NSValueTransformer *)dateJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSDate *(NSNumber *UNIXTimestamp) {
       return [NSDate dateWithTimeIntervalSince1970:([UNIXTimestamp floatValue] / 1000)];

    } reverseBlock:^NSNumber *(NSDate *date) {
        return [NSNumber numberWithInteger:[date timeIntervalSince1970]];
    }];
}

+ (NSValueTransformer *)bylineJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^NSString *(NSString *byline) {
        return [byline stringByReplacingOccurrencesOfString:@" via Fresco News" withString:@""];
    }];
}

+ (NSString *)relativeDateStringFromDate:(NSDate *)date
{
    
    int ti = [[NSDate date] timeIntervalSince1970] - [date timeIntervalSince1970];

    if(ti <= 0){
        return [NSString stringWithFormat:@"just now"];
    }
    else if(ti < 60){
        return [NSString stringWithFormat:@"%ds", ti];
    }
    else if(ti < 3600){
        
        int diff = round(ti / 60);
        
        return [NSString stringWithFormat:@"%dm", diff];
        
    }
    else if(ti<86400){
        
        int diff = round(ti / 60 / 60);
        
        return [NSString stringWithFormat:@"%dh", diff];
        
    }
    else if(ti < 604800){
        
        int diff = round(ti / 60 / 60 / 24);
        
        return [NSString stringWithFormat:@"%dd", diff];
        
    }
    else if(ti < 2629740){
        
        int diff = round(ti / 60 / 60 / 24 / 4);
        
        return [NSString stringWithFormat:@"%dw", diff];
        
        
    }
    else if(ti < 31556900){
        
        int diff = round(ti / 60 / 60 / 24 / 4 / 12);
        
        return [NSString stringWithFormat:@"%dmo", diff];
        
        
    }
    else{
        
        int diff = round(ti / 60 / 60 / 24 / 30 / 52);
        
        return [NSString stringWithFormat:@"%dy", diff];
        
    }
    
    return 0;
    
}

+ (NSString *)futureDateStringFromDate:(NSDate *)date
{
    
    double ti = [date timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970];
    
    if(ti < 60){
        return @"in a few seconds";
    }
    else if(ti < 3600){
        
        int diff = round(ti / 60);
        
        return diff == 1 ? [NSString stringWithFormat:@"in %d minute", diff] : [NSString stringWithFormat:@"in %d minutes", diff];
        
    }
    else if(ti<86400){
        
        int diff = round(ti / 60 / 60);
        
        return diff == 1 ?[NSString stringWithFormat:@"in %d hour", diff] : [NSString stringWithFormat:@"in %d hours", diff];
        
    }
    else if(ti < 604800){
        
        int diff = round(ti / 60 / 60 / 24);
        
        return diff == 1 ? [NSString stringWithFormat:@"in %d day", diff] : [NSString stringWithFormat:@"in %d days", diff];
        
    }
    else if(ti < 2629740){
        
        int diff = round(ti / 60 / 60 / 24 / 4);
        
        return diff == 1 ? [NSString stringWithFormat:@"in %d weeks", diff] : [NSString stringWithFormat:@"in %d weeks", diff];
        
        
    }
    else if(ti < 31556900){
        
        int diff = round(ti / 60 / 60 / 24 / 4 / 12);
        
        return diff == 1 ? [NSString stringWithFormat:@"in %d month", diff] : [NSString stringWithFormat:@"in %d months", diff];
        
        
    }
    else if(ti < 3155690000){
        
        int diff = round(ti / 60 / 60 / 24 / 30 / 52);
        
        return diff == 1 ? [NSString stringWithFormat:@"%d year ago", diff] : [NSString stringWithFormat:@"%d years ago", diff];
        
    }
    else
        return @"Never";
    
    return 0;
    
}

#pragma mark - Image CDN

// makes a URL something like http://res.cloudinary.com/dnd5ngsax/image/fetch/w_375,h_375,c_faces/
- (NSURL *)cdnAssetURLForURLString:(NSString *)url withSize:(CGSize)size transformationString:(NSString *)transformationString
{
    NSString *sizeString;
    if (size.width > 0) {
        sizeString = [NSString stringWithFormat:@"w_%d", (int)size.width];
        if (size.height)
            sizeString = [sizeString stringByAppendingString:@","];
    }
    if (size.height > 0) {
        sizeString = [NSString stringWithFormat:@"%@h_%d", sizeString, (int)size.height];
    }
    
    if ([transformationString length])
        sizeString = [NSString stringWithFormat:@"%@,%@", sizeString, transformationString];
    
    NSString *fullURL = [NSString stringWithFormat:@"%@/%@/%@", [VariableStore sharedInstance].cdnBaseURL, sizeString, url];

    return [NSURL URLWithString:fullURL];
}
@end
