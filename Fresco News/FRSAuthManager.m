//
//  FRSAuthManager.m
//  Fresco
//
//  Created by Maurice Wu on 1/3/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSAuthManager.h"
#import "FRSUserManager.h"
#import "FRSSessionManager.h"
#import "EndpointManager.h"
#import "NSString+Fresco.h"
#import "FRSModerationManager.h"
#import "FRSOnboardingViewController.h"

// sign in / sign up (authorization) methods
static NSString *const loginEndpoint = @"auth/signin";
static NSString *const signUpEndpoint = @"auth/register";
static NSString *const socialLoginEndpoint = @"auth/signin/social";
static NSString *const addSocialEndpoint = @"user/social/connect/";
static NSString *const deleteSocialEndpoint = @"user/social/disconnect/";

@implementation FRSAuthManager

+ (instancetype)sharedInstance {
    static FRSAuthManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[FRSAuthManager alloc] init];
    });
    return instance;
}

- (BOOL)isAuthenticated {
    if ([[SAMKeychain accountsForService:serviceName] count] > 0) {
        return TRUE;
    }
    return FALSE;
}

- (void)handleUserLogin:(id)responseObject {
    if ([responseObject objectForKey:@"token"]) {
        [[FRSSessionManager sharedInstance] saveUserToken:[responseObject objectForKey:@"token"]];
    }

    FRSUser *authenticatedUser = [[FRSUserManager sharedInstance] authenticatedUser];

    if (!authenticatedUser) {
        authenticatedUser = [NSEntityDescription insertNewObjectForEntityForName:@"FRSUser" inManagedObjectContext:[self managedObjectContext]];
    }

    [[FRSUserManager sharedInstance] updateLocalUser];

    NSDictionary *currentInstallation = [self currentInstallation];

    if ([currentInstallation objectForKey:@"device_token"]) {
        NSDictionary *update = @{ @"installation" : currentInstallation };
        [[FRSUserManager sharedInstance] updateUserWithDigestion:update
                                                      completion:^(id responseObject, NSError *error){
                                                      }];
    }
}

- (void)registerWithUserDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion {
    // email
    // username
    // password
    // twitter_handle
    // social_links
    // installation

    if (digestion[@"password"]) {
        self.passwordUsed = digestion[@"password"];
    } else {
        self.socialUsed = digestion[@"social_links"];
    }

    [[FRSAPIClient sharedClient] post:signUpEndpoint
                       withParameters:digestion
                           completion:^(id responseObject, NSError *error) {

                             if ([responseObject objectForKey:@"token"] && ![responseObject objectForKey:@"err"]) {
                                 [self handleUserLogin:responseObject];
                             }

                             completion(responseObject, error);
                           }];
}

- (void)logout {
    [[FRSSessionManager sharedInstance] deleteTokens];
}

// all info needed for "installation" field of registration/signin
- (NSDictionary *)currentInstallation {

    NSMutableDictionary *currentInstallation = [[NSMutableDictionary alloc] init];
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceToken"];

    if (deviceToken != Nil || [deviceToken isEqual:[NSNull null]]) {
        currentInstallation[@"device_token"] = deviceToken;
    } else {
    }

    NSString *sessionID = [[NSUserDefaults standardUserDefaults] objectForKey:@"SESSION_ID"];

    if (sessionID) {
        currentInstallation[@"device_id"] = sessionID;
    } else {
        sessionID = [NSString randomString];
        currentInstallation[@"device_id"] = sessionID;
        [[NSUserDefaults standardUserDefaults] setObject:sessionID forKey:@"SESSION_ID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    currentInstallation[@"platform"] = @"ios";

    NSString *appVersion = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];

    if (appVersion) {
        currentInstallation[@"app_version"] = appVersion;
    }

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    NSString *timeZone = [dateFormat stringFromDate:[NSDate date]];

    if (timeZone) {
        currentInstallation[@"timezone"] = timeZone;
    }

    NSString *localeString = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];

    if (localeString) {
        currentInstallation[@"locale_identifier"] = localeString;
    }

    return currentInstallation;
}

- (void)signIn:(NSString *)user password:(NSString *)password completion:(FRSAPIDefaultCompletionBlock)completion {
    self.passwordUsed = password;

    NSDictionary *params = @{ @"username" : user,
                              @"password" : password };

    [[FRSAPIClient sharedClient] post:loginEndpoint
                       withParameters:params
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                             if (!error) {
                                 [self handleUserLogin:responseObject];
                             }
                           }];
}

/*
 Sign in: all expect user to have an account, either returns a token, a challenge (i.e. 'create an account') or incorrect details
 */
- (void)signInWithTwitter:(TWTRSession *)session completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *twitterAccessToken = session.authToken;
    NSString *twitterAccessTokenSecret = session.authTokenSecret;
    NSDictionary *authDictionary = @{ @"platform" : @"twitter",
                                      @"token" : twitterAccessToken,
                                      @"secret" : twitterAccessTokenSecret };
    self.socialUsed = authDictionary;

    [[FRSAPIClient sharedClient] post:socialLoginEndpoint
                       withParameters:authDictionary
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                             // handle cacheing of authentication
                             if (!error) {
                                 [self handleUserLogin:responseObject];
                             }

                           }];
}

- (void)addTwitter:(TWTRSession *)twitterSession completion:(FRSAPIDefaultCompletionBlock)completion {
    NSMutableDictionary *twitterDictionary = [[NSMutableDictionary alloc] init];
    [twitterDictionary setObject:@"Twitter" forKey:@"platform"];

    if (twitterSession.authToken && twitterSession.authTokenSecret) {
        [twitterDictionary setObject:twitterSession.authToken forKey:@"token"];
        [twitterDictionary setObject:twitterSession.authTokenSecret forKey:@"secret"];
    } else {
        completion(Nil, [NSError errorWithDomain:@"com.fresconews.Fresco" code:401 userInfo:Nil]);
        return;
    }

    [[FRSAPIClient sharedClient] post:addSocialEndpoint
                       withParameters:twitterDictionary
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                           }];
}

- (void)addFacebook:(FBSDKAccessToken *)facebookToken completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *tokenString = facebookToken.tokenString;

    if (!tokenString) {
        completion(Nil, [NSError errorWithDomain:@"com.fresconews.Fresco" code:401 userInfo:Nil]);
        return;
    }

    NSDictionary *facebookDictionary = @{ @"platform" : @"Facebook",
                                          @"token" : tokenString };

    [[FRSAPIClient sharedClient] post:addSocialEndpoint
                       withParameters:facebookDictionary
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                           }];
}

- (void)signInWithFacebook:(FBSDKAccessToken *)token completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *facebookAccessToken = token.tokenString;
    NSDictionary *authDictionary = @{ @"platform" : @"facebook",
                                      @"token" : facebookAccessToken };
    self.socialUsed = authDictionary;

    [[FRSAPIClient sharedClient] post:socialLoginEndpoint
                       withParameters:authDictionary
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error); // burden of error handling falls on sender

                             // handle internal cacheing of authentication
                             if (!error) {
                                 [self handleUserLogin:responseObject];
                             }
                           }];
}

- (void)linkTwitter:(NSString *)token secret:(NSString *)secret completion:(FRSAPIDefaultCompletionBlock)completion {
    if (token && secret) {
        [[FRSAPIClient sharedClient] post:addSocialEndpoint
            withParameters:@{ @"platform" : @"twitter",
                              @"token" : token,
                              @"secret" : secret }
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
    } else {
        completion(Nil, [NSError errorWithDomain:@"com.fresconews.Fresco" code:400 userInfo:@{ @"message" : @"Incorrect Twitter credentials" }]);
    }
}

- (void)linkFacebook:(NSString *)token completion:(FRSAPIDefaultCompletionBlock)completion {
    if (token) {
        [[FRSAPIClient sharedClient] post:addSocialEndpoint
            withParameters:@{ @"platform" : @"facebook",
                              @"token" : token }
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
    } else {
        completion(Nil, [NSError errorWithDomain:@"com.fresconews.Fresco" code:400 userInfo:@{ @"message" : @"Incorrect Twitter credentials" }]);
    }
}

- (void)unlinkFacebook:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSAPIClient sharedClient] post:deleteSocialEndpoint
        withParameters:@{ @"platform" : @"facebook" }
        completion:^(id responseObject, NSError *error) {
          completion(responseObject, error);
        }];
}

- (void)unlinkTwitter:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSAPIClient sharedClient] post:deleteSocialEndpoint
        withParameters:@{ @"platform" : @"twitter" }
        completion:^(id responseObject, NSError *error) {
          completion(responseObject, error);
        }];
}

// all the info needed for "social_links" field of registration/signin
- (NSDictionary *)socialDigestionWithTwitter:(TWTRSession *)twitterSession facebook:(FBSDKAccessToken *)facebookToken {
    // side note, twitter_handle is outside social links, needs to be handled outside this method
    NSMutableDictionary *socialDigestion = [[NSMutableDictionary alloc] init];

    if (twitterSession) {
        // add twitter to digestion
        if (twitterSession.authToken && twitterSession.authTokenSecret) {
            NSDictionary *twitterDigestion = @{ @"token" : twitterSession.authToken,
                                                @"secret" : twitterSession.authTokenSecret };
            [socialDigestion setObject:twitterDigestion forKey:@"twitter"];
        }
    }

    if (facebookToken) {
        // add facebook to digestion
        if (facebookToken.tokenString) {
            NSDictionary *facebookDigestion = @{ @"token" : facebookToken.tokenString };
            [socialDigestion setObject:facebookDigestion forKey:@"facebook"];
        }
    }

    return socialDigestion;
}

- (BOOL)checkAuthAndPresentOnboard {
    if (![[FRSAuthManager sharedInstance] isAuthenticated]) {
        
        id<FRSApp> appDelegate = (id<FRSApp>)[[UIApplication sharedApplication] delegate];
        FRSOnboardingViewController *onboardVC = [[FRSOnboardingViewController alloc] init];
        UINavigationController *navController = (UINavigationController *)appDelegate.window.rootViewController;
        
        if ([[navController class] isSubclassOfClass:[UINavigationController class]]) {
            [navController pushViewController:onboardVC animated:FALSE];
        } else {
            UITabBarController *tab = (UITabBarController *)navController;
            tab.navigationController.interactivePopGestureRecognizer.enabled = YES;
            tab.navigationController.interactivePopGestureRecognizer.delegate = nil;
            UINavigationController *onboardNav = [[UINavigationController alloc] init];
            [onboardNav pushViewController:onboardVC animated:NO];
            [tab presentViewController:onboardNav animated:YES completion:Nil];
        }
        
        return YES;
    }
    
    if ([[FRSUserManager sharedInstance] authenticatedUser].suspended) {
        [[FRSModerationManager sharedInstance] checkSuspended];
        return NO;
    }
    
    return FALSE;
}

@end
