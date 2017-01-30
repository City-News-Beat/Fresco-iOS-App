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
- (void)likeStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)unlikeStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)repostStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)unrepostStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)fetchStoriesWithLimit:(NSInteger)limit lastStoryID:(NSString *)offsetID completion:(void (^)(NSArray *stories, NSError *error))completion;

@end
