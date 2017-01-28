

//
//  UserManager.m
//  Fresco
//
//  Created by User on 1/3/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSUserManager.h"
#import "FRSAPIClient.h"
#import "FRSAuthManager.h"

static NSString *const userEndpoint = @"user/";
static NSString *const setAvatarEndpoint = @"user/avatar";
static NSString *const updateUserEndpoint = @"user/update";
static NSString *const authenticatedUserEndpoint = @"user/me";

@implementation FRSUserManager

+ (instancetype)sharedInstance {
    static FRSUserManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[FRSUserManager alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];

    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleLocationUpdate:)
                                                     name:FRSLocationUpdateNotification
                                                   object:nil];
    }

    return self;
}

#pragma API calls

- (void)checkUser:(NSString *)user completion:(FRSAPIBooleanCompletionBlock)completion {

    NSString *endpoint = [NSString stringWithFormat:@"user/%@", user];

    [[FRSAPIClient sharedClient] get:endpoint
                      withParameters:nil
                          completion:^(id responseObject, NSError *error) {
                            if (error) {
                                completion(TRUE, error);
                                return;
                            }

                            if ([responseObject objectForKey:@"id"] != Nil && ![[responseObject objectForKey:@"id"] isEqual:[NSNull null]]) {
                                completion(FALSE, error);
                            }

                            // shouldn't happen
                            completion(TRUE, error);
                          }];
}

- (void)getUserWithUID:(NSString *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:@"user/%@", user];

    [[FRSAPIClient sharedClient] get:endpoint
                      withParameters:nil
                          completion:^(id responseObject, NSError *error) {
                            if (error) {
                                completion(responseObject, error);
                                return;
                            }

                            if ([responseObject objectForKey:@"id"] != Nil && ![[responseObject objectForKey:@"id"] isEqual:[NSNull null]]) {
                                completion(responseObject, error);
                            }

                            // shouldn't happen
                            completion(responseObject, error);
                          }];
}

- (void)updateLocalUser {
    if (![[FRSAuthManager sharedInstance] isAuthenticated]) {
        return;
    }

    [[FRSAPIClient sharedClient] get:authenticatedUserEndpoint
                      withParameters:nil
                          completion:^(id responseObject, NSError *error) {
                            if (error) {
                                return;
                            }

                            // set up FRSUser object with this info, set authenticated to true
                            NSString *userID = responseObject[@"id"];
                            NSString *email = responseObject[@"email"];
                            NSString *name = responseObject[@"full_name"];
                            NSMutableDictionary *identityDictionary = [[NSMutableDictionary alloc] init];

                            if (userID && ![userID isEqual:[NSNull null]]) {
                                userID = userID;
                            }

                            if (name && ![name isEqual:[NSNull null]]) {
                                identityDictionary[@"name"] = name;
                            }

                            if (email && ![email isEqual:[NSNull null]]) {
                                identityDictionary[@"email"] = email;
                            }

                            [[SEGAnalytics sharedAnalytics] identify:userID
                                                              traits:identityDictionary];
                            [FRSTracker track:loginEvent];
                          }];
}

- (void)updateUserWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSAPIClient sharedClient] post:updateUserEndpoint
                       withParameters:digestion
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                           }];
}

- (FRSUser *)authenticatedUser {
    // predicate searching for users in store w/ loggedIn as TRUE/1
    NSPredicate *signedInPredicate = [NSPredicate predicateWithFormat:@"%K == %@", @"isLoggedIn", @(TRUE)];
    NSFetchRequest *signedInRequest = [NSFetchRequest fetchRequestWithEntityName:@"FRSUser"];
    signedInRequest.predicate = signedInPredicate;

    // get context from app deleegate (hate this dependency but no need to re-write rn to move up)
    NSManagedObjectContext *context = [[FRSAPIClient sharedClient] managedObjectContext]; // temp (replace with internal or above method

    // no need to sort response, because theoretically there is 1
    NSError *userFetchError;
    NSArray *authenticatedUsers = [context executeFetchRequest:signedInRequest error:&userFetchError];

    // no authenticated user, or we had trouble accessing data store
    if (userFetchError || [authenticatedUsers count] < 1) {
        return Nil;
    }

    // if we have multiple "authenticated" users in data store, we probs messed up big time
    if ([authenticatedUsers count] > 1) {
    }

    _authenticatedUser = [authenticatedUsers firstObject];

    return _authenticatedUser;
}

- (void)refreshCurrentUser:(FRSAPIDefaultCompletionBlock)completion {
    if (![[FRSAuthManager sharedInstance] isAuthenticated]) {
        completion(Nil, [NSError errorWithDomain:@"com.fresconews.fresco" code:404 userInfo:Nil]); // no authenticated user, 404
        return;
    }

    // authenticated request to user/me (essentially user/ozetadev w/ more fields)
    [[FRSAPIClient sharedClient] get:authenticatedUserEndpoint
                      withParameters:Nil
                          completion:^(id responseObject, NSError *error) {
                            completion(responseObject, error);
                          }];
}

- (void)updateIdentityWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSAPIClient sharedClient] post:@"user/identity/update"
                       withParameters:digestion
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                           }];
}

- (void)updateUserLocation:(NSDictionary *)inputParams completion:(void (^)(NSDictionary *response, NSError *error))completion {
    if (![[FRSAuthManager sharedInstance] isAuthenticated]) {
        return;
    }

    [[FRSAPIClient sharedClient] post:locationEndpoint
                       withParameters:inputParams
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                           }];
}

- (void)handleLocationUpdate:(NSNotification *)userInfo {
    dispatch_async(dispatch_get_main_queue(), ^{

      [self updateUserLocation:userInfo.userInfo
                    completion:^(NSDictionary *response, NSError *error) {
                      if (!error) {
                      } else {
                          NSLog(@"Location Error: %@ %@", response, error);
                      }
                    }];
    });
}

- (void)pingLocation:(NSDictionary *)location completion:(FRSAPIDefaultCompletionBlock)completion {
    if (![[FRSAuthManager sharedInstance] isAuthenticated]) {
        return;
    }

    [[FRSAPIClient sharedClient] post:locationEndpoint
                       withParameters:location
                           completion:^(id responseObject, NSError *error){
                           }];
}

- (void)checkEmail:(NSString *)email completion:(FRSAPIDefaultCompletionBlock)completion {
    [self check:email completion:completion];
}

- (void)checkUsername:(NSString *)username completion:(FRSAPIDefaultCompletionBlock)completion {
    [self check:username completion:completion];
}

- (void)check:(NSString *)check completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *checkEndpoint = [userEndpoint stringByAppendingString:[check stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

    [[FRSAPIClient sharedClient] get:checkEndpoint
                      withParameters:Nil
                          completion:^(id responseObject, NSError *error) {
                            completion(responseObject, error);
                          }];
}

- (void)postAvatarWithParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSAPIClient sharedClient] postAvatar:setAvatarEndpoint withParameters:parameters withData:parameters[@"avatar"] withName:@"avatar" withFileName:@"photo.jpg" completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

@end
