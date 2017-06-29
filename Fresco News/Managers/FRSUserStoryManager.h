//
//  FRSUserStoryManager.h
//  Fresco
//
//  Created by Revanth Kumar Yarlagadda on 6/21/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSBaseManager.h"
#import "FRSUserStory+CoreDataClass.h"

@interface FRSUserStoryManager : FRSBaseManager

+ (instancetype)sharedInstance;

- (void)fetchUserStoriesWithLimit:(NSInteger)limit offsetStoryID:(NSString *)offset completion:(FRSAPIDefaultCompletionBlock)completion;

- (void)fetchCommentsForStoryID:(NSString *)storyID completion:(FRSAPIDefaultCompletionBlock)completion;

- (void)fetchMoreComments:(FRSUserStory *)story last:(NSString *)last completion:(FRSAPIDefaultCompletionBlock)completion;

@end
