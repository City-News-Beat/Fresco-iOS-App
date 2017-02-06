//
//  NSString+Validation.m
//  Fresco
//
//  Created by Fresco News on 8/5/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import "NSString+Validation.h"

@implementation NSString (Validation)

- (BOOL)isValidEmail {
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";

    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])];

    if (regExMatches == 0) {
        return NO;
    }
    return YES;
}

- (BOOL)isValidPassword {
    return ([self length] >= 4) ? YES : NO;
}

- (BOOL)isValidUsername {
    if ([self stringContainsEmoji]) {
        return NO;
    }
    
    if ([self isEqualToString:@"@"]) {
        return NO;
    }
    
    NSCharacterSet *allowedSet = [NSCharacterSet characterSetWithCharactersInString:validUsernameChars];
    NSCharacterSet *disallowedSet = [allowedSet invertedSet];
    return ([self rangeOfCharacterFromSet:disallowedSet].location == NSNotFound);
}

- (BOOL)stringContainsEmoji {
    __block BOOL returnValue = NO;
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock:
                              ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {

                                const unichar hs = [substring characterAtIndex:0];
                                // surrogate pair
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }

                                } else {
                                    // non surrogate
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                              }];

    return returnValue;
}

+ (NSString *)formatCreditCard:(NSString *)input {
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

+ (NSString *)formatCreditCardExpiry:(NSString *)input {

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

+ (NSString *)trimSpecialCharacters:(NSString *)input {

    NSCharacterSet *special = [NSCharacterSet characterSetWithCharactersInString:@"/+-() "];
    return [[input componentsSeparatedByCharactersInSet:special] componentsJoinedByString:@""];
}

@end
