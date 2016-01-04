//
//  FRSDataValidator.h
//  Fresco
//
//  Created by Daniel Sun on 12/21/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRSDataValidator : NSObject

+(BOOL)isNonNullObject:(id)object;

+(BOOL)isValidEmail:(NSString *)email;

+(BOOL)isValidUserName:(NSString *)userName;

+(BOOL)isValidPassword:(NSString *)password;

@end
