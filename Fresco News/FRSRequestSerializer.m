//
//  FRSRequestSerializer.m
//  Fresco
//
//  Created by Philip Bernstein on 5/27/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSRequestSerializer.h"
#import "EndpointManager.h"

@implementation FRSRequestSerializer

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters error:(NSError *__autoreleasing *)error {
    NSString *endpoint = [URLString stringByReplacingOccurrencesOfString:[EndpointManager sharedInstance].currentEndpoint.baseUrl withString:@""];

    NSMutableURLRequest *request = [super requestWithMethod:method URLString:URLString parameters:parameters error:Nil];

    if ([endpoint containsString:@"gallery/submit"]) {
        [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:Nil]];
    } else if ([endpoint containsString:@"user/avatar"]) {
        [request setValue:@"multipart/form-data" forHTTPHeaderField:@"content-type"];
    }

    return request;
}
@end
