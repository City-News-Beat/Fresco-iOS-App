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

- (void)handleUserLogin:(id)responseObject;
- (BOOL)isAuthenticated;
- (void)signIn:(NSString *)user password:(NSString *)password completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)signInWithTwitter:(TWTRSession *)session completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)signInWithFacebook:(FBSDKAccessToken *)token completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)registerWithUserDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion; // leaves burdon of constructing dict obj to sender (will have method for that)
- (void)logout;
- (NSDictionary *)currentInstallation;
- (void)linkTwitter:(NSString *)token secret:(NSString *)secret completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)linkFacebook:(NSString *)token completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)unlinkFacebook:(FRSAPIDefaultCompletionBlock)completion;
- (void)unlinkTwitter:(FRSAPIDefaultCompletionBlock)completion;
- (void)addTwitter:(TWTRSession *)twitterSession completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)addFacebook:(FBSDKAccessToken *)facebookToken completion:(FRSAPIDefaultCompletionBlock)completion;
- (NSDictionary *)socialDigestionWithTwitter:(TWTRSession *)twitterSession facebook:(FBSDKAccessToken *)facebookToken; // current social links, formatted for transmission to server
- (BOOL)checkAuthAndPresentOnboard;

@end
