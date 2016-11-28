//
//  FRSRequestSerializer.m
//  Fresco
//
//  Created by Philip Bernstein on 5/27/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSRequestSerializer.h"
#import "Fresco.h"

@implementation FRSRequestSerializer

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters error:(NSError *__autoreleasing *)error {
    NSString *endpoint = [URLString stringByReplacingOccurrencesOfString:baseURL withString:@""];
    
    NSMutableURLRequest *request = [super requestWithMethod:method URLString:URLString parameters:parameters error:Nil];
    NSLog(@"%@", [request valueForHTTPHeaderField:@"Authorization"]);
    if (![endpoint containsString:@"auth"] && ![endpoint containsString:@"user"]) {
        NSString *authorization = [request valueForHTTPHeaderField:@"Authorization"];
        if ([authorization containsString:@"Basic"]) {
            [request setValue:Nil forHTTPHeaderField:@"Authorization"];
        }
    }
    
    if ([endpoint containsString:@"gallery/submit"]) {
        [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:Nil]];
    }
    
    if ([endpoint containsString:@"user/avatar"]) {
        [request setValue:@"multipart/form-data" forHTTPHeaderField:@"content-type"];
    }
    
    if ([endpoint containsString:@"assignment/find"]) {
        NSString *authorization = [@"Basic " stringByAppendingString:clientAuthorization];
        [request setValue:authorization forHTTPHeaderField:@"Authorization"];
    }
    
    
    return request;
}
@end
