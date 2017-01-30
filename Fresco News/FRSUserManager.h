//
//  UserManager.h
//  Fresco
//
//  Created by User on 1/3/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSBaseManager.h"

@interface FRSUserManager : FRSBaseManager

@property (nonatomic, retain) FRSUser *authenticatedUser;

+ (instancetype)sharedInstance;

- (void)updateIdentityWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)updateUserWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)updateLocalUser;
- (void)refreshCurrentUser:(FRSAPIDefaultCompletionBlock)completion;
- (void)getUserWithUID:(NSString *)user completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)pingLocation:(NSDictionary *)location completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)checkEmail:(NSString *)email completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)checkUsername:(NSString *)username completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)postAvatarWithParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)updateLegacyUserWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)getTermsWithCompletion:(FRSAPIDefaultCompletionBlock)completion;
- (void)acceptTermsWithCompletion:(FRSAPIDefaultCompletionBlock)completion;
- (void)disableAccountWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)reloadUser;
- (void)reloadUser:(FRSAPIDefaultCompletionBlock)completion;

@end
