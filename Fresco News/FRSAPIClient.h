//
//  FRSAPIClient.h
//  Fresco
//
//  Created by Daniel Sun on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSLocator.h"
#import "FRSUser.h"
#import "FRSSocial.h"
#import "FRSJSONResponseSerializer.h"
#import "AFNetworking.h"
#import "SAMKeychain.h"
#import <Photos/Photos.h>
#import <Mixpanel/Mixpanel.h>
#import "FRSAlertView.h"
#import "UIColor+Fresco.h"

typedef void (^FRSAPIDefaultCompletionBlock)(id responseObject, NSError *error);
typedef void (^FRSAPIBooleanCompletionBlock)(BOOL response, NSError *error);
typedef void (^FRSAPISizeCompletionBlock)(NSInteger size, NSError *error);

@protocol FRSApp
- (UITabBarController *)tabBar;
@property (nonatomic, retain) UIWindow *window;
@end

@protocol FRSFileUploaderObjectContext <NSObject>
- (NSManagedObjectContext *)managedObjectContext; // emulate FRSAppDelegate methods without importing
- (void)registerForPushNotifications;
@end

@interface FRSAPIClient : NSObject <FRSAlertViewDelegate>

@property (nonatomic, retain) AFHTTPSessionManager *requestManager;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;



+ (instancetype)sharedClient;
- (NSManagedObjectContext *)managedObjectContext;

- (void)fetchGalleriesWithLimit:(NSInteger)limit offsetGalleryID:(NSString *)offset completion:(void (^)(NSArray *galleries, NSError *error))completion;


- (void)fetchMoreComments:(FRSGallery *)gallery last:(NSString *)last completion:(FRSAPIDefaultCompletionBlock)completion;

- (void)fetchRepostsForGallery:(NSString *)galleryID limit:(NSNumber *)limit lastID:(NSString *)lastID completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)fetchLikesForGallery:(NSString *)galleryID limit:(NSNumber *)limit lastID:(NSString *)lastID completion:(FRSAPIDefaultCompletionBlock)completion;

// notifications
- (void)getNotificationsWithCompletion:(FRSAPIDefaultCompletionBlock)completion;
- (void)getNotificationsWithLast:(NSString *)last completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)setPushNotificationWithBool:(BOOL)sendPush completion:(FRSAPIDefaultCompletionBlock)completion;

- (void)updateLegacyUserWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion;

- (void)addComment:(NSString *)comment toGallery:(NSString *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;
// generic auth-ed call
- (void)get:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)post:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)delete:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)postAvatar:(NSString *)endPoint withParameters:(NSDictionary *)parameters withData:(NSData *)data withName:(NSString *)name withFileName:(NSString *)fileName completion:(FRSAPIDefaultCompletionBlock)completion;

- (void)deleteComment:(NSString *)commentID fromGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;

//registration

- (void)createGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;

- (NSNumber *)fileSizeForURL:(NSURL *)url;

- (void)getGalleryWithUID:(NSString *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;

- (void)getOutletWithID:(NSString *)outlet completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)getPostWithID:(NSString *)post completion:(FRSAPIDefaultCompletionBlock)completion;

// check user
- (NSDate *)dateFromString:(NSString *)string;

- (void)likeGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;


- (void)unlikeGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;


- (void)repostGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)unrepostGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;




- (void)fetchPurchasesForGalleryID:(NSString *)galleryID completion:(FRSAPIDefaultCompletionBlock)completion;

- (void)fetchCommentsForGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)fetchCommentsForGalleryID:(NSString *)galleryID completion:(FRSAPIDefaultCompletionBlock)completion;
- (NSArray *)parsedObjectsFromAPIResponse:(NSArray *)response cache:(BOOL)cache;


- (void)fetchAddressFromLocation:(CLLocation *)location completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)completePost:(NSString *)postID params:(NSDictionary *)params completion:(FRSAPIDefaultCompletionBlock)completion;

- (void)updateSettingsWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)disableAccountWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion;

// search
- (void)searchWithQuery:(NSString *)query completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)fetchNearbyUsersWithCompletion:(FRSAPIDefaultCompletionBlock)completion;

- (void)createPaymentWithToken:(NSString *)token completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)fetchPayments:(FRSAPIDefaultCompletionBlock)completion;
- (void)deletePayment:(NSString *)paymentID completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)makePaymentActive:(NSString *)paymentID completion:(FRSAPIDefaultCompletionBlock)completion;

// file
- (void)uploadStateID:(NSString *)endPoint withParameters:(NSData *)parameters completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)updateTaxInfoWithFileID:(NSString *)fileID completion:(FRSAPIDefaultCompletionBlock)completion;
- (void)fetchFileSizeForVideo:(PHAsset *)video callback:(FRSAPISizeCompletionBlock)callback;
- (NSString *)md5:(PHAsset *)asset;
- (NSMutableDictionary *)digestForAsset:(PHAsset *)asset callback:(FRSAPIDefaultCompletionBlock)callback;


// terms
- (void)getTermsWithCompletion:(FRSAPIDefaultCompletionBlock)completion;
- (void)acceptTermsWithCompletion:(FRSAPIDefaultCompletionBlock)completion;

- (void)fetchSettings:(FRSAPIDefaultCompletionBlock)completion;
- (void)updateSettings:(NSDictionary *)params completion:(FRSAPIDefaultCompletionBlock)completion;

- (AFHTTPSessionManager *)managerWithFrescoConfigurations:(NSString *)endpoint withRequestType:(NSString *)requestType;

@end
