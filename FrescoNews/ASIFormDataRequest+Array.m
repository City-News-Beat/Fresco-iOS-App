//
//  ASIFormDataRequest+Array.m
//  Fresco
//
//  Created by Team Fresco on 3/15/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import "ASIFormDataRequest+Array.h"

@implementation ASIFormDataRequest (Array)

- (void)setPostArray:(NSArray *)array forKey:(NSString *)aKey
{
    for (NSUInteger i = 0; i < [array count]; i++) {
        [self setPostValue:[array objectAtIndex:i] forKey:[NSString stringWithFormat:@"%@[%lu]", aKey, (unsigned long)i]];
    }
}

@end
