//
//  FRSFeedManager.h
//  Fresco
//
//  Created by User on 1/29/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSBaseManager.h"

@interface FRSFeedManager : FRSBaseManager

+ (instancetype)sharedInstance;

- (void)fetchFollowing:(void (^)(NSArray *galleries, NSError *error))completion;
- (void)fetchFollowing:(NSString *)timeStamp completion:(void (^)(NSArray *galleries, NSError *error))completion;
- (void)fetchLikesFeedForUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)fetchLikesFeedForUser:(FRSUser *)user last:(NSString *)timeStamp completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)fetchGalleriesForUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)fetchGalleriesForUser:(FRSUser *)user last:(NSString *)timeStamp completion:(FRSAPIDefaultCompletionBlock)completion;

@end
