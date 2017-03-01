//
//  FRSSessionManager.m
//  Fresco
//
//  Created by Maurice Wu on 1/25/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSSessionManager.h"
#import "FRSAuthManager.h"
#import "EndpointManager.h"
#import "NSString+Fresco.h"

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
    if(![[[FRSSessionManager sharedInstance] bearerForToken:kClientToken] isEqualToString:@""]) return;
    
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
                                       [self saveClientToken:accessTokenDict];
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
        [params setValue:[self refreshTokenForToken:kUserToken] forKey:@"refresh_token"];
    } else {
        [params setValue:[self refreshTokenForToken:kClientToken] forKey:@"refresh_token"];
    }

    [[FRSAPIClient sharedClient] post:tokenEndpoint
                       withParameters:params
                           completion:^(id responseObject, NSError *error) {
                               self.isRefreshing = NO;
                               
                               if (!error) {
                                   NSDictionary *accessTokenDict = responseObject[@"access_token"];
                                   if (accessTokenDict) {
                                       if (isUserToken) {
                                           [self saveUserToken:accessTokenDict];
                                       } else {
                                           [self saveClientToken:accessTokenDict];
                                       }
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

#pragma mark - Token Accessors

- (NSString *)bearerForToken:(NSString *)tokenType {
    NSDictionary *token = [[NSUserDefaults standardUserDefaults] dictionaryForKey:tokenType];
    if(token == nil || token[@"token"] == nil) return @"";
    return token[@"token"];
}

- (NSString *)refreshTokenForToken:(NSString *)tokenType {
    NSDictionary *token = (NSDictionary *)[[NSUserDefaults standardUserDefaults] dictionaryForKey:tokenType];
    if(token == nil || token[@"refresh_token"] == nil) return @"";
    return token[@"refresh_token"];
}

#pragma mark - Client Token

- (void)saveClientToken:(NSDictionary *)clientToken {
    [[NSUserDefaults standardUserDefaults] setObject:@{
                                                       @"token": clientToken[@"token"],
                                                       @"refresh_token": clientToken[@"refresh_token"]
                                                       } forKey:kClientToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)deleteClientTokens{
    //Delete token off the API
    [[FRSAPIClient sharedClient] delete:tokenEndpoint
                         withParameters:nil
                             completion:^(id responseObject, NSError *error) {
                                 //Remove client refresh and regular token
                                 [[NSUserDefaults standardUserDefaults] removeObjectForKey:kClientToken];
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

- (void)saveUserToken:(NSDictionary *)userToken {
    NSString *bearer = [userToken objectForKey:@"token"];
    
    //Save the bearer string to our keychain
    [SAMKeychain setPasswordData:[bearer dataUsingEncoding:NSUTF8StringEncoding] forService:serviceName account:[EndpointManager sharedInstance].currentEndpoint.frescoClientId];
    
    [[NSUserDefaults standardUserDefaults] setObject:@{
                                                       @"refresh_token": userToken[@"refresh_token"],
                                                       } forKey:kUserToken];
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
            if (![key isEqualToString:kClientToken]) {
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
