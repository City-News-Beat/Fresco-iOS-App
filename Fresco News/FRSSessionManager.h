//
//  FRSSessionManager.h
//  Fresco
//
//  Created by User on 1/25/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSBaseManager.h"

@interface FRSSessionManager : FRSBaseManager

+ (instancetype)sharedInstance;

- (void)generateClientCredentials;
- (void)refreshToken:(BOOL)isUserToken completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)saveCientToken:(NSString *)clientToken;
- (void)saveRefreshCientToken:(NSString *)refreshClientToken;
- (NSString *)clientToken;
- (void)saveUserToken:(NSString *)token;
- (void)deleteTokens;
- (NSString *)authenticationToken;

@end
