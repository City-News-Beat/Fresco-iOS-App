//
//  FRSDataManager.h
//  Fresco
//
//  Created by Team Fresco on 2/2/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

@import Foundation;
@import CoreLocation;

#import <AFNetworking/AFNetworking.h>
@import Parse;
#import "FRSStory.h"
#import "FRSPost.h"
#import "FRSUser.h"
#import "FRSTag.h"
#import "FRSGallery.h"
#import "FRSAssignment.h"
#import "FRSCluster.h"
#import "FRSNotification.h"

typedef void(^FRSAPIResponseBlock)(id responseObject, NSError *error);
typedef void(^FRSAPISuccessBlock)(BOOL sucess, NSError *error);
typedef void(^FRSAPIArrayResponseBlock)(NSArray *responseObject, NSError *error);

@interface FRSDataManager : AFHTTPSessionManager

@property (nonatomic, strong) FRSUser *currentUser;

@property (nonatomic, strong) NSString *frescoAPIToken;

/*
** Tells us if notifications have been updated already
*/

@property (nonatomic, assign) BOOL updatedNotifications;

/*
** Tells us if login is in process
*/

@property (nonatomic, assign) BOOL loggingIn;

/*
** Tells us if login is in process
*/

@property (nonatomic, assign) BOOL tokenValidatedForSession;

+ (FRSDataManager *)sharedManager;

/*
** Reachability checker
*/

- (BOOL)connected;

- (NSString *)endpointForPath:(NSString *)endpoint;

#pragma mark - Users

- (void)refreshUser:(PFBooleanResultBlock)block;
- (void)logout;
- (BOOL)currentUserIsLoaded;
- (BOOL)isLoggedIn;
- (BOOL)currentUserValid;
- (void)setCurrentUser:(NSString *)frescoUserId withResponseBlock:(FRSAPISuccessBlock)responseBlock;
- (void)updateFrescoUserWithParams:(NSDictionary *)inputParams withImageData:(NSData *)imageData block:(FRSAPISuccessBlock)responseBlock;
- (void)signupUser:(NSString *)username email:(NSString *)email password:(NSString *)password block:(PFBooleanResultBlock)block;
- (void)loginUser:(NSString *)username password:(NSString *)password block:(PFUserResultBlock)block;
- (void)loginViaFacebookWithBlock:(PFUserResultBlock)block;
- (void)loginViaTwitterWithBlock:(PFUserResultBlock)block;
- (void)disableFrescoUser:(FRSAPISuccessBlock)responseBlock;

#pragma mark - Galleries

- (void)getGalleries:(NSDictionary *)params shouldRefresh:(BOOL)refresh withResponseBlock:(FRSAPIResponseBlock)responseBlock;
- (void)getGalleriesForUser:(NSString *)userId offset:(NSNumber *)offset shouldRefresh:(BOOL)refresh withResponseBlock:(FRSAPIResponseBlock)responseBlock;
- (void)getGallery:(NSString *)galleryId WithResponseBlock:(FRSAPIResponseBlock)responseBlock;
- (void)getGalleriesFromIds:(NSArray *)ids responseBlock:(FRSAPIResponseBlock)responseBlock;
- (void)getGalleriesFromStory:(NSString *)storyId withOffset:(NSNumber *)offset responseBlock:(FRSAPIResponseBlock)responseBlock;
- (void)resetDraftGalleryPost;

#pragma mark - Stories

- (void)getStory:(NSString *)storyId withResponseBlock:(FRSAPIResponseBlock)responseBlock;
- (void)getStoriesWithResponseBlock:(NSNumber*)offset shouldRefresh:(BOOL)invalidate withReponseBlock:(FRSAPIResponseBlock)responseBlock;

#pragma mark - Assignments

- (void)getAssignment:(NSString *)assignmentId withResponseBlock:(FRSAPIResponseBlock)responseBlock;
- (void)getAssignmentsWithinRadius:(float)radius ofLocation:(CLLocationCoordinate2D)coordinate withResponseBlock:(FRSAPIResponseBlock)responseBlock;
- (void)getClustersWithinLocation:(float)lat lon:(float)lon radius:(float)radius withResponseBlock:(FRSAPIResponseBlock)responseBlock;

#pragma mark - Notifications

- (void)getNotificationsForUser:(NSNumber*)offset withResponseBlock:(FRSAPIResponseBlock)responseBlock;
- (void)setNotificationSeen:(NSString *)notificationId withResponseBlock:(FRSAPIResponseBlock)responseBlock;

- (void)deleteNotification:(NSString *)notificationId withResponseBlock:(FRSAPIResponseBlock)responseBlock;

#pragma mark - Other

- (void)updateUserLocation:(NSDictionary *)params block:(FRSAPIResponseBlock)responseBlock;
- (void)getTermsOfService:(FRSAPIResponseBlock)responseBlock;

@end
