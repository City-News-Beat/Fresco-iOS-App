//
//  NSNull+Fresco.m
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 5/15/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "NSNull+Fresco.h"

#define kNullHandlingTrackingKey @"NullHandled"
#define kNullHandlingMethodKey @"methodName"
#define kNullHandlingHandledReturnValueKey @"handledReturnValue"

@implementation NSNull (Fresco)

- (NSUInteger)length {
    [FRSTracker track:kNullHandlingTrackingKey
           parameters:@{kNullHandlingMethodKey : @"length",
                        kNullHandlingHandledReturnValueKey : @"0"
                        }];
    return 0;
}

- (NSInteger)integerValue {
    [FRSTracker track:kNullHandlingTrackingKey
           parameters:@{kNullHandlingMethodKey : @"integerValue",
                        kNullHandlingHandledReturnValueKey : @"0"
                        }];
    return 0;
}

- (float)floatValue {
    [FRSTracker track:kNullHandlingTrackingKey
           parameters:@{kNullHandlingMethodKey : @"floatValue",
                        kNullHandlingHandledReturnValueKey : @"0.0"
                        }];
    return 0.0;
}

- (NSString *)description {
    [FRSTracker track:kNullHandlingTrackingKey
           parameters:@{kNullHandlingMethodKey : @"description",
                        kNullHandlingHandledReturnValueKey : @"0(NSNull)"
                        }];
    return @"0(NSNull)";
}

- (NSArray *)componentsSeparatedByString:(NSString *)separator {
    [FRSTracker track:kNullHandlingTrackingKey
           parameters:@{kNullHandlingMethodKey : @"componentsSeparatedByString",
                        kNullHandlingHandledReturnValueKey : @"Empty Array",
                        @"separator" : [NSString getValidString:separator orAlternativeString:@"separator is nil"]
                        }];
    return @[];
}

- (id)objectForKey:(id)key {
    [FRSTracker track:kNullHandlingTrackingKey
           parameters:@{kNullHandlingMethodKey : @"objectForKey",
                        kNullHandlingHandledReturnValueKey : @"nil value",
                        @"key" : [NSString getValidString:key orAlternativeString:@"key is nil"]
                        }];
    return nil;
}

- (id)valueForKey:(id)key {
    [FRSTracker track:kNullHandlingTrackingKey
           parameters:@{kNullHandlingMethodKey : @"valueForKey",
                        kNullHandlingHandledReturnValueKey : @"nil value",
                        @"key" : [NSString getValidString:key orAlternativeString:@"key is nil"]
                        }];
    return nil;
}

- (BOOL)boolValue {
    [FRSTracker track:kNullHandlingTrackingKey
           parameters:@{kNullHandlingMethodKey : @"boolValue",
                        kNullHandlingHandledReturnValueKey : @"NO"
                        }];
    return NO;
}

- (BOOL)isEqualToString:(NSString *)aString {
    [FRSTracker track:kNullHandlingTrackingKey
           parameters:@{kNullHandlingMethodKey : @"isEqualToString",
                        kNullHandlingHandledReturnValueKey : @"NO",
                        @"anotherString" : [NSString getValidString:aString orAlternativeString:@"anotherString is nil"]
                        }];
    return NO;
}

- (NSComparisonResult)caseInsensitiveCompare:(NSString *)string {
    [FRSTracker track:kNullHandlingTrackingKey
           parameters:@{kNullHandlingMethodKey : @"caseInsensitiveCompare",
                        kNullHandlingHandledReturnValueKey : @"NSNotFound",
                        @"string" : [NSString getValidString:string orAlternativeString:@"string is nil"]
                        }];
    return NSNotFound;
}

@end
