//
//  FRSSessionManager.m
//  Fresco
//
//  Created by User on 1/25/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSSessionManager.h"
#import "FRSAPIClient.h"
#import "EndpointManager.h"

static NSString *const kClientToken = @"kClientToken";
static NSString *const kRefreshClientToken = @"kRefreshClientToken";
static NSString *const tokenEndpoint = @"auth/token";

@interface FRSSessionManager ()

@property (nonatomic) BOOL generatingClientToken;

@end

@implementation FRSSessionManager

+ (instancetype)sharedInstance {
    static FRSSessionManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[FRSSessionManager alloc] init];
    });
    return instance;
}

#pragma mark - API Calls

- (void)generateClientCredentials {
    if (!self.generatingClientToken) {
        self.generatingClientToken = YES;
        NSDictionary *params = @{ @"grant_type" : @"client_credentials",
                                  @"scope" : @"write" };

        [[FRSAPIClient sharedClient] post:tokenEndpoint
                           withParameters:params
                               completion:^(id responseObject, NSError *error) {
                                 self.generatingClientToken = NO;
                                 if (!error) {
                                     NSDictionary *accessTokenDict = responseObject[@"access_token"];
                                     if (accessTokenDict) {
                                         [self saveCientToken:accessTokenDict[@"token"]];
                                         [self saveRefreshCientToken:accessTokenDict[@"refresh_token"]];
                                     }
                                 }
                               }];
    }
}

- (void)refreshToken:(BOOL)isUserToken completion:(FRSAPIDefaultCompletionBlock)completion {
    NSDictionary *params = @{ @"grant_type" : @"refresh_token",
                              @"scope" : @"write" };

    [[FRSAPIClient sharedClient] post:tokenEndpoint
                       withParameters:params
                           completion:^(id responseObject, NSError *error) {
                             if (!error) {
                                 NSDictionary *accessTokenDict = responseObject[@"access_token"];
                                 if (accessTokenDict) {
                                     if (isUserToken) {
                                         [self saveCientToken:accessTokenDict[@"token"]];
                                         [self saveRefreshCientToken:accessTokenDict[@"refresh_token"]];
                                     } else {
                                         [self saveUserToken:accessTokenDict[@"token"]];
                                         [self saveRefreshToken:accessTokenDict[@"refresh_token"]];
                                     }
                                 }
                                 completion(responseObject, nil);
                             } else {
                                 completion(nil, error);
                             }
                           }];
}

- (void)deleteTokens {
    [[FRSAPIClient sharedClient] delete:tokenEndpoint
                         withParameters:nil
                             completion:^(id responseObject, NSError *error){
                             }];

    NSArray *allAccounts = [SAMKeychain allAccounts];

    for (NSDictionary *account in allAccounts) {
        NSString *accountName = account[kSAMKeychainAccountKey];
        [SAMKeychain deletePasswordForService:serviceName account:accountName];
    }

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kClientToken];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kRefreshClientToken];
}

#pragma mark - Client Token

- (NSString *)clientToken {
    NSString *clientToken = [[NSUserDefaults standardUserDefaults] stringForKey:kClientToken];
    return clientToken;
}

- (void)saveCientToken:(NSString *)clientToken {
    [[NSUserDefaults standardUserDefaults] setObject:clientToken forKey:kClientToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)refreshClientToken {
    NSString *refreshClientToken = [[NSUserDefaults standardUserDefaults] stringForKey:kRefreshClientToken];
    return refreshClientToken;
}

- (void)saveRefreshCientToken:(NSString *)refreshClientToken {
    [[NSUserDefaults standardUserDefaults] setObject:refreshClientToken forKey:kRefreshClientToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - User/Auth Token

- (NSString *)authenticationToken {
    NSArray *allAccounts = [SAMKeychain accountsForService:serviceName];

    if ([allAccounts count] == 0) {
        return Nil;
    }

    NSDictionary *credentialsDictionary = [allAccounts firstObject];
    NSString *accountName = credentialsDictionary[kSAMKeychainAccountKey];

    return [SAMKeychain passwordForService:serviceName account:accountName];
}

- (void)saveUserToken:(NSString *)token {
    [SAMKeychain setPasswordData:[token dataUsingEncoding:NSUTF8StringEncoding] forService:serviceName account:[EndpointManager sharedInstance].currentEndpoint.frescoClientId];
}

- (NSString *)refreshUserToken {
    return [SAMKeychain passwordForService:serviceName account:[NSString stringWithFormat:@"%@Refresh", [EndpointManager sharedInstance].currentEndpoint.frescoClientId]];
}

- (void)saveRefreshToken:(NSString *)token {
    [SAMKeychain setPasswordData:[token dataUsingEncoding:NSUTF8StringEncoding] forService:serviceName account:[NSString stringWithFormat:@"%@Refresh", [EndpointManager sharedInstance].currentEndpoint.frescoClientId]];
}

@end
