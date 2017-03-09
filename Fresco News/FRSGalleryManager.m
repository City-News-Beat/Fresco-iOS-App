//
//  FRSGalleryManager.m
//  Fresco
//
//  Created by Maurice Wu on 1/29/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSGalleryManager.h"
#import "FRSAuthManager.h"

static NSString *const likeGalleryEndpoint = @"gallery/%@/like";
static NSString *const repostGalleryEndpoint = @"gallery/%@/repost";
static NSString *const unrepostGalleryEndpoint = @"gallery/%@/unrepost";
static NSString *const commentsEndpoint = @"gallery/%@/comments?limit=10";
static NSString *const purchasesEndpoint = @"gallery/%@/purchases";
static NSString *const commentEndpoint = @"gallery/%@/comment/";
static NSString *const galleryUnlikeEndpoint = @"gallery/%@/unlike";
static NSString *const deleteCommentEndpoint = @"gallery/%@/comment/delete";
static NSString *const likedGalleryEndpoint = @"gallery/%@/likes";
static NSString *const repostedGalleryEndpoint = @"gallery/%@/reposts";
static NSString *const highlightsEndpoint = @"gallery/highlights";
static NSString *const paginateComments = @"gallery/%@/comments?limit=10&last=%@";
static NSString *const getCommentEndpoint = @"gallery/%@/comment/%@";
static NSString *const createGalleryEndpoint = @"gallery/submit";
static NSString *const getPostEndpoint = @"post/%@";
static NSString *const getOutletEndpoint = @"outlet/%@";

@implementation FRSGalleryManager

+ (instancetype)sharedInstance {
    static FRSGalleryManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[FRSGalleryManager alloc] init];
    });
    return instance;
}

#pragma mark - Creating Galleries

- (void)createGallery:(NSDictionary *)galleryDict completion:(FRSAPIDefaultCompletionBlock)completion {
    [[FRSAPIClient sharedClient] post:createGalleryEndpoint
                       withParameters:galleryDict
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                           }];
}

#pragma mark - Loading Galleries

- (void)fetchGalleriesWithLimit:(NSInteger)limit offsetGalleryID:(NSString *)offset completion:(void (^)(NSArray *galleries, NSError *error))completion {
    NSDictionary *params = @{
        @"limit" : [NSNumber numberWithInteger:limit],
        @"last" : (offset != Nil) ? offset : @"",
    };

    if (!offset) {
        params = @{ @"limit" : [NSNumber numberWithInteger:limit] };
    }

    [[FRSAPIClient sharedClient] get:highlightsEndpoint
                      withParameters:params
                          completion:^(id responseObject, NSError *error) {
                            completion(responseObject, error);
                          }];
}

- (void)fetchLikesForGallery:(NSString *)galleryID limit:(NSNumber *)limit lastID:(NSString *)lastID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:likedGalleryEndpoint, galleryID];

    [[FRSAPIClient sharedClient] get:endpoint
        withParameters:@{ @"limit" : limit,
                          @"last" : lastID }
        completion:^(id responseObject, NSError *error) {
          completion(responseObject, error);
        }];
}

- (void)fetchRepostsForGallery:(NSString *)galleryID limit:(NSNumber *)limit lastID:(NSString *)lastID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:repostedGalleryEndpoint, galleryID];

    [[FRSAPIClient sharedClient] get:endpoint
        withParameters:@{ @"limit" : limit,
                          @"last" : lastID }
        completion:^(id responseObject, NSError *error) {
          completion(responseObject, error);
        }];
}

- (void)getGalleryWithUID:(NSString *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:@"gallery/%@", gallery];

    [[FRSAPIClient sharedClient] get:endpoint
                      withParameters:nil
                          completion:^(id responseObject, NSError *error) {
                            completion(responseObject, error);
                          }];
}

#pragma mark - Likes/Reposts

- (void)likeGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    if ([[FRSAuthManager sharedInstance] checkAuthAndPresentOnboard]) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresco.news" code:101 userInfo:Nil]);
        return;
    }

    NSString *endpoint = [NSString stringWithFormat:likeGalleryEndpoint, gallery.uid];
    [[FRSAPIClient sharedClient] post:endpoint
                       withParameters:Nil
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                             [gallery setValue:@(TRUE) forKey:@"liked"];
                             [[self managedObjectContext] save:Nil];
                           }];
}

- (void)unlikeGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {

    NSString *endpoint = [NSString stringWithFormat:galleryUnlikeEndpoint, gallery.uid];
    [[FRSAPIClient sharedClient] post:endpoint
                       withParameters:Nil
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                             [gallery setValue:@(TRUE) forKey:@"liked"];
                           }];
}

- (void)repostGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    if ([[FRSAuthManager sharedInstance] checkAuthAndPresentOnboard]) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresco.news" code:101 userInfo:Nil]);
        return;
    }

    if ([[gallery valueForKey:@"reposted"] boolValue]) {
        [self unrepostGallery:gallery completion:completion];
        return;
    }


    NSString *endpoint = [NSString stringWithFormat:repostGalleryEndpoint, gallery.uid];

    [[FRSAPIClient sharedClient] post:endpoint
                       withParameters:Nil
                           completion:^(id responseObject, NSError *error) {
                               completion(responseObject, error);
                               
                               [gallery setValue:@(TRUE) forKey:@"reposted"];
                               [[self managedObjectContext] save:nil];
                           }];
}

- (void)unrepostGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:unrepostGalleryEndpoint, gallery.uid];

    [[FRSAPIClient sharedClient] post:endpoint
                       withParameters:Nil
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);

                             [gallery setValue:@(FALSE) forKey:@"reposted"];

                             [[self managedObjectContext] save:Nil];
                           }];
}

#pragma mark - Comments

- (void)fetchCommentsForGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    [self fetchCommentsForGalleryID:gallery.uid completion:completion];
}

- (void)fetchCommentsForGalleryID:(NSString *)galleryID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:commentsEndpoint, galleryID];
    [[FRSAPIClient sharedClient] get:endpoint
                      withParameters:Nil
                          completion:^(id responseObject, NSError *error) {
                            completion(responseObject, error);
                          }];
}

- (void)fetchMoreComments:(FRSGallery *)gallery last:(NSString *)last completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:paginateComments, gallery.uid, last];

    [[FRSAPIClient sharedClient] get:endpoint
                      withParameters:Nil
                          completion:^(id responseObject, NSError *error) {
                            completion(responseObject, error);
                          }];
}

- (void)addComment:(NSString *)comment toGallery:(NSString *)galleryID completion:(FRSAPIDefaultCompletionBlock)completion {
    if ([[FRSAuthManager sharedInstance] checkAuthAndPresentOnboard]) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresco.news" code:101 userInfo:Nil]);
        return;
    }

    NSString *endpoint = [NSString stringWithFormat:commentEndpoint, galleryID];
    NSDictionary *parameters = @{ @"comment" : comment };

    [[FRSAPIClient sharedClient] post:endpoint withParameters:parameters completion:completion];
}

- (void)deleteComment:(NSString *)commentID fromGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:deleteCommentEndpoint, gallery.uid];
    NSDictionary *params = @{ @"comment_id" : commentID };

    [[FRSAPIClient sharedClient] post:endpoint
                       withParameters:params
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);
                           }];
}

#pragma mark - Purchases

- (void)fetchPurchasesForGalleryID:(NSString *)galleryID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:purchasesEndpoint, galleryID];
    [[FRSAPIClient sharedClient] get:endpoint
                      withParameters:Nil
                          completion:^(id responseObject, NSError *error) {
                            completion(responseObject, error);
                          }];
}

- (void)getPostWithID:(NSString *)post completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:getPostEndpoint, post];
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

- (void)getOutletWithID:(NSString *)outlet completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:getOutletEndpoint, outlet];
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

@end
