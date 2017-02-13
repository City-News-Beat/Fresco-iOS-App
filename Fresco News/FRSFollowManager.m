
//
//  FRSFollowManager.m
//  Fresco
//
//  Created by Maurice Wu on 1/29/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFollowManager.h"
#import "FRSAuthManager.h"

static NSString *const followUserEndpoint = @"user/%@/follow";
static NSString *const unfollowUserEndpoint = @"user/%@/unfollow";
static NSString *const followersEndpoint = @"user/%@/followers";
static NSString *const followingEndpoint = @"user/%@/following";

@implementation FRSFollowManager

+ (instancetype)sharedInstance {
    static FRSFollowManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[FRSFollowManager alloc] init];
    });
    return instance;
}

- (void)followUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    if ([[FRSAuthManager sharedInstance] checkAuthAndPresentOnboard]) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresco.news" code:101 userInfo:Nil]);
        return;
    }

    if ([user valueForKey:@"following"] && [[user valueForKey:@"following"] boolValue] == TRUE) {
        [self unfollowUser:user
                completion:^(id responseObject, NSError *error) {
                  completion(responseObject, error);
                }];
        return;
    }

    [self followUserID:user.uid
            completion:^(id responseObject, NSError *error) {
              [user setValue:@(TRUE) forKey:@"following"];
              [[self managedObjectContext] save:Nil];
              completion(responseObject, error);
            }];
}

- (void)unfollowUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    if ([[FRSAuthManager sharedInstance] checkAuthAndPresentOnboard]) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresconews.news" code:101 userInfo:Nil]);
        return;
    }

    [self unfollowUserID:user.uid
              completion:^(id responseObject, NSError *error) {
                [user setValue:@(FALSE) forKey:@"following"];
                [[self managedObjectContext] save:Nil];
                completion(responseObject, error);
              }];
}

- (void)getFollowingForUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:followingEndpoint, user.uid];

    [[FRSAPIClient sharedClient] get:endpoint
                      withParameters:Nil
                          completion:^(id responseObject, NSError *error) {
                            completion(responseObject, error);
                          }];
}

- (void)getFollowersForUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:followersEndpoint, user.uid];

    [[FRSAPIClient sharedClient] get:endpoint
                      withParameters:Nil
                          completion:^(id responseObject, NSError *error) {
                            completion(responseObject, error);

                          }];
}

- (void)getFollowersForUser:(FRSUser *)user last:(FRSUser *)lastUser completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:followersEndpoint, user.uid];
    endpoint = [NSString stringWithFormat:@"%@?last=%@", endpoint, lastUser.uid];

    [[FRSAPIClient sharedClient] get:endpoint
                      withParameters:Nil
                          completion:^(id responseObject, NSError *error) {
                            completion(responseObject, error);
                          }];
}

- (void)getFollowingForUser:(FRSUser *)user last:(FRSUser *)lastUser completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:followingEndpoint, user.uid];
    endpoint = [NSString stringWithFormat:@"%@?last=%@", endpoint, lastUser.uid];

    [[FRSAPIClient sharedClient] get:endpoint
                      withParameters:Nil
                          completion:^(id responseObject, NSError *error) {
                            completion(responseObject, error);
                          }];
}

- (void)followUserID:(NSString *)userID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:followUserEndpoint, userID];
    [[FRSAPIClient sharedClient] post:endpoint
                       withParameters:Nil
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                           }];
}

- (void)unfollowUserID:(NSString *)userID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:unfollowUserEndpoint, userID];
    [[FRSAPIClient sharedClient] post:endpoint
                       withParameters:Nil
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                           }];
}

@end

