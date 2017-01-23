//
//  FRSAuthManager.h
//  Fresco
//
//  Created by User on 1/3/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSBaseManager.h"

@interface FRSAuthManager : FRSBaseManager

@property (nonatomic, retain) NSString *passwordUsed;
@property (nonatomic, retain) NSString *emailUsed;
@property (nonatomic, retain) NSDictionary *socialUsed;

+ (instancetype)sharedInstance;

- (BOOL)isAuthenticated;
- (void)signIn:(NSString *)user password:(NSString *)password completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)signInWithTwitter:(TWTRSession *)session completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)signInWithFacebook:(FBSDKAccessToken *)token completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)registerWithUserDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion; // leaves burdon of constructing dict obj to sender (will have method for that)
- (NSString *)authenticationToken;
- (void)logout;
- (NSDictionary *)currentInstallation;

@end
