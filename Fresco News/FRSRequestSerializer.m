//
//  FRSRequestSerializer.m
//  Fresco
//
//  Created by Philip Bernstein on 5/27/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSRequestSerializer.h"

@implementation FRSRequestSerializer

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters error:(NSError *__autoreleasing *)error {
    NSString *endpoint = [URLString stringByReplacingOccurrencesOfString:baseURL withString:@""];
    
    NSMutableURLRequest *request = [super requestWithMethod:method URLString:URLString parameters:parameters error:Nil];
    
    if (![endpoint containsString:@"auth"]) {
        NSString *authorization = [request valueForHTTPHeaderField:@"Authorization"];
        
        if ([endpoint containsString:@"highlights"] || [endpoint containsString:@"story/recent"]) {
            if (![authorization containsString:@"Bearer"]) {
                [request setValue:@"" forHTTPHeaderField:@"Authorization"];
            }
        }
    }
    
    return request;
}
@end
