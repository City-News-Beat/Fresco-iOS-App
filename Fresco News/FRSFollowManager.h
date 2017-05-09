//
//  FRSFollowManager.h
//  Fresco
//
//  Created by Maurice Wu on 1/29/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSBaseManager.h"

@interface FRSFollowManager : FRSBaseManager

+ (instancetype)sharedInstance;

- (void)followUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)unfollowUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)getFollowersForUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)getFollowingForUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)getFollowersForUser:(FRSUser *)user last:(NSString *)lastUserID completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)getFollowingForUser:(FRSUser *)user last:(NSString *)lastUserID completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)followUserID:(NSString *)userID completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)unfollowUserID:(NSString *)userID completion:(FRSAPIDefaultCompletionBlock)completion;

@end
