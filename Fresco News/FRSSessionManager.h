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

/**
 Returns user's bearer token

 @return NSString User bearer token
 */
- (NSString *)authenticationToken;

/**
 Returns the bearer for the passed token type
 
 @return NSString Token's bearer
 */
- (NSString *)bearerForToken:(NSString *)tokenType;

/**
 Returns the the refresh token for the passed token type
 
 @return Refresh token as a string
 */
- (NSString *)refreshTokenForToken:(NSString *)tokenType;

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
 Saves client token object to user defaults

 @param clientToken The token object to save
 */
- (void)saveClientToken:(NSDictionary *)clientToken;


/**
 Saves user token to the app

 @param token The user token to save
 */
- (void)saveUserToken:(NSDictionary *)token;


/**
 Deletes all user related tokens & data from the app
 */
- (void)deleteUserData;

/**
 Deletes all client related tokens from the app
 */
- (void)deleteClientTokens;

@end
