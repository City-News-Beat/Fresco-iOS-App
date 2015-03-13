//
//  MTLModel+Additions.h
//  Fresco
//
//  Created by Jason Gresh on 3/11/15.
//  Copyright (c) 2015 TapMedia LLC. All rights reserved.
//

@import Foundation;

#import <Mantle/Mantle.h>

@interface MTLModel (Additions)
+ (NSDateFormatter *)sharedFormatter;

// transformers to be used directly or by reference
// in same-typed fields
+ (NSValueTransformer *)tagsJSONTransformer;
+ (NSValueTransformer *)postsJSONTransformer;
+ (NSValueTransformer *)sourcesJSONTransformer;
+ (NSValueTransformer *)imageJSONTransformer;
+ (NSValueTransformer *)URLJSONTransformer;
+ (NSValueTransformer *)userJSONTransformer;
+ (NSValueTransformer *)dateJSONTransformer;

+ (NSString *)relativeDateStringFromDate:(NSDate *)date;
@end
