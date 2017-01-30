//
//  FRSSearchManager.h
//  Fresco
//
//  Created by User on 1/29/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSBaseManager.h"

@interface FRSSearchManager : FRSBaseManager

+ (instancetype)sharedInstance;

- (void)searchWithQuery:(NSString *)query completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)fetchNearbyUsersWithCompletion:(FRSAPIDefaultCompletionBlock)completion;

@end
