//
//  FRSGalleryManager.m
//  Fresco
//
//  Created by User on 1/29/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import "FRSGalleryManager.h"
#import "FRSUploadManager.h"
#import "FRSAuthManager.h"
#import <Photos/Photos.h>

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
                           completion:completion];
}

- (void)createGalleryWithParams:(NSDictionary*)params andAssets:(NSArray *)assets completion:(FRSAPIDefaultCompletionBlock)completion {
    NSInteger videosCounted = 0;
    NSInteger photosCounted = 0;
    //Keep track of total assets added to signify completion of digest creationg
    __block NSInteger assetsAdded = 0;
    NSMutableArray *posts = [[NSMutableArray alloc] initWithCapacity:[assets count]];
    //Init empty so we can choose ordering later
    for (NSInteger i = 0; i < [assets count]; i++) [posts addObject:[NSNull null]];
    
    
    //Block to create the gallery once done
    void (^createGallery)(void) = ^ {
        NSMutableDictionary *updateParams = [params mutableCopy];
        [updateParams setObject:posts forKey:@"posts_new"];
        
        [self createGallery:updateParams completion:^(id responseObject, NSError *error) {
            if(!error) {
                [FRSTracker track:submissionsEvent
                       parameters:@{ @"videos_submitted" : @(videosCounted),
                                     @"photos_submitted" : @(photosCounted),
                                     ASSIGNMENT_ID       : params[@"assignment_id"] != nil ? params[@"assignment_id"] : @"" }];
                
                completion(responseObject, nil);
            } else {
                completion(nil, error);
            }
        }];
    };
    
    //Loop through assets and generate digests with addresses
    for (NSInteger i = 0; i < [assets count]; i++) {
        PHAsset *asset = assets[i];
        
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            videosCounted++;
        } else {
            photosCounted++;
        }
        
        [[FRSUploadManager sharedInstance] digestForAsset:asset
                                                 callback:^(id responseObject, NSError *error) {
                                                     if (error) {
                                                         completion(error, nil);
                                                     } else {
                                                         //This is an async operation, but we need the same ordering
                                                         [posts replaceObjectAtIndex:i withObject:responseObject];
                                                         assetsAdded++;
                                                         if(assetsAdded == [assets count]) {
                                                             createGallery();
                                                         }
                                                     }
                                                 }];
    }
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

    [FRSTracker track:galleryLiked parameters:@{ @"gallery_id" : (gallery.uid != Nil) ? gallery.uid : @"" }];

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
    [FRSTracker track:galleryUnliked parameters:@{ @"gallery_id" : (gallery.uid != Nil) ? gallery.uid : @"" }];

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

    [FRSTracker track:galleryReposted parameters:@{ @"gallery_id" : (gallery.uid != Nil) ? gallery.uid : @"" }];

    NSString *endpoint = [NSString stringWithFormat:repostGalleryEndpoint, gallery.uid];

    [[FRSAPIClient sharedClient] post:endpoint
                       withParameters:Nil
                           completion:^(id responseObject, NSError *error) {
                             completion(responseObject, error);

                             [gallery setValue:@(TRUE) forKey:@"reposted"];
                             [[self managedObjectContext] save:Nil];
                           }];
}

- (void)unrepostGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:unrepostGalleryEndpoint, gallery.uid];

    [FRSTracker track:galleryUnreposted parameters:@{ @"gallery_id" : (gallery.uid != Nil) ? gallery.uid : @"" }];

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
