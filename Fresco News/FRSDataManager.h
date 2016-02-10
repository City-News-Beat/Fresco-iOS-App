//
//  FRSDataManager.h
//  Fresco
//
//  Created by Team Fresco on 2/2/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

@import Foundation;
@import CoreLocation;
@import Parse;

#import <AFNetworking/AFNetworking.h>
#import "FRSStory.h"
#import "FRSPost.h"
#import "FRSUser.h"

#import "FRSGallery.h"
//#import "FRSAssignment.h"
//
//#import "FRSNotification.h"

@interface FRSDataManager : AFHTTPSessionManager

/**
*  Current user in session
*/

@property (nonatomic, strong) FRSUser *currentUser;

/**
*  Current API Token
*/

@property (nonatomic, strong) NSString *frescoAPIToken;

/**
*  Tells us if notifications have been updated already
*/

@property (nonatomic, assign) BOOL updatedNotifications;

/**
*  Tells us if login is in process
*/

@property (nonatomic, assign) BOOL loggingIn;

/**
*  Tells us if login is in process
*/

@property (nonatomic, assign) BOOL tokenValidatedForSession;

/**
 *  Shared accessor for manager
 *
 *  @return Returns singleton instance of FRSDatamanger
 */

+ (FRSDataManager *)sharedManager;

/**
 *  Reachability checker
 *
 *  @return Current reachability state
 */

- (BOOL)connected;

- (NSString *)endpointForPath:(NSString *)endpoint;

#pragma mark - Users

/**
 *  Refreshes the current logged in user for their latest info
 *
 *  @param block Parse response block
 */
- (void)refreshUser:(PFBooleanResultBlock)block;

/**
 *  Logs the user out of the app, and resets associated user defaults
 */

- (void)logout;

/**
 *  Tells us if the current user has been loading from the DB
 *
 *  @return YES = is Loaded, NO = notLoaded
 */
- (BOOL)currentUserIsLoaded;

/**
 *  Tells us if the a user is logged into the app
 *
 *  @return BOOL repsresents login state
 */
- (BOOL)isLoggedIn;

/**
 *  Determines if the current user logged in is valid i.e. has a first & last name
 *
 *  @return BOOL repsresents valid state
 */
- (BOOL)currentUserValid;

/**
 *  Sets the current logged in user to the passed user id
 *
 *  @param frescoUserId  The user id to set the current user to
 *  @param responseBlock Success block
 */

- (void)setCurrentUser:(NSString *)frescoUserId withResponseBlock:(FRSAPISuccessBlock)responseBlock;

/**
 *  Runs updated on user object with passed params
 *
 *  @param inputParams   User paramaters to update
 *  @param imageData     Optional image data for the user avatar
 *  @param responseBlock Success block
 */

- (void)updateFrescoUserWithParams:(NSDictionary *)inputParams withImageData:(NSData *)imageData block:(FRSAPISuccessBlock)responseBlock;

/**
 *  Runs Parse sign up, and creates a User on Fresco backend
 *
 *  @param username Username
 *  @param email    Email to sign up with
 *  @param password Password to sign up with
 *  @param block    Result block
 */

- (void)signupUser:(NSString *)username email:(NSString *)email password:(NSString *)password block:(PFBooleanResultBlock)block;

/**
 *  Logs in user with needed params
 *
 *  @param username The username of the user
 *  @param password The password of the user
 *  @param block    User response block
 */

- (void)loginUser:(NSString *)username password:(NSString *)password block:(PFUserResultBlock)block;

- (void)loginViaFacebookWithBlock:(PFUserResultBlock)block;

- (void)loginViaTwitterWithBlock:(PFUserResultBlock)block;

- (void)disableFrescoUser:(FRSAPISuccessBlock)responseBlock;

//- (void)updateUserLocation:(NSDictionary *)inputParams block:(FRSAPISuccessBlock)responseBlock;

-(void)updateUserLocation:(NSDictionary *)inputParams completion:(void(^)(NSDictionary *response, NSError *error))completion;

#pragma mark - Galleries

- (void)getGalleries:(NSDictionary *)params shouldRefresh:(BOOL)refresh withResponseBlock:(FRSAPIResponseBlock)responseBlock;
- (void)getGalleriesForUser:(NSString *)userId offset:(NSNumber *)offset shouldRefresh:(BOOL)refresh withResponseBlock:(FRSAPIResponseBlock)responseBlock;
- (void)getGallery:(NSString *)galleryId withResponseBlock:(FRSAPIResponseBlock)responseBlock;
- (void)getGalleriesFromStory:(NSString *)storyId withOffset:(NSNumber *)offset responseBlock:(FRSAPIResponseBlock)responseBlock;
- (void)resolveGalleriesInList:(NSArray *)galleries withResponseBlock:(FRSAPIResponseBlock)responseBlock;

#pragma mark - Stories

- (void)getStory:(NSString *)storyId withResponseBlock:(FRSAPIResponseBlock)responseBlock;
- (void)getStoriesWithOffset:(NSNumber*)offset shouldRefresh:(BOOL)refresh withReponseBlock:(FRSAPIResponseBlock)responseBlock;

#pragma mark - Assignments

- (void)getAssignment:(NSString *)assignmentId withResponseBlock:(FRSAPIResponseBlock)responseBlock;
- (void)getAssignmentsWithinRadius:(float)radius ofLocation:(CLLocationCoordinate2D)coordinate withResponseBlock:(FRSAPIResponseBlock)responseBlock;
- (void)getClustersWithinLocation:(float)lat lon:(float)lon radius:(float)radius withResponseBlock:(FRSAPIResponseBlock)responseBlock;

#pragma mark - Notifications

- (void)getNotificationsForUser:(NSNumber*)offset withResponseBlock:(FRSAPIResponseBlock)responseBlock;
- (void)setNotificationSeen:(NSString *)notificationId withResponseBlock:(FRSAPIResponseBlock)responseBlock;

- (void)deleteNotification:(NSString *)notificationId withResponseBlock:(FRSAPIResponseBlock)responseBlock;

#pragma mark - Payments

/**
 *  Updates user payment info with passed params
 *
 *  @param params        Fields to update
 *  @param responseBlock API Response Block
 */

- (void)updateUserPaymentInfo:(NSDictionary *)params block:(FRSAPIResponseBlock)responseBlock;

/**
 *  Returns logged in user's payment info
 *
 *  @param responseBlock API Response Block
 */

- (void)getUserPaymentInfo:(FRSAPIResponseBlock)responseBlock;

#pragma mark - TOS

- (void)getTermsOfService:(BOOL)validate withResponseBlock:(FRSAPIResponseBlock)responseBlock;
- (void)agreeToTOS:(FRSAPISuccessBlock)successBlock;

@end
