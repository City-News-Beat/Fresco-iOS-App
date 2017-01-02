//
//  FRSSocial.m
//  Fresco
//
//  Created by Philip Bernstein on 4/23/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSSocial.h"
#import "FRSAPIClient.h"

@implementation FRSSocial

// TODO: for login w/ twitter & login w/ facebook, use register, and add extra api layer
+ (void)loginWithTwitter:(LoginCompletionBlock)completion {
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
      NSLog(@"SECRET: %@ \nTOKEN: %@", session.authTokenSecret, session.authToken);

      if (session) {
          [[FRSAPIClient sharedClient] signInWithTwitter:session
                                              completion:^(id responseObject, NSError *error) {

                                                if (responseObject) {

                                                    NSLog(@"RESPONSE: %d", [[responseObject objectForKey:@"valid_password"] boolValue]);

                                                    /*if ([[responseObject objectForKey:@"valid_password"] boolValue]) {
                        completion(TRUE, [NSError errorWithDomain:@"com.fresconews.Fresco" code:1125 userInfo:Nil], session, Nil, responseObject);
                        return;
                    }*/
                                                    completion(TRUE, error, session, Nil, responseObject);
                                                    return;
                                                }

                                                if (error) {
                                                    completion(FALSE, error, session, Nil, nil);
                                                }
                                              }];

      } else {
          completion(FALSE, error, Nil, Nil, nil);
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
                                    completion(FALSE, [NSError errorWithDomain:@"com.fresconews.fresco" code:301 userInfo:Nil], Nil, Nil, nil);
                                } else {
                                    [[FRSAPIClient sharedClient] signInWithFacebook:[FBSDKAccessToken currentAccessToken]
                                                                         completion:^(id responseObject, NSError *error) {
                                                                           if (error) {
                                                                               completion(FALSE, error, Nil, Nil, nil);

                                                                           } else {
                                                                               [[FRSAPIClient sharedClient] handleUserLogin:responseObject];

                                                                               NSLog(@"RESPONSE: %d", [[responseObject objectForKey:@"valid_password"] boolValue]);

                                                                               /*if ( [[responseObject objectForKey:@"valid_password"] boolValue]) {
                            completion(TRUE, [NSError errorWithDomain:@"com.fresconews.Fresco" code:1125 userInfo:Nil], Nil, [FBSDKAccessToken currentAccessToken], responseObject);
                            return;
                        }*/

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
