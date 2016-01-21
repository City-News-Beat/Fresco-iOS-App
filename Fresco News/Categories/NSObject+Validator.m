//
//  NSObject+Validator.m
//  Fresco
//
//  Created by Daniel Sun on 1/21/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "NSObject+Validator.h"

@implementation NSObject (Validator)

-(BOOL)isNull{
    return [self isEqual:[NSNull null]];
}

-(BOOL)isValidDictionaryForKeys:(NSArray *)keys{
    if (![self isKindOfClass:[NSDictionary class]]) return NO;
    
    NSDictionary *dict = (NSDictionary *)self;
    for (NSString *key in keys){
        if ([dict[key] isNull]){
            return NO;
        }
    }
    return YES;
}

@end
