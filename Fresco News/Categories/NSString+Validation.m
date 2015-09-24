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


+ (NSString *)formatCreditCard:(NSString *)input
{
    input = [[self class] trimSpecialCharacters:input];
    NSString *output;
    switch (input.length) {
        case 1:
        case 2:
        case 3:
        case 4:
            output = [NSString stringWithFormat:@"%@", [input substringToIndex:input.length]];
            break;
        case 5:
        case 6:
        case 7:
        case 8:
            output = [NSString stringWithFormat:@"%@ %@", [input substringToIndex:4], [input substringFromIndex:4]];
            break;
        case 9:
        case 10:
        case 11:
        case 12:
            output = [NSString stringWithFormat:@"%@ %@ %@", [input substringToIndex:4], [input substringWithRange:NSMakeRange(4, 4)], [input substringFromIndex:8]];
            break;
        case 13:
        case 14:
        case 15:
        case 16:
            output = [NSString stringWithFormat:@"%@ %@ %@ %@", [input substringToIndex:4], [input substringWithRange:NSMakeRange(4, 4)], [input substringWithRange:NSMakeRange(8, 4)], [input substringFromIndex:12]];
            break;
        default:
            output = @"";
            break;
    }
    return output;
}

+ (NSString *)formatCreditCardExpiry:(NSString *)input{
    
    input = [[self class] trimSpecialCharacters:input];
    NSString *output;
    switch (input.length) {
        case 1:
        case 2:
            output = [NSString stringWithFormat:@"%@", [input substringToIndex:input.length]];
            break;
        case 3:
        case 4:
            output = [NSString stringWithFormat:@"%@/%@", [input substringToIndex:2], [input substringFromIndex:2]];
            break;
        default:
            output = @"";
            break;
    }
    
    return output;
    
}

+ (NSString *)trimSpecialCharacters:(NSString *)input{
    
    NSCharacterSet *special = [NSCharacterSet characterSetWithCharactersInString:@"/+-() "];
    return [[input componentsSeparatedByCharactersInSet:special] componentsJoinedByString:@""];
    
}

@end
