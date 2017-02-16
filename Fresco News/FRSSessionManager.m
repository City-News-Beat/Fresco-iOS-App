//
//  FRSSessionManager.m
//  Fresco
//
//  Created by User on 1/25/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSSessionManager.h"
#import "FRSAuthManager.h"
#import "EndpointManager.h"

static NSString *const kClientToken = @"kClientToken";
static NSString *const kRefreshClientToken = @"kRefreshClientToken";
static NSString *const kRefreshUserToken = @"kRefreshUserToken";
static NSString *const tokenEndpoint = @"auth/token";

@interface FRSSessionManager ()

@property (nonatomic) BOOL generatingClientToken;
@property (nonatomic) BOOL isRefreshing;

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

#pragma mark - API Operations

- (void)generateClientCredentials {
    if (self.generatingClientToken) return;
    
    //If we already have a client token
    if(![[[FRSSessionManager sharedInstance] clientToken] isEqualToString:@""]) return;
    
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
                                       [self saveClientToken:accessTokenDict[@"token"]];
                                       [self saveRefreshClientToken:accessTokenDict[@"refresh_token"]];
                                   }
                               }
                           }];

}

- (void)refreshToken:(BOOL)isUserToken completion:(FRSAPIDefaultCompletionBlock)completion {
    if(self.isRefreshing) return;
    self.isRefreshing = YES;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]
                                   initWithDictionary:@{ @"grant_type" : @"refresh_token",
                                                         @"scope" : @"write"
                                                         }];
    
    if(isUserToken) {
        [params setValue:[self refreshUserToken] forKey:@"refresh_token"];
    } else {
        [params setValue:[self refreshClientToken] forKey:@"refresh_token"];
    }

    [[FRSAPIClient sharedClient] post:tokenEndpoint
                       withParameters:params
                           completion:^(id responseObject, NSError *error) {
                               self.isRefreshing = NO;
                               
                               if (!error) {
                                   NSDictionary *accessTokenDict = responseObject[@"access_token"];
                                   if (accessTokenDict) {
                                       if (isUserToken) {
                                           [self saveUserToken:accessTokenDict[@"token"]];
                                           [self saveRefreshToken:accessTokenDict[@"refresh_token"]];
                                       } else {
                                           [self saveClientToken:accessTokenDict[@"token"]];
                                           [self saveRefreshClientToken:accessTokenDict[@"refresh_token"]];                              }
                                   }
                                   completion(responseObject, nil);
                               } else {
                                   if(isUserToken) {
                                       //Log user out due to failed refresh. At this point, there's no other way for the app to authenticate the user
                                       [[FRSAuthManager sharedInstance] logout];
                                   } else {
                                       //Prevent deleting client tokens while new ones may be generating
                                       //In this case, the generation of the new ones will override the current ones
                                       if(!self.generatingClientToken) {
                                           [self deleteClientTokens];
                                       }
                                   }
                                   
                                   completion(nil, error);
                               }
                           }];
}

#pragma mark - Client Token

- (NSString *)clientToken {
    NSString *clientToken = [[NSUserDefaults standardUserDefaults] stringForKey:kClientToken];
    if(clientToken == nil) return @"";
    return clientToken;
}

- (NSString *)refreshClientToken {
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:kRefreshClientToken];
    if(token == nil) return @"";
    return token;
}

- (void)saveClientToken:(NSString *)clientToken {
    [[NSUserDefaults standardUserDefaults] setObject:clientToken forKey:kClientToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveRefreshClientToken:(NSString *)refreshClientToken {
    [[NSUserDefaults standardUserDefaults] setObject:refreshClientToken forKey:kRefreshClientToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)deleteClientTokens{
    //Delete token off the API
    [[FRSAPIClient sharedClient] delete:tokenEndpoint
                         withParameters:nil
                             completion:^(id responseObject, NSError *error) {
                                 //Remove client refresh and regular token
                                 [[NSUserDefaults standardUserDefaults] removeObjectForKey:kClientToken];
                                 [[NSUserDefaults standardUserDefaults] removeObjectForKey:kRefreshClientToken];
                                 [[NSUserDefaults standardUserDefaults] synchronize];
                             }];
}

#pragma mark - User Tokens

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

/**
 Returns the user's refresh token

 @return Refresh token as a string
 */
- (NSString *)refreshUserToken {
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:kRefreshUserToken];
    if(token == nil) return @"";
    return token;
}

- (void)saveRefreshToken:(NSString *)refreshUserToken{
    [[NSUserDefaults standardUserDefaults] setObject:refreshUserToken forKey:kRefreshUserToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)deleteUserData {
    void (^clearTokens)(void) = ^ {
        NSArray *allAccounts = [SAMKeychain allAccounts];
        
        //Delete user bearer
        for (NSDictionary *account in allAccounts) {
            NSString *accountName = account[kSAMKeychainAccountKey];
            [SAMKeychain deletePasswordForService:serviceName account:accountName];
        }
        
        //Clear UserDefaults except client tokens
        NSDictionary *defaultsDictionary = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
        for (NSString *key in [defaultsDictionary allKeys]) {
            if (![key isEqualToString:kClientToken] && ![key isEqualToString:kRefreshClientToken]) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
            }
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    };
    
    if([[FRSAuthManager sharedInstance] isAuthenticated]) {
        //Delete token off the API
        [[FRSAPIClient sharedClient] delete:tokenEndpoint
                             withParameters:nil
                                 completion:^(id responseObject, NSError *error) {
                                     clearTokens();
                                 }];
    } else {
        clearTokens();
    }
}



@end
