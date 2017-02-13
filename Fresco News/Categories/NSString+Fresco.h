//
//  NSString+Fresco.h
//  Fresco
//
//  Created by Maurice Wu on 1/3/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Fresco)

+ (NSString *)randomString;
+ (NSString *)random64CharacterString;
+ (NSDate *)dateFromString:(NSString *)string;

@end
