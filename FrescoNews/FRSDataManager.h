//
//  FRSDataManager.h
//  Fresco
//
//  Created by Team Fresco on 2/2/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

@import Foundation;

#import <AFNetworking/AFNetworking.h>
#import "FRSStory.h"
#import "FRSPost.h"
#import "FRSUser.h"
#import "FRSTag.h"
#import "FRSGallery.h"

typedef void(^FRSAPIResponseBlock)(id responseObject, NSError *error);

typedef void(^FRSAPIArrayResponseBlock)(NSArray *responseObject, NSError *error);

@interface FRSDataManager : AFHTTPSessionManager

@property (nonatomic, strong) FRSUser *currentUser;

+ (FRSDataManager *)sharedManager;

- (void)currentUserFromParseUser;

- (void)logout;

- (void)getPostsWithTags:(NSArray *)tags limit:(NSNumber *)limit responseBlock:(FRSAPIArrayResponseBlock)responseBlock;

- (void)getPostsWithTag:(FRSTag *)tag limit:(NSNumber *)limit responseBlock:(FRSAPIArrayResponseBlock)responseBlock;

- (void)getPostsAfterId:(NSNumber *)lastId responseBlock:(FRSAPIArrayResponseBlock)responseBlock;

- (void)getPostsWithId:(NSNumber *)postId responseBlock:(FRSAPIResponseBlock)responseBlock;

- (void)getTagsWithResponseBlock:(FRSAPIResponseBlock)responseBlock;

- (void)getHomeDataWithResponseBlock:(NSNumber*)offset responseBlock:(FRSAPIResponseBlock)responseBlock;

- (void)getStoriesWithResponseBlock:(FRSAPIResponseBlock)responseBlock;

- (void)getGalleriesWithResponseBlock:(FRSAPIResponseBlock)responseBlock;

@end
