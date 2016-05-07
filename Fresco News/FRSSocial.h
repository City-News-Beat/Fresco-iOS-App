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

@interface FRSSocial : NSObject
typedef void (^LoginCompletionBlock)(BOOL authenticated, NSError *error, TWTRSession *session, FBSDKAccessToken *token);

+(void)loginWithTwitter:(LoginCompletionBlock)completion;
+(void)loginWithFacebook:(LoginCompletionBlock)completion parent:(UIViewController *)parent;

+(void)registerWithFacebook:(LoginCompletionBlock)completion parent:(UIViewController *)parent;
+(void)registerWithTwitter:(LoginCompletionBlock)completion;
@end
