//
//  NSString+Fresco.m
//  Fresco
//
//  Created by Maurice Wu on 1/3/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "NSString+Fresco.h"

@implementation NSString (Fresco)

+ (NSString *)randomString {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:15];

    for (int i = 0; i < 15; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random_uniform([letters length])]];
    }

    return randomString;
}

+ (NSString *)random64CharacterString {
    NSString *letters = @"abcdefABCDEF0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:64];

    for (int i = 0; i < 64; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random_uniform([letters length])]];
    }

    return randomString;
}

+ (NSDate *)dateFromString:(NSString *)string {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    dateFormatter.timeZone = timeZone;
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

    return [dateFormatter dateFromString:string];
}

/**
 Convenience method to format an NSAttributedString with the proper paragraph style.
 
 @param text NSString Entire string to be returned.
 @param boldText NSString The string you want to be bold.
 @return NSAttributedString formatted and bolded where specified.
 */
+ (NSAttributedString *)formattedAttributedStringFromString:(NSString *)text boldText:(NSString *)boldText {
    
    NSRange boldRange = [text rangeOfString:boldText];
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineSpacing = 1.2;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attribs = @{
                              NSForegroundColorAttributeName : [[UIColor blackColor] colorWithAlphaComponent:0.54],
                              NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightRegular],
                              NSParagraphStyleAttributeName : paragraphStyle
                              };
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:attribs];
    UIFont *font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    NSDictionary *dictBoldText = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    [attributedText setAttributes:dictBoldText range:boldRange];
    
    return attributedText;
}

@end
