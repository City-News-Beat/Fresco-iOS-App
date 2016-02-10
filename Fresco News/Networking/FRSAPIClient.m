//
//  FRSAPIClient.m
//  Fresco
//
//  Created by Daniel Sun on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSAPIClient.h"
#import <AFNetworking/AFNetworking.h>

@implementation FRSAPIClient

-(void)getAssignmentsWithinRadius:(float)radius ofLocation:(NSArray *)location withCompletion:(FRSAPIDefaultCompletionBlock)completion{
    AFHTTPRequestOperationManager *manager = [self managerWithFrescoConfigurations];
    NSDictionary *params = @{
                             @"lat" :location[0],
                             @"lon" : location[1],
                             @"radius" : @(radius),
                             @"active" : @"true"
                             };
    
    [manager GET:@"assignment/find" parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if (responseObject[@"data"]){
            
            if (!completion) return;
            completion(responseObject[@"data"], nil);
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        if (!completion) return;
        completion(nil, error);
    }];
}

 
///gallery/search?q=test&offset=0&limit=18&verified=true&tags=`
//
//[1:02]
//`/story/search?q=test&offset=0&limit=10`
//
//[1:02]
//`/user/search?q=test&offset=0&limit=10`
//
//
//


-(AFHTTPRequestOperationManager *)managerWithFrescoConfigurations{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_API]];
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"kFrescoAuthToken"] forHTTPHeaderField:@"authToken"];
    return manager;
}

@end
