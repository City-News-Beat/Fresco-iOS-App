//
//  FRSUserDefaults.m
//  Fresco
//
//  Created by Philip Bernstein on 3/29/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSUserDefaults.h"

@implementation FRSUserDefaults

+(instancetype)standardUserDefaults {
    static FRSUserDefaults *defaults = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        defaults = [[FRSUserDefaults alloc] init];
    });
    
    return defaults;
}


@end
