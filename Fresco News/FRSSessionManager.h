//
//  FRSSessionManager.h
//  Fresco
//
//  Created by User on 1/25/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSBaseManager.h"

@interface FRSSessionManager : FRSBaseManager

+ (instancetype)sharedInstance;

- (NSString *)clientToken;
- (NSString *)authenticationToken;


/**
 Generates client credentials and saves them to the app
 */
- (void)generateClientCredentials;


/**
 Generates a new token with the app's current refresh token

 @param isUserToken whether the token being refreshed is a user token
 @param completion response block with response data
 */
- (void)refreshToken:(BOOL)isUserToken completion:(FRSAPIDefaultCompletionBlock)completion;


/**
 Saves client token to user defaults

 @param clientToken The token to save
 */
- (void)saveClientToken:(NSString *)clientToken;


/**
 Save refresh token to user defautls

 @param refreshClientToken the refresh token to save
 */
- (void)saveRefreshClientToken:(NSString *)refreshClientToken;


/**
 Saves user token to the app

 @param token The user token to save
 */
- (void)saveUserToken:(NSString *)token;

/**
 Saves refresh token to disk
 
 @param refreshUserToken refresh token to save
 */
- (void)saveRefreshToken:(NSString *)refreshUserToken;

/**
 Deletes all user related tokens & data from the app
 */
- (void)deleteUserData;

/**
 Deletes all client realted tokens from the app
 */
- (void)deleteClientTokens;

@end
