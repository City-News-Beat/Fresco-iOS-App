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


typedef void(^FRSAPIDefaultCompletionBlock)(id responseObject, NSError *error);

@interface FRSAPIClient : NSObject

+(instancetype)sharedClient;

-(void)getAssignmentsWithinRadius:(float)radius ofLocation:(NSArray *)location withCompletion:(FRSAPIDefaultCompletionBlock)completion;
-(void)fetchStoriesWithLimit:(NSInteger)limit lastStoryID:(NSInteger)offsetID completion:(void(^)(NSArray *stories, NSError *error))completion;
-(void)fetchGalleriesWithLimit:(NSInteger)limit offsetGalleryID:(NSInteger)offset completion:(void(^)(NSArray *galleries, NSError *error))completion;

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

-(void)pingLocation:(NSDictionary *)location completion:(FRSAPIDefaultCompletionBlock)completion;

-(BOOL)isAuthenticated;

-(void)createGalleryWithPosts:(NSArray *)posts completion:(FRSAPIDefaultCompletionBlock)completion;
@end
