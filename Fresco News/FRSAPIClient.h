//
//  FRSAPIClient.h
//  Fresco
//
//  Created by Daniel Sun on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSAppDelegate.h"
#import "FRSLocator.h"
#import "FRSUser.h"
#import "FRSSocial.h"
#import "FRSJSONResponseSerializer.h"
#import <AFNetworking/AFNetworking.h>
#import "SSKeychain.h"
#import <Photos/Photos.h>
#import <Mixpanel/Mixpanel.h>

typedef void(^FRSAPIDefaultCompletionBlock)(id responseObject, NSError *error);
typedef void(^FRSAPIBooleanCompletionBlock)(BOOL response, NSError *error);
typedef void(^FRSAPISizeCompletionBlock)(NSInteger size, NSError *error);

@protocol FRSApp
-(UITabBarController *)tabBar;
@end

@protocol FRSFileUploaderObjectContext <NSObject>
-(NSManagedObjectContext *)managedObjectContext; // emulate FRSAppDelegate methods without importing
-(void)registerForPushNotifications;
@end

@interface FRSAPIClient : NSObject
@property (nonatomic, retain) AFHTTPRequestOperationManager *requestManager;
@property BOOL managerAuthenticated;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
+(instancetype)sharedClient;
-(NSManagedObjectContext *)managedObjectContext;
-(void)getAssignmentsWithinRadius:(float)radius ofLocation:(NSArray *)location withCompletion:(FRSAPIDefaultCompletionBlock)completion;
-(void)fetchStoriesWithLimit:(NSInteger)limit lastStoryID:(NSString *)offsetID completion:(void(^)(NSArray *stories, NSError *error))completion;
-(void)fetchGalleriesWithLimit:(NSInteger)limit offsetGalleryID:(NSString *)offset completion:(void(^)(NSArray *galleries, NSError *error))completion;
-(void)fetchFollowing:(void(^)(NSArray *galleries, NSError *error))completion;
-(void)fetchGalleriesForUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)fetchGalleriesInStory:(NSString *)storyID completion:(void(^)(NSArray *galleries, NSError *error))completion;
-(void)acceptAssignment:(NSString *)assignmentID completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)fetchMoreComments:(FRSGallery *)gallery last:(NSString *)last completion:(FRSAPIDefaultCompletionBlock)completion;
// notifications
-(void)getNotificationsWithCompletion:(FRSAPIDefaultCompletionBlock)completion;

-(void)addComment:(NSString *)comment toGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;
// generic auth-ed call
-(void)get:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)post:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion;


-(void)deleteComment:(NSString *)commentID fromGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;

-(void)disconnectPlatform:(NSString *)platform completion:(FRSAPIDefaultCompletionBlock)completion;

// authentication
-(void)signIn:(NSString *)user password:(NSString *)password completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)signInWithTwitter:(TWTRSession *)session completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)signInWithFacebook:(FBSDKAccessToken *)token completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)updateUserWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion;
//registration
-(void)registerWithUserDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion; // leaves burdon of constructing dict obj to sender (will have method for that)
-(void)pingLocation:(NSDictionary *)location completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)updateLocalUser;
-(BOOL)isAuthenticated;
-(void)createGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;
-(NSString *)authenticationToken; // current token, assuming 1 user support
-(NSDictionary *)socialDigestionWithTwitter:(TWTRSession *)twitterSession facebook:(FBSDKAccessToken *)facebookToken; // current social links, formatted for transmission to server
-(FRSUser *)authenticatedUser;
-(NSDictionary *)currentInstallation;
-(NSNumber *)fileSizeForURL:(NSURL *)url;
// social
-(void)addTwitter:(TWTRSession *)twitterSession completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)addFacebook:(FBSDKAccessToken *)facebookToken completion:(FRSAPIDefaultCompletionBlock)completion;

-(void)checkEmail:(NSString *)email completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)checkUsername:(NSString *)username completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)refreshCurrentUser:(FRSAPIDefaultCompletionBlock)completion;

-(void)getGalleryWithUID:(NSString *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)getStoryWithUID:(NSString *)user completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)getAssignmentWithUID:(NSString *)assignment completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)getOutletWithID:(NSString *)outlet completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)getPostWithID:(NSString *)post completion:(FRSAPIDefaultCompletionBlock)completion;

// check user
-(void)getUserWithUID:(NSString *)user completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)checkUser:(NSString *)user completion:(FRSAPIBooleanCompletionBlock)completion;
-(NSDate *)dateFromString:(NSString *)string;

-(void)likeGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)likeStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion;

-(void)unlikeGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)unlikeStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion;

-(void)repostGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)repostStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion;

-(void)followUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)unfollowUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion;

-(void)followUserID:(NSString *)userID completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)unfollowUserID:(NSString *)userID completion:(FRSAPIDefaultCompletionBlock)completion;

-(void)fetchCommentsForGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)fetchCommentsForGalleryID:(NSString *)galleryID completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)getFollowersForUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)getFollowingForUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion;
-(NSArray *)parsedObjectsFromAPIResponse:(NSArray *)response cache:(BOOL)cache;

-(BOOL)checkAuthAndPresentOnboard;
-(void)fetchLikesFeedForUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)fetchAddressFromLocation:(CLLocation *)location completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)completePost:(NSString *)postID params:(NSDictionary *)params completion:(FRSAPIDefaultCompletionBlock)completion;

-(void)updateSettingsWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)disableAccountWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion;

// search
-(void)searchWithQuery:(NSString *)query completion:(FRSAPIDefaultCompletionBlock)completion;

-(void)createPaymentWithToken:(NSString *)token completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)fetchPayments:(FRSAPIDefaultCompletionBlock)completion;
-(void)deletePayment:(NSString *)paymentID completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)makePaymentActive:(NSString *)paymentID completion:(FRSAPIDefaultCompletionBlock)completion;

// file
-(void)postAvatar:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)fetchFileSizeForVideo:(PHAsset *)video callback:(FRSAPISizeCompletionBlock)callback;
-(NSString *)md5:(PHAsset *)asset;
-(NSMutableDictionary *)digestForAsset:(PHAsset *)asset callback:(FRSAPIDefaultCompletionBlock)callback;
-(void)getAssignmentsWithinRadius:(float)radius ofLocations:(NSArray *)location withCompletion:(FRSAPIDefaultCompletionBlock)completion;
@end
