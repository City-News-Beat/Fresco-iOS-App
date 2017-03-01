//
//  FRSAuthManager.h
//  Fresco
//
//  Created by Maurice Wu on 1/3/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSBaseManager.h"

@interface FRSAuthManager : FRSBaseManager

@property (nonatomic, retain) NSString *passwordUsed;
@property (nonatomic, retain) NSString *emailUsed;
@property (nonatomic, retain) NSDictionary *socialUsed;

+ (instancetype)sharedInstance;

/**
 Tells us whether there is an authenticated user in session

 @return TRUE if authenticated, FALSE if not
 */
- (BOOL)isAuthenticated;


/**
 Registers a new user by creating one via the API and then subsequently logging them in
 
 @param digestion new user to create
 @param completion completion block returning user response object
 */
- (void)registerWithUserDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion;


/**
 Regular username/password signin method

 @param user user's username
 @param password user's password
 @param completion success completion block
 */
- (void)signIn:(NSString *)user password:(NSString *)password completion:(FRSAPIDefaultCompletionBlock)completion;


/**
 Signs user in with Twitter session

 @param session Twitter SDK session
 @param completion Sends back error and/or response
 */
- (void)signInWithTwitter:(TWTRSession *)session completion:(FRSAPIDefaultCompletionBlock)completion;

/**
 Signs user in with Facebook session
 
 @param session Facebook SDK session
 @param completion Sends back error and/or response
 */
- (void)signInWithFacebook:(FBSDKAccessToken *)token completion:(FRSAPIDefaultCompletionBlock)completion;


/**
 This method is responsbile for taking the token response and handling saving the new user to the app's sesion
 
 @param tokenObject token response from the API after authenticating
 */
- (void)handleUserLogin:(id)tokenObject completion:(FRSAPIDefaultCompletionBlock)completion;


/**
 Logs the user out
 */
- (void)logout;


/**
 Returns the current installation on the device. Typically used in registration or updating the user on the API

 @return NSDictionary of the installation object
 */
- (NSDictionary *)currentInstallation;


/**
 Links user to the passed Twitter credentials

 @param token Twitter user token
 @param secret Twitter user secret
 @param completion response block
 */
- (void)linkTwitter:(NSString *)token secret:(NSString *)secret completion:(FRSAPIDefaultCompletionBlock)completion;

/**
 Links user to the passed Facebook credentials
 
 @param token Facebook user token
 @param completion response block
 */
- (void)linkFacebook:(NSString *)token completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)unlinkFacebook:(FRSAPIDefaultCompletionBlock)completion;
- (void)unlinkTwitter:(FRSAPIDefaultCompletionBlock)completion;

/**
 Current social links, formatted for transmission to server
 All the info needed for "social_links" field of registration/signin

 @return NSDictionary with generated params
 */
- (NSDictionary *)socialDigestionWithTwitter:(TWTRSession *)twitterSession facebook:(FBSDKAccessToken *)facebookToken;

- (BOOL)checkAuthAndPresentOnboard;

@end
