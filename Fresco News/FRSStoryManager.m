//
//  FRSStoryManager.m
//  Fresco
//
//  Created by Maurice Wu on 1/28/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSStoryManager.h"
#import "FRSAuthManager.h"

@implementation FRSStoryManager

static NSString *const storiesEndpoint = @"story/recent";
static NSString *const likeStoryEndpoint = @"story/%@/like";
static NSString *const repostStoryEndpoint = @"story/%@/repost";
static NSString *const unrepostStoryEndpoint = @"story/%@/unrepost";
static NSString *const storyUnlikeEndpoint = @"story/%@/unlike";
static NSString *const storyGalleriesEndpoint = @"story/%@/galleries";

+ (instancetype)sharedInstance {
    static FRSStoryManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[FRSStoryManager alloc] init];
    });
    return instance;
}

- (void)fetchStoriesWithLimit:(NSInteger)limit lastStoryID:(NSString *)offsetID completion:(void (^)(NSArray *stories, NSError *error))completion {

    NSDictionary *params = @{
        @"limit" : [NSNumber numberWithInteger:limit],
        @"last" : (offsetID != Nil) ? offsetID : @""
    };

    if (!offsetID) {
        params = @{
            @"limit" : [NSNumber numberWithInteger:limit],
        };
    }

    [[FRSAPIClient sharedClient] get:storiesEndpoint
                      withParameters:params
                          completion:^(id responseObject, NSError *error) {
                            completion(responseObject, error);
                          }];
}

- (void)likeStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion {
    if ([[FRSAuthManager sharedInstance] checkAuthAndPresentOnboard]) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresco.news" code:101 userInfo:Nil]);
        return;
    }

    NSString *endpoint = [NSString stringWithFormat:likeStoryEndpoint, story.uid];
    [[FRSAPIClient sharedClient] post:endpoint
                       withParameters:Nil
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                           }];
}

- (void)unlikeStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:storyUnlikeEndpoint, story.uid];
    [[FRSAPIClient sharedClient] post:endpoint
                       withParameters:Nil
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                           }];
}

- (void)repostStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion {
    if ([[FRSAuthManager sharedInstance] checkAuthAndPresentOnboard]) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresco.news" code:101 userInfo:Nil]);
        return;
    }

    NSString *endpoint = [NSString stringWithFormat:repostStoryEndpoint, story.uid];
    [[FRSAPIClient sharedClient] post:endpoint
                       withParameters:Nil
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                           }];
}

- (void)unrepostStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:unrepostStoryEndpoint, story.uid];

    [[FRSAPIClient sharedClient] post:endpoint
                       withParameters:Nil
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                           }];
}

- (void)getStoryWithUID:(NSString *)story completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:@"story/%@", story];

    [[FRSAPIClient sharedClient] get:endpoint
                      withParameters:nil
                          completion:^(id responseObject, NSError *error) {
                            if (error) {
                                completion(responseObject, error);
                                return;
                            }

                            if ([responseObject objectForKey:@"id"] != Nil && ![[responseObject objectForKey:@"id"] isEqual:[NSNull null]]) {
                                completion(responseObject, error);
                            }

                            // shouldn't happen
                            completion(responseObject, error);
                          }];
}

- (void)fetchGalleriesInStory:(NSString *)storyID completion:(void (^)(NSArray *galleries, NSError *error))completion {
    NSString *endpoint = [NSString stringWithFormat:storyGalleriesEndpoint, storyID];

    [[FRSAPIClient sharedClient] get:endpoint
                      withParameters:Nil
                          completion:^(id responseObject, NSError *error) {
                            completion(responseObject, error);
                          }];
}

@end
