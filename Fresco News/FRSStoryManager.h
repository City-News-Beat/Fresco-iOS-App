//
//  FRSStoryManager.h
//  Fresco
//
//  Created by User on 1/28/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSBaseManager.h"

@interface FRSStoryManager : FRSBaseManager

+ (instancetype)sharedInstance;

- (void)getStoryWithUID:(NSString *)user completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)fetchGalleriesInStory:(NSString *)storyID completion:(void (^)(NSArray *galleries, NSError *error))completion;

@end
