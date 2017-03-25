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
- (void)updateLocalUser:(FRSAPIDefaultCompletionBlock)completion;
- (void)refreshCurrentUser:(FRSAPIDefaultCompletionBlock)completion;


- (void)getUserWithUID:(NSString *)user completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)checkEmail:(NSString *)email completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)checkUsername:(NSString *)username completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)postAvatarWithParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)updateLegacyUserWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)getTermsWithCompletion:(FRSAPIDefaultCompletionBlock)completion;
- (void)acceptTermsWithCompletion:(FRSAPIDefaultCompletionBlock)completion;
- (void)disableAccountWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)reloadUser;
- (void)reloadUser:(FRSAPIDefaultCompletionBlock)completion;


/**
 Updates the user's location
 
 @param location CLLocation of the current user
 @param completion complection block for response
 */
- (void)updateUserLocation:(CLLocation *)location completion:(FRSAPIDefaultCompletionBlock)completion;



/**
 Saves new fields on user object from passed object

 @param responseObject dictionary containing the user field
 @param synchronously whether to run the operation synchronously or not
 */
- (void)saveUserFields:(NSDictionary *)responseObject andSynchronously:(BOOL)synchronously;


/**
 Updates the user defaults based on the passed user response object

 @param responseObject the user response object
 */
- (void)updateUserDefaultsWithResponseObject:(NSDictionary *)responseObject;

@end
