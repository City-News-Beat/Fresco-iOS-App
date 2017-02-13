//
//  FRSFeedManager.m
//  Fresco
//
//  Created by Maurice Wu on 1/29/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSFeedManager.h"
#import "FRSUserManager.h"

static NSString *const likeFeed = @"feeds/%@/likes";
static NSString *const followingFeed = @"feeds/%@/following";
static NSString *const userFeed = @"feeds/%@/user";

@implementation FRSFeedManager

+ (instancetype)sharedInstance {
    static FRSFeedManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[FRSFeedManager alloc] init];
    });
    return instance;
}

- (void)fetchFollowing:(void (^)(NSArray *galleries, NSError *error))completion {
    FRSUser *authenticatedUser = [[FRSUserManager sharedInstance] authenticatedUser];
    if (!authenticatedUser) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresconews.fresco" code:404 userInfo:@{ @"error" : @"no user u dingus" }]);
    }
    
    NSString *endpoint = [NSString stringWithFormat:followingFeed, authenticatedUser.uid];

    [[FRSAPIClient sharedClient] get:endpoint
                      withParameters:Nil
                          completion:^(id responseObject, NSError *error) {
                            completion(responseObject, error);
                          }];
}

- (void)fetchFollowing:(NSString *)timeStamp completion:(void (^)(NSArray *galleries, NSError *error))completion {
    FRSUser *authenticatedUser = [[FRSUserManager sharedInstance] authenticatedUser];
    if (!authenticatedUser) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresconews.fresco" code:404 userInfo:@{ @"error" : @"no user u dingus" }]);
    }
    
    NSString *endpoint = [NSString stringWithFormat:followingFeed, authenticatedUser.uid];
    endpoint = [NSString stringWithFormat:@"%@?last=%@", endpoint, timeStamp];
    
    [[FRSAPIClient sharedClient] get:endpoint
                      withParameters:Nil
                          completion:^(id responseObject, NSError *error) {
                              completion(responseObject, error);
                          }];
}

- (void)fetchLikesFeedForUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:likeFeed, user.uid];
    [[FRSAPIClient sharedClient] get:endpoint
                      withParameters:Nil
                          completion:^(id responseObject, NSError *error) {
                            completion(responseObject, error);
                          }];
}

- (void)fetchLikesFeedForUser:(FRSUser *)user last:(NSString *)timeStamp completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:likeFeed, user.uid];
    endpoint = [NSString stringWithFormat:@"%@?last=%@", endpoint, timeStamp];
    
    [[FRSAPIClient sharedClient] get:endpoint
                      withParameters:Nil
                          completion:^(id responseObject, NSError *error) {
                              completion(responseObject, error);
                          }];
}

- (void)fetchGalleriesForUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:userFeed, user.uid];

    [[FRSAPIClient sharedClient] get:endpoint
                      withParameters:Nil
                          completion:^(id responseObject, NSError *error) {
                            completion(responseObject, error);
                          }];
}

- (void)fetchGalleriesForUser:(FRSUser *)user last:(NSString *)timeStamp completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:userFeed, user.uid];
    endpoint = [NSString stringWithFormat:@"%@?last=%@", endpoint, timeStamp];
    
    [[FRSAPIClient sharedClient] get:endpoint
                      withParameters:Nil
                          completion:^(id responseObject, NSError *error) {
                              completion(responseObject, error);
                          }];
}

@end
