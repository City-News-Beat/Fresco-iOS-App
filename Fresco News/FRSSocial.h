//
//  FRSSocial.h
//  Fresco
//
//  Created by Philip Bernstein on 4/23/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import <AccountKit/AccountKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Twitter/Twitter.h>
#import "FRSAPIClient.h"

@interface FRSSocial : NSObject
typedef void (^LoginCompletionBlock)(BOOL authenticated, NSError *error, TWTRSession *session, FBSDKAccessToken *token);

// login methods communicate with both the social outlet, and the API
+(void)loginWithTwitter:(LoginCompletionBlock)completion;
+(void)loginWithFacebook:(LoginCompletionBlock)completion parent:(UIViewController *)parent;

// register methods simply communicate with social outlet, for eventual communication to the API
+(void)registerWithFacebook:(LoginCompletionBlock)completion parent:(UIViewController *)parent;
+(void)registerWithTwitter:(LoginCompletionBlock)completion;
@end
