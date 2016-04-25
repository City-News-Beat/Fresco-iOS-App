//
//  FRSSocial.m
//  Fresco
//
//  Created by Philip Bernstein on 4/23/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSSocial.h"

@implementation FRSSocial
+(TWTRLogInButton *)twitterLoginButton:(LoginCompletionBlock)completion {
    
    TWTRLogInButton* logInButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession* session, NSError* error) {
        if (session) {
           
            completion(TRUE, Nil);
            
        } else {
            
            completion(FALSE, error);
            
        }
    }];
    
    return logInButton;
}

@end
