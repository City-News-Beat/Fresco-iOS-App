//
//  MTLModel+Additions.h
//  Fresco
//
//  Created by Fresco News on 3/11/15.
//  Copyright (c) 2015 TapMedia LLC. All rights reserved.
//

@import Foundation;

#import <Mantle/Mantle.h>

@interface MTLModel (Additions)

// transformers to be used directly or by reference
// in same-typed fields
+ (NSValueTransformer *)postsJSONTransformer;
+ (NSValueTransformer *)sourcesJSONTransformer;
+ (NSValueTransformer *)imageJSONTransformer;
+ (NSValueTransformer *)URLJSONTransformer;
+ (NSValueTransformer *)userJSONTransformer;
+ (NSValueTransformer *)dateJSONTransformer;

+ (NSString *)relativeDateStringFromDate:(NSDate *)date;
+ (NSString *)futureDateStringFromDate:(NSDate *)date;

- (NSURL *)cdnAssetURLForURLString:(NSString *)url withSize:(CGSize)size transformationString:(NSString *)transformationString;

@end
