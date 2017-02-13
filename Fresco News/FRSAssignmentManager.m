//
//  FRSAssignmentManager.m
//  Fresco
//
//  Created by Maurice Wu on 1/29/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSAssignmentManager.h"

static NSString *const assignmentsEndpoint = @"assignment/find";
static NSString *const acceptAssignmentEndpoint = @"assignment/%@/accept";
static NSString *const unacceptAssignmentEndpoint = @"assignment/%@/unaccept";
static NSString *const acceptedAssignmentEndpoint = @"assignment/accepted";

@implementation FRSAssignmentManager

+ (instancetype)sharedInstance {
    static FRSAssignmentManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[FRSAssignmentManager alloc] init];
    });
    return instance;
}

/*
 Fetch assignments w/in radius of user location, calls generic method w/ parameters & endpoint
 */

- (void)getAssignmentsWithinRadius:(float)radius ofLocation:(NSArray *)location withCompletion:(FRSAPIDefaultCompletionBlock)completion {

    NSMutableDictionary *geoData = [[NSMutableDictionary alloc] init];
    [geoData setObject:@"Point" forKey:@"type"];
    [geoData setObject:location forKey:@"coordinates"];

    NSDictionary *params = @{

        @"geo" : geoData,
        @"radius" : @(radius),
    };

    [[FRSAPIClient sharedClient] get:assignmentsEndpoint
                      withParameters:params
                          completion:^(id responseObject, NSError *error) {
                            completion(responseObject, error);
                          }];
}

- (void)getAssignmentWithUID:(NSString *)assignment completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:@"assignment/%@", assignment];

    [[FRSAPIClient sharedClient] get:endpoint
                      withParameters:nil
                          completion:^(id responseObject, NSError *error) {
                            if (error) {
                                completion(responseObject, error);
                                return;
                            }

                            if ([responseObject objectForKey:@"id"] != Nil && ![[responseObject objectForKey:@"id"] isEqual:[NSNull null]]) {
                                completion(responseObject, error);
                            } else {
                                completion(nil, error);
                            }
                          }];
}

- (void)acceptAssignment:(NSString *)assignmentID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:acceptAssignmentEndpoint, assignmentID];

    [[FRSAPIClient sharedClient] post:endpoint
                       withParameters:nil
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                           }];
}

- (void)unacceptAssignment:(NSString *)assignmentID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:unacceptAssignmentEndpoint, assignmentID];

    [[FRSAPIClient sharedClient] post:endpoint
                       withParameters:nil
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                           }];
}

- (void)getAcceptedAssignmentWithCompletion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSAPIClient sharedClient] get:acceptedAssignmentEndpoint
                      withParameters:nil
                          completion:^(id responseObject, NSError *error) {
                            completion(responseObject, error);
                          }];
}

@end
