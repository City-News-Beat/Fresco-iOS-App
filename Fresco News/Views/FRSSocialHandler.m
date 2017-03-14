//
//  FRSSocialHandler.m
//  Fresco
//
//  Created by Omar Elfanek on 3/14/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSSocialHandler.h"
#import "FRSGalleryManager.h"
#import "FRSStoryManager.h"
#import "FRSAuthManager.h"

@implementation FRSSocialHandler


#pragma mark - Like / Unlike

+ (void)likeGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    __block NSInteger galleryLikes = [[gallery valueForKey:LIKES] integerValue];
    
    galleryLikes++;
    [self didLike:YES gallery:gallery count:galleryLikes];
    
    [[FRSGalleryManager sharedInstance] likeGallery:gallery completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

+ (void)unlikeGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    __block NSInteger galleryLikes = [[gallery valueForKey:LIKES] integerValue];
    
    galleryLikes--;
    [self didLike:NO gallery:gallery count:galleryLikes];
    
    [[FRSGalleryManager sharedInstance] unlikeGallery:gallery completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

+ (void)likeStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion {
    __block NSInteger storyLikes = [[story valueForKey:LIKES] integerValue];
    
    storyLikes++;
    [self didLike:YES story:story count:storyLikes];
    
    [[FRSStoryManager sharedInstance] likeStory:story completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

+ (void)unlikeStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion {
    __block NSInteger storyLikes = [[story valueForKey:LIKES] integerValue];
    
    storyLikes--;
    [self didLike:NO story:story count:storyLikes];
    
    [[FRSStoryManager sharedInstance] unlikeStory:story completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}


#pragma mark - Repost / Unrepost

+ (void)repostGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    __block NSInteger galleryReposts = [[gallery valueForKey:REPOSTS] integerValue];
    
    galleryReposts++;
    [self didRepost:YES gallery:gallery count:galleryReposts];
    
    [[FRSGalleryManager sharedInstance] repostGallery:gallery completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

+ (void)unrepostGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    __block NSInteger galleryReposts = [[gallery valueForKey:REPOSTS] integerValue];
    
    galleryReposts--;
    [self didRepost:NO gallery:gallery count:galleryReposts];
    
    [[FRSGalleryManager sharedInstance] unrepostGallery:gallery completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

+ (void)repostStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion {
    __block NSInteger storyReposts = [[story valueForKey:REPOSTS] integerValue];
    
    storyReposts++;
    [self didRepost:YES story:story count:storyReposts];
    
    [[FRSStoryManager sharedInstance] repostStory:story completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

+ (void)unrepostStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion {
    __block NSInteger storyReposts = [[story valueForKey:REPOSTS] integerValue];
    
    storyReposts--;
    [self didRepost:NO story:story count:storyReposts];
    
    [[FRSStoryManager sharedInstance] unrepostStory:story completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

#pragma mark - Private
/**
 Updates the like/unlike status on an FRSGallery in Core Data.

 @param didLike BOOL pass in YES if the user did like the gallery
 @param gallery FRSGallery to be updated
 @param count NSInteger number of likes to be stored on the gallery
 */
+ (void)didLike:(BOOL)didLike gallery:(FRSGallery *)gallery count:(NSInteger)count {
    if (didLike) {
        [gallery setValue:[NSNumber numberWithInteger:count] forKey:LIKES];
        [gallery setValue:@1 forKey:LIKED];
    } else {
        [gallery setValue:[NSNumber numberWithInteger:count] forKey:LIKES];
        [gallery setValue:@0 forKey:LIKED];
    }
    [[[FRSAuthManager sharedInstance] managedObjectContext] save:nil];
}

/**
 Updates the like/unlike status on an FRSStory in Core Data.
 
 @param didLike BOOL pass in YES if the user did like the story
 @param story FRSStory to be updated
 @param count NSInteger number of likes to be stored on the story
 */
+ (void)didLike:(BOOL)didLike story:(FRSStory *)story count:(NSInteger)count {
    if (didLike) {
        [story setValue:[NSNumber numberWithInteger:count] forKey:LIKES];
        [story setValue:@1 forKey:LIKED];
    } else {
        [story setValue:[NSNumber numberWithInteger:count] forKey:LIKES];
        [story setValue:@0 forKey:LIKED];
    }
    [[[FRSAuthManager sharedInstance] managedObjectContext] save:nil];
}


/**
 Updates the reposted/unreposted status on an FRSGallery in Core Data.
 
 @param didRepost BOOL pass in YES if the user did repost the gallery
 @param gallery FRSGallery to be updated
 @param count NSInteger number of reposts to be stored on the gallery
 */
+ (void)didRepost:(BOOL)didRepost gallery:(FRSGallery *)gallery count:(NSInteger)count {
    if (didRepost) {
        [gallery setValue:[NSNumber numberWithInteger:count] forKey:REPOSTS];
        [gallery setValue:@1 forKey:REPOSTED];
    } else {
        [gallery setValue:[NSNumber numberWithInteger:count] forKey:REPOSTS];
        [gallery setValue:@0 forKey:REPOSTED];
    }
    [[[FRSAuthManager sharedInstance] managedObjectContext] save:nil];
}

/**
 Updates the reposted/unreposted status on an FRSStory in Core Data.
 
 @param didRepost BOOL pass in YES if the user did repost the story
 @param gallery FRSGallery to be updated
 @param count NSInteger number of reposts to be stored on the story
 */
+ (void)didRepost:(BOOL)didRepost story:(FRSStory *)story count:(NSInteger)count {
    if (didRepost) {
        [story setValue:[NSNumber numberWithInteger:count] forKey:REPOSTS];
        [story setValue:@1 forKey:REPOSTED];
    } else {
        [story setValue:[NSNumber numberWithInteger:count] forKey:REPOSTS];
        [story setValue:@0 forKey:REPOSTED];
    }
    [[[FRSAuthManager sharedInstance] managedObjectContext] save:nil];
}

@end
