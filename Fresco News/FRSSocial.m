//
//  FRSSocial.m
//  Fresco
//
//  Created by Philip Bernstein on 4/23/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSSocial.h"
#import "FRSAuthManager.h"

@implementation FRSSocial

+ (void)loginWithTwitter:(LoginCompletionBlock)completion {
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
        if (session) {
            [[FRSAuthManager sharedInstance] signInWithTwitter:session
                                                    completion:^(id responseObject, NSError *error) {
                                                        if (error) {
                                                            completion(FALSE, error, Nil, Nil, nil);
                                                        } else {
                                                            completion(TRUE, Nil, Nil, [FBSDKAccessToken currentAccessToken], responseObject);
                                                        }
                                                    }];
            
        } else {
            completion(FALSE, error, nil, nil, nil);
        }
    }];
}

+ (void)loginWithFacebook:(LoginCompletionBlock)completion parent:(UIViewController *)parent manager:(FBSDKLoginManager *)manager {
    [manager logInWithReadPermissions:@[ @"public_profile", @"email", @"user_friends" ]
                   fromViewController:parent
                              handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                if (error) {
                                    completion(FALSE, error, Nil, Nil, nil);
                                } else if (result.isCancelled) {
                                    completion(FALSE, [NSError errorWithDomain:@"com.fresconews.fresco" code:301 userInfo:Nil], nil, nil, nil);
                                } else {
                                    [[FRSAuthManager sharedInstance] signInWithFacebook:[FBSDKAccessToken currentAccessToken]
                                                                             completion:^(id responseObject, NSError *error) {
                                                                               if (error) {
                                                                                   completion(FALSE, error, Nil, Nil, nil);
                                                                               } else {
                                                                                   completion(TRUE, Nil, Nil, [FBSDKAccessToken currentAccessToken], responseObject);
                                                                               }
                                                                             }];
                                }
                              }];
}

+ (void)registerWithFacebook:(LoginCompletionBlock)completion parent:(UIViewController *)parent {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:@[ @"public_profile", @"email", @"user_friends" ]
                 fromViewController:parent
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                              completion((!error), error, Nil, [FBSDKAccessToken currentAccessToken], nil);
                            }];
}

+ (void)registerWithTwitter:(LoginCompletionBlock)completion {
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
      completion((session != Nil && !error), error, session, Nil, nil);
    }];
}

+ (NSDictionary *)socialLinkForTwitterSession:(TWTRSession *)session {
    if (session.authTokenSecret && session.authToken) {
        return @{ @"platform" : @"twitter",
                  @"token" : session.authToken,
                  @"secret" : session.authTokenSecret };
    }

    return @{};
}

+ (NSDictionary *)socialLinkForFacebookToken:(FBSDKAccessToken *)token {
    NSString *tokenString = token.tokenString;

    if (tokenString) {
        return @{ @"platform" : @"facebook",
                  @"token" : tokenString };
    }

    return @{};
}

@end
