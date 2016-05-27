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

typedef void(^FRSAPIDefaultCompletionBlock)(id responseObject, NSError *error);
typedef void(^FRSAPIBooleanCompletionBlock)(BOOL response, NSError *error);


@protocol FRSFileUploaderObjectContext <NSObject>
-(NSManagedObjectContext *)managedObjectContext; // emulate FRSAppDelegate methods without importing
-(void)registerForPushNotifications;
@end

@interface FRSAPIClient : NSObject
@property (nonatomic, retain) AFHTTPRequestOperationManager *requestManager;
@property BOOL managerAuthenticated;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
+(instancetype)sharedClient;

-(void)getAssignmentsWithinRadius:(float)radius ofLocation:(NSArray *)location withCompletion:(FRSAPIDefaultCompletionBlock)completion;
-(void)fetchStoriesWithLimit:(NSInteger)limit lastStoryID:(NSString *)offsetID completion:(void(^)(NSArray *stories, NSError *error))completion;
-(void)fetchGalleriesWithLimit:(NSInteger)limit offsetGalleryID:(NSString *)offset completion:(void(^)(NSArray *galleries, NSError *error))completion;

-(void)fetchFollowing:(void(^)(NSArray *galleries, NSError *error))completion;

-(void)fetchGalleriesForUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion;

-(void)fetchGalleriesInStory:(NSString *)storyID completion:(void(^)(NSArray *galleries, NSError *error))completion;

// generic auth-ed call
-(void)get:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion;
-(void)post:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion;

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

// check user
-(void)checkUser:(NSString *)user completion:(FRSAPIBooleanCompletionBlock)completion;
-(NSDate *)dateFromString:(NSString *)string;
-(void)acceptAssignment:(NSString *)assignmentID completion:(FRSAPIDefaultCompletionBlock)completion;
@end
