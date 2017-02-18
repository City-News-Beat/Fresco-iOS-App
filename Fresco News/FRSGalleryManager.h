//
//  FRSGalleryManager.h
//  Fresco
//
//  Created by User on 1/29/17.
//  Copyright © 2017 Fresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRSBaseManager.h"

@interface FRSGalleryManager : FRSBaseManager

+ (instancetype)sharedInstance;


/**
 Creates a new gallery with provided dictionary

 @param galleryDict Parameters of gallery of being created
 @param completion Completion handler
 */
- (void)createGallery:(NSDictionary *)galleryDict completion:(FRSAPIDefaultCompletionBlock)completion;


/**
 Creates a new gallery that is being submitted

 @param params Parameters of the gallery being created
 @param assets Assets to create with
 @param completion Completion handler
 */
- (void)createGalleryWithParams:(NSDictionary*)params andAssets:(NSArray *)assets completion:(FRSAPIDefaultCompletionBlock)completion;


- (void)getGalleryWithUID:(NSString *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)fetchGalleriesWithLimit:(NSInteger)limit offsetGalleryID:(NSString *)offset completion:(void (^)(NSArray *galleries, NSError *error))completion;
- (void)fetchRepostsForGallery:(NSString *)galleryID limit:(NSNumber *)limit lastID:(NSString *)lastID completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)fetchLikesForGallery:(NSString *)galleryID limit:(NSNumber *)limit lastID:(NSString *)lastID completion:(FRSAPIDefaultCompletionBlock)completion;

- (void)likeGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)unlikeGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)repostGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)unrepostGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;

- (void)fetchCommentsForGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)fetchCommentsForGalleryID:(NSString *)galleryID completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)fetchMoreComments:(FRSGallery *)gallery last:(NSString *)last completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)addComment:(NSString *)comment toGallery:(NSString *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)deleteComment:(NSString *)commentID fromGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;

- (void)fetchPurchasesForGalleryID:(NSString *)galleryID completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)getOutletWithID:(NSString *)outlet completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)getPostWithID:(NSString *)post completion:(FRSAPIDefaultCompletionBlock)completion;

@end
