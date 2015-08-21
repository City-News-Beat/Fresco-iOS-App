//
//  NSString+Validation.m
//  Fresco
//
//  Created by Nicolas Rizk on 8/5/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "NSString+Validation.h"

@implementation NSString (Validation)

- (BOOL)isValidEmail {
    
    NSString *emailRegex = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";

    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:self];
}


- (BOOL)isValidPassword {

    return ([self length] > 5) ? YES : NO;
}

@end
