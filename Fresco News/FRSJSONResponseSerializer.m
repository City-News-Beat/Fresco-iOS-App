//
//  FRSJSONResponseSerializer.m
//  Fresco
//
//  Created by Philip Bernstein on 4/27/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSJSONResponseSerializer.h"

@implementation FRSJSONResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error {
    // Let the superclass do its work.
    // Run the custom code only if there is an error.
    id responseToReturn = [super responseObjectForResponse:response
                                                      data:data
                                                     error:error];
    if (!*error) { return responseToReturn; }
    
    NSError *parsingError;
    NSDictionary *JSONResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:&parsingError];
    
    if (parsingError) { return responseToReturn; }
    
    // Populate the error's userInfo using the parsed JSON
    NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];
    NSString *errorDescription = JSONResponse[@"error"];
    userInfo[NSLocalizedDescriptionKey] = errorDescription;
    
    NSError *annotatedError = [NSError errorWithDomain:(*error).domain
                                                  code:(*error).code
                                              userInfo:userInfo];
    (*error) = annotatedError;
    
    return responseToReturn;
}

@end
