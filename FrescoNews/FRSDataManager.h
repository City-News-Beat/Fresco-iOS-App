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
#import "FRSAssignment.h"

typedef void(^FRSAPIResponseBlock)(id responseObject, NSError *error);

typedef void(^FRSAPIArrayResponseBlock)(NSArray *responseObject, NSError *error);

@interface FRSDataManager : AFHTTPSessionManager

@property (nonatomic, strong) FRSUser *currentUser;

+ (FRSDataManager *)sharedManager;

/*
** User
*/

- (void)loginWithUsername:(NSString *)username password:(NSString *)password responseBlock:(FRSAPIResponseBlock)responseBlock;

- (void)logout;

/*
** Galleries
*/

# warning for video
- (void)getHomeDataWithResponseBlock:(NSNumber*)offset responseBlock:(FRSAPIResponseBlock)responseBlock;

- (void)getGallery:(NSString *)galleryId WithResponseBlock:(FRSAPIResponseBlock)responseBlock;

- (void)getStoriesWithResponseBlock:(FRSAPIResponseBlock)responseBlock;

- (void)getGalleriesWithResponseBlock:(FRSAPIResponseBlock)responseBlock;

/*
** Assignments
*/

- (void)getAssignment:(NSString *)assignmentId WithResponseBlock:(FRSAPIResponseBlock)responseBlock;

- (void)getAssignmentsWithinLocation:(float)lat lon:(float)lon radius:(float)radius WithResponseBlock:(FRSAPIResponseBlock)responseBlock;

@end
