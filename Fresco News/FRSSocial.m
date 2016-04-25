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
+(TWTRLogInButton *)twitterLoginButton:(LoginCompletionBlock)completion {
    
    TWTRLogInButton *defaultLoginButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession* session, NSError* error) {
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
    
    // customize button
    
    return defaultLoginButton;
}

@end
