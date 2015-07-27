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

#pragma mark - Users

- (void)refreshUser:(PFBooleanResultBlock)block;
- (void)logout;
- (BOOL)isLoggedIn;
- (BOOL)currentUserValid;
- (void)setCurrentUser:(NSString *)frescoUserId withResponseBlock:(FRSAPISuccessBlock)responseBlock;
- (void)updateFrescoUserWithParams:(NSDictionary *)inputParams withImageData:(NSData *)imageData block:(FRSAPIResponseBlock)responseBlock;
- (void)signupUser:(NSString *)username email:(NSString *)email password:(NSString *)password block:(PFBooleanResultBlock)block;
- (void)loginUser:(NSString *)username password:(NSString *)password block:(PFUserResultBlock)block;
- (void)loginViaFacebookWithBlock:(PFUserResultBlock)block;
- (void)loginViaTwitterWithBlock:(PFUserResultBlock)block;

#pragma mark - Galleries

- (void)getHomeDataWithResponseBlock:(NSNumber*)offset responseBlock:(FRSAPIResponseBlock)responseBlock;
- (void)getGalleriesForUser:(NSString *)userId offset:(NSNumber *)offset WithResponseBlock:(FRSAPIResponseBlock)responseBlock;
- (void)getGallery:(NSString *)galleryId WithResponseBlock:(FRSAPIResponseBlock)responseBlock;
- (void)getGalleriesWithResponseBlock:(FRSAPIResponseBlock)responseBlock;
- (void)getGalleriesFromIds:(NSArray *)ids responseBlock:(FRSAPIResponseBlock)responseBlock;

#pragma mark - Stories

- (void)getStory:(NSString *)storyId withResponseBlock:(FRSAPIResponseBlock)responseBlock;
- (void)getStoriesWithResponseBlock:(NSNumber*)offset  withReponseBlock:(FRSAPIResponseBlock)responseBlock;

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
