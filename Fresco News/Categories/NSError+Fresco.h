//
//  NSError+NSError_Fresco.h
//  Fresco
//
//  Created by Elmir Kouliev on 2/12/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 Category for off-hand errors that are formatted for us
 */
@interface NSError (Fresco)


/**
 Returns a clean, generic error with descriptions and codes.
 Methods below this are just stripped down versions that lead to this one

 @param message message to return
 @param code code to use
 @return returns an NSError
 */
+ (NSError *)errorWithMessage:(NSString*)message andCode:(NSInteger)code;

+ (NSError *)errorWithMessage:(NSString*)message;

+ (NSError *)unAuthenticatedError;


@end
