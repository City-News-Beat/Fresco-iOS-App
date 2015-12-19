//
//  UIFont+Fresco.m
//  Fresco
//
//  Created by Daniel Sun on 12/18/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "UIFont+Fresco.h"

@implementation UIFont (Fresco)

+(UIFont *)notaBoldWithSize:(NSInteger)size{
    return [UIFont fontWithName:@"Nota-Bold" size:size];
}

+(UIFont *)notaRegularWithSize:(NSInteger)size{
    return [UIFont fontWithName:@"Nota-Normal" size:size];
}

+(UIFont *)notaMediumWithSize:(NSInteger)size{
    return [UIFont fontWithName:@"Nota-Medium" size:size];
}

@end
