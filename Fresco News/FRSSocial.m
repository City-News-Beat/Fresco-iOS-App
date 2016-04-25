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
    [login logInWithReadPermissions: @[@"public_profile"] fromViewController:parent handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
                 NSLog(@"Process error");
             } else if (result.isCancelled) {
                 NSLog(@"Cancelled");
             } else {
                 NSLog(@"Logged in");
             }
         }];
}

@end
