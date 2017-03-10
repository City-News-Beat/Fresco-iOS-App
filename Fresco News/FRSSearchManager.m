//
//  FRSSearchManager.m
//  Fresco
//
//  Created by Maurice Wu on 1/29/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSSearchManager.h"

static NSString *const searchEndpoint = @"search";
static NSString *const nearbyUsersEndpoint = @"user/suggestions";

@implementation FRSSearchManager

+ (instancetype)sharedInstance {
    static FRSSearchManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[FRSSearchManager alloc] init];
    });
    return instance;
}

- (void)fetchNearbyUsersWithCompletion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSAPIClient sharedClient] get:nearbyUsersEndpoint
                      withParameters:nil
                          completion:^(id responseObject, NSError *error) {
                            completion(responseObject, error);
                          }];
}

- (void)searchWithQuery:(NSString *)query completion:(FRSAPIDefaultCompletionBlock)completion {
    if (!query) {
        // error out

        return;
    }

    NSDictionary *params = @{ @"q" : query,
                              @"stories" : @(TRUE),
                              @"galleries" : @(TRUE),
                              @"users" : @(TRUE),
                              @"limit" : @100 };

    [[FRSAPIClient sharedClient] get:searchEndpoint
                      withParameters:params
                          completion:^(id responseObject, NSError *error) {
                            completion(responseObject, error);
                          }];
}

@end
