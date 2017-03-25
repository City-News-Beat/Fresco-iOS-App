//
//  FRSSocialHandler.h
//  Fresco
//
//  Created by Omar Elfanek on 3/14/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRSSocialHandler : NSObject

#define LIKES @"likes"
#define LIKED @"liked"
#define REPOSTS @"reposts"
#define REPOSTED @"reposted"


#pragma mark - Like
/**
 Likes the FRSGallery and updates the like on the API and locally in Core Data.
 
 @param gallery FRSGallery to be liked.
 @param completion FRSAPIDefaultCompletionBlock
 */
+ (void)likeGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;

/**
 Unlikes the FRSGallery and updates the unlike on the API and locally in Core Data.
 
 @param gallery FRSGallery to be unliked.
 @param completion FRSAPIDefaultCompletionBlock
 */
+ (void)unlikeGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;


/**
 Likes the FRSStory and updates the like on the API and locally in Core Data.
 
 @param story FRSStory to be liked.
 @param completion FRSAPIDefaultCompletionBlock
 */
+ (void)likeStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion;

/**
 Unlikes the FRSStory and updates the unlike on the API and locally in Core Data.
 
 @param story FRSStory to be unliked.
 @param completion FRSAPIDefaultCompletionBlock
 */
+ (void)unlikeStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion;



#pragma mark - Repost
/**
 Reposts the FRSGallery and updates the repost on the API and locally in Core Data.
 
 @param gallery FRSGallery to be reposted.
 @param completion FRSAPIDefaultCompletionBlock
 */
+ (void)repostGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;

/**
 Unreposts the FRSGallery and updates the unrepost on the API and locally in Core Data.
 
 @param gallery FRSGallery to be unreposted.
 @param completion FRSAPIDefaultCompletionBlock
 */
+ (void)unrepostGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;


/**
 Reposts the FRSStory and updates the repost on the API and locally in Core Data.
 
 @param story FRSStory to be reposted.
 @param completion FRSAPIDefaultCompletionBlock
 */
+ (void)repostStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion;

/**
 Unreposts the FRSStory and updates the unrepost on the API and locally in Core Data.
 
 @param story FRSStory to be unreposted.
 @param completion FRSAPIDefaultCompletionBlock
 */
+ (void)unrepostStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion;



#pragma - Follow






@end
