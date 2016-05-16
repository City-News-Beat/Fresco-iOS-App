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
    
    NSError *parsingError;
    NSDictionary *JSONResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:&parsingError];
    
    if (parsingError) { return Nil; }
    
    NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];
    NSString *errorDescription = JSONResponse[@"error"];
    userInfo[NSLocalizedDescriptionKey] = errorDescription;
    
    NSError *annotatedError = [NSError errorWithDomain:(*error).domain
                                                  code:(*error).code
                                              userInfo:userInfo];
    (*error) = annotatedError;
    
    return JSONResponse;
}

@end
