//
//  FRSDataValidator.m
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSDataValidator.h"

@implementation FRSDataValidator

+(BOOL)isNonNullObject:(id)object{
    if ([[object class] isSubclassOfClass:[NSDictionary class]]){
        return [FRSDataValidator validateDictionary:(NSDictionary *)object];
    }
    else {
        return (![object isEqual:[NSNull null]] && object);
    }
}

+(BOOL)validateDictionary:(NSDictionary *)dict{
    if (!dict || [dict isEqual:[NSNull null]]) return NO;
    
    else {
        for (NSString *key in [dict allKeys]){
            if ([dict[key] isEqual:[NSNull null]]){
                return NO;
            }
        }
    }
    
    return YES;
}

+(BOOL)isValidEmail:(NSString *)email{
    NSError *regexError;
    
    NSRegularExpression *emailCheck = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$" options:kNilOptions error:&regexError];
    
    NSArray *matches = [emailCheck matchesInString:email options:kNilOptions range:NSMakeRange(0, email.length)];
    
    return ([matches count] == 0);
}

+(BOOL)isValidPassword:(NSString *)password{
    NSArray *numbers = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0"];
    BOOL hasNumber = FALSE;
    
    for (NSString *number in numbers) {
        if ([password rangeOfString:number].location != NSNotFound) {
            hasNumber = TRUE;
            break;
        }
    }
    
    return (password.length >= 8 && hasNumber);
}

+(BOOL)isValidUserName:(NSString *)userName {

    return (userName && userName.length < maxUsernameChars);
}

@end
