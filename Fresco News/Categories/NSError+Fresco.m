//
//  NSError+NSError_Fresco.m
//  Fresco
//
//  Created by Elmir Kouliev on 2/12/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "NSError+Fresco.h"

@implementation NSError (Fresco)

+ (NSError *)errorWithMessage:(NSString*)message andCode:(NSInteger)code {
    NSError *errorToReturn = [NSError
                              errorWithDomain:errorDomain
                              code:code
                              userInfo:@{ NSLocalizedDescriptionKey : message }];
    
    return errorToReturn;
}

+ (NSError *)errorWithMessage:(NSString*)message {
    return [NSError errorWithMessage:message andCode:500];
}

+ (NSError *)unAuthenticatedError {
    return [self errorWithMessage:@"Sorry, but there is no one logged in!" andCode:401];
}

@end
