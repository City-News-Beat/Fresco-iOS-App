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
+(void)loginWithTwitter:(LoginCompletionBlock)completion {
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
        if (session) {
            [[FRSAPIClient sharedClient] signInWithTwitter:session completion:^(id responseObject, NSError *error) {
                if (error) {
                    completion(TRUE, Nil);
                }
                else {
                    completion(FALSE, error);
                }
            }];
            
        } else {
            completion(FALSE, error);
        }
    }];
}

+(void)loginWithFacebook:(LoginCompletionBlock)completion parent:(UIViewController *)parent {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions: @[@"public_profile", @"email", @"user_friends"] fromViewController:parent handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            completion(FALSE, error);
        } else if (result.isCancelled) {
            completion(FALSE, [NSError errorWithDomain:@"com.fresconews.fresco" code:301 userInfo:Nil]);
        } else {
            [[FRSAPIClient sharedClient] signInWithFacebook:[FBSDKAccessToken currentAccessToken]
                completion:^(id responseObject, NSError *error) {
                    if (error) {
                        completion(FALSE, error);
                    }
                    else {
                        completion(TRUE, Nil);
                    }
            }];
        }
    }];
}

+(NSDictionary *)socialLinkForTwitterSession:(TWTRSession *)session {
    
    
    return Nil;
}

+(NSDictionary *)socialLinkForFacebookToken:(FBSDKAccessToken *)token {
    
    
    return Nil;
}

@end
