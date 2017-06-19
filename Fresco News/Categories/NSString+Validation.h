//
//  NSString+Validation.h
//  Fresco
//
//  Created by Fresco News on 8/5/15.
//  Copyright (c) 2015 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Validation)

- (BOOL)isValidEmail;
- (BOOL)isValidPassword;
- (BOOL)isValidUsername;
- (BOOL)stringContainsEmoji;
+ (NSString *)formatCreditCard:(NSString *)input;
+ (NSString *)formatCreditCardExpiry:(NSString *)input;

//returns YES aString if its valid, returns NO if aString is invalid
//valid means aString not nil, aString not NSNull object, and aString belongs to NSString class. If it satisfies all these three constraints, then aString is valid.
+ (BOOL)isStringValid:(NSString *)aString;

//returns same aString if its valid, returns empty string if aString is invalid
//valid means aString not nil, aString not NSNull object, and aString belongs to NSString class. If it satisfies all these three constraints, then aString is valid.
+ (NSString *)getValidStringOrEmptyStringFrom:(NSString *)aString;

//returns same aString if its valid, returns altString if aString is invalid, returns empty string if altString is also invalid
//valid means aString not nil, aString not NSNull object, and aString belongs to NSString class. If it satisfies all these three constraints, then aString is valid.
+ (NSString *)getValidString:(NSString *)aString orAlternativeString:(NSString *)altString;

@end
