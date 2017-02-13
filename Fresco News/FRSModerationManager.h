//
//  FRSModerationManager.h
//  Fresco
//
//  Created by Maurice Wu on 1/29/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSBaseManager.h"

@interface FRSModerationManager : FRSBaseManager

+ (instancetype)sharedInstance;

- (void)blockUser:(NSString *)userID withCompletion:(FRSAPIDefaultCompletionBlock)completion;
- (void)unblockUser:(NSString *)userID withCompletion:(FRSAPIDefaultCompletionBlock)completion;
- (void)reportUser:(NSString *)userID params:(NSDictionary *)params completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)reportGallery:(FRSGallery *)gallery params:(NSDictionary *)params completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)fetchBlockedUsers:(FRSAPIDefaultCompletionBlock)completion;
- (void)checkSuspended;
- (void)presentSmooch;

@end
