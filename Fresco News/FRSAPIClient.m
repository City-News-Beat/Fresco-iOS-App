
//
//  FRSAPIClient.m
//  Fresco
//
//  Created by Daniel Sun on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSAPIClient.h"
#import "Fresco.h"
#import "FRSPost.h"
#import "FRSRequestSerializer.h"
#import "FRSAppDelegate.h"
#import "FRSOnboardingViewController.h"
#import "FRSTracker.h"
#import "FRSTabBarController.h"
#import "FRSAppDelegate.h"
#import "EndpointManager.h"
#import "FRSAuthManager.h"
#import "FRSUserManager.h"
#import "NSDate+ISO.h"

@implementation FRSAPIClient

+ (instancetype)sharedClient {
    static FRSAPIClient *client = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
      client = [[FRSAPIClient alloc] init];
    });

    return client;
}

- (void)handleError:(NSError *)error {
    switch (error.code / 100) {
    case 5:
        // server error
        break;
    case 4:
        // client error
        switch (error.code) {
        case 401:

            break;
        case 403:

            break;
        case 404:

            break;

        case 405:

            break;

        case 412:
            // installation token error or social taken error
            break;
        default:
            break;
        }
        break;

    case 3:
        // redirection
        break;

    //test
    case 2:
        // prolly not an error
        break;

    default:
        break;
    }
}

- (void)linkTwitter:(NSString *)token secret:(NSString *)secret completion:(FRSAPIDefaultCompletionBlock)completion {
    if (token && secret) {
        [self post:addSocialEndpoint
            withParameters:@{ @"platform" : @"twitter",
                              @"token" : token,
                              @"secret" : secret }
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
    } else {
        completion(Nil, [NSError errorWithDomain:@"com.fresconews.Fresco" code:400 userInfo:@{ @"message" : @"Incorrect Twitter credentials" }]);
    }
}

- (void)linkFacebook:(NSString *)token completion:(FRSAPIDefaultCompletionBlock)completion {
    if (token) {
        [self post:addSocialEndpoint
            withParameters:@{ @"platform" : @"facebook",
                              @"token" : token }
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
    } else {
        completion(Nil, [NSError errorWithDomain:@"com.fresconews.Fresco" code:400 userInfo:@{ @"message" : @"Incorrect Twitter credentials" }]);
    }
}

- (void)unlinkFacebook:(FRSAPIDefaultCompletionBlock)completion {
    [self post:deleteSocialEndpoint
        withParameters:@{ @"platform" : @"facebook" }
        completion:^(id responseObject, NSError *error) {
          completion(responseObject, error);
        }];
}

- (void)unlinkTwitter:(FRSAPIDefaultCompletionBlock)completion {
    [self post:deleteSocialEndpoint
        withParameters:@{ @"platform" : @"twitter" }
        completion:^(id responseObject, NSError *error) {
          completion(responseObject, error);
        }];
}

- (void)getNotificationsWithCompletion:(FRSAPIDefaultCompletionBlock)completion {

    [self get:notificationEndpoint
        withParameters:@{}
        completion:^(id responseObject, NSError *error) {
          completion(responseObject, error);
        }];
}

- (void)setPushNotificationWithBool:(BOOL)sendPush completion:(FRSAPIDefaultCompletionBlock)completion {
    NSDictionary *dict = @{ @"send_push" : [NSNumber numberWithBool:sendPush] };

    [self post:settingsUpdateEndpoint
        withParameters:@{ @"notify-user-dispatch-new-assignment" : dict }
        completion:^(id responseObject, NSError *error) {
          completion(responseObject, error);
        }];
}

- (void)getNotificationsWithLast:(nonnull NSString *)last completion:(FRSAPIDefaultCompletionBlock)completion {

    if (!last) {
        completion(Nil, [NSError errorWithDomain:@"com.fresconews.Fresco" code:400 userInfo:Nil]);
    }

    [self get:notificationEndpoint
        withParameters:@{ @"last" : last }
        completion:^(id responseObject, NSError *error) {
          completion(responseObject, error);
        }];
}

- (void)updateSettingsWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion {
    [self post:settingsUpdateEndpoint withParameters:digestion completion:completion];
}

- (void)disableAccountWithDigestion:(NSDictionary *)digestion completion:(FRSAPIDefaultCompletionBlock)completion {
    [self post:disableAccountEndpoint withParameters:digestion completion:completion];
}

// all the info needed for "social_links" field of registration/signin
- (NSDictionary *)socialDigestionWithTwitter:(TWTRSession *)twitterSession facebook:(FBSDKAccessToken *)facebookToken {
    // side note, twitter_handle is outside social links, needs to be handled outside this method
    NSMutableDictionary *socialDigestion = [[NSMutableDictionary alloc] init];

    if (twitterSession) {
        // add twitter to digestion
        if (twitterSession.authToken && twitterSession.authTokenSecret) {
            NSDictionary *twitterDigestion = @{ @"token" : twitterSession.authToken,
                                                @"secret" : twitterSession.authTokenSecret };
            [socialDigestion setObject:twitterDigestion forKey:@"twitter"];
        }
    }

    if (facebookToken) {
        // add facebook to digestion
        if (facebookToken.tokenString) {
            NSDictionary *facebookDigestion = @{ @"token" : facebookToken.tokenString };
            [socialDigestion setObject:facebookDigestion forKey:@"facebook"];
        }
    }

    return socialDigestion;
}

- (void)fetchGalleriesForUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:userFeed, user.uid];

    [self get:endpoint
        withParameters:Nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

/*
 Fetch assignments w/in radius of user location, calls generic method w/ parameters & endpoint
 */

- (void)getAssignmentsWithinRadius:(float)radius ofLocation:(NSArray *)location withCompletion:(FRSAPIDefaultCompletionBlock)completion {

    NSMutableDictionary *geoData = [[NSMutableDictionary alloc] init];
    [geoData setObject:@"Point" forKey:@"type"];
    [geoData setObject:location forKey:@"coordinates"];

    NSDictionary *params = @{

        @"geo" : geoData,
        @"radius" : @(radius),
    };

    [self get:assignmentsEndpoint
        withParameters:params
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (void)showErrorWithMessage:(NSString *)message onCancel:(FRSAPIBooleanCompletionBlock)onCancel onRetry:(FRSAPIBooleanCompletionBlock)onRetry {
}

- (void)getAssignmentsWithinRadius:(float)radius ofLocations:(NSArray *)location withCompletion:(FRSAPIDefaultCompletionBlock)completion {
    NSMutableDictionary *geoData = [[NSMutableDictionary alloc] init];
    [geoData setObject:@"MultiPoint" forKey:@"type"];

    NSMutableDictionary *coordinates = [[NSMutableDictionary alloc] init];

    int counter = 0;
    for (CLLocation *loc in location) {
        NSArray *coordinateLocation = @[ @(loc.coordinate.longitude), @(loc.coordinate.latitude) ];
        [coordinates setObject:coordinateLocation forKey:[NSNumber numberWithInt:counter]];
        counter++;
    }

    [geoData setObject:coordinates forKey:@"coordinates"];

    NSDictionary *params = @{
        @"geo" : geoData,
        @"radius" : @(radius)
    };

    [self get:assignmentsEndpoint
        withParameters:params
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

#pragma mark - Gallery Fetch

/*
 Fetch galleries w/ limit, calls generic method w/ parameters & endpoint
 */

- (void)fetchGalleriesWithLimit:(NSInteger)limit offsetGalleryID:(NSString *)offset completion:(void (^)(NSArray *galleries, NSError *error))completion {

    NSDictionary *params = @{

        @"limit" : [NSNumber numberWithInteger:limit],
        @"last" : (offset != Nil) ? offset : @"",
    };

    if (!offset) {
        params = @{
            @"limit" : [NSNumber numberWithInteger:limit],
        };
    }

    [self get:highlightsEndpoint
        withParameters:params
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (void)fetchLikesForGallery:(NSString *)galleryID limit:(NSNumber *)limit lastID:(NSString *)lastID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:likedGalleryEndpoint, galleryID];

    [self get:endpoint
        withParameters:@{ @"limit" : limit,
                          @"last" : lastID }
        completion:^(id responseObject, NSError *error) {
          completion(responseObject, error);
        }];
}

- (void)fetchRepostsForGallery:(NSString *)galleryID limit:(NSNumber *)limit lastID:(NSString *)lastID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:repostedGalleryEndpoint, galleryID];

    [self get:endpoint
        withParameters:@{ @"limit" : limit,
                          @"last" : lastID }
        completion:^(id responseObject, NSError *error) {
          completion(responseObject, error);
        }];
}

- (void)deleteComment:(NSString *)commentID fromGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {

    NSString *endpoint = [NSString stringWithFormat:deleteCommentEndpoint, gallery.uid];
    NSDictionary *params = @{ @"comment_id" : commentID };

    [self post:endpoint
        withParameters:params
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (void)fetchGalleriesInStory:(NSString *)storyID completion:(void (^)(NSArray *galleries, NSError *error))completion {

    NSString *endpoint = [NSString stringWithFormat:storyGalleriesEndpoint, storyID];

    [self get:endpoint
        withParameters:Nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (void)getRecentGalleriesFromLastGalleryID:(NSString *)galleryID completion:(void (^)(NSArray *galleries, NSError *error))completion {
}

- (void)fetchStoriesWithLimit:(NSInteger)limit lastStoryID:(NSString *)offsetID completion:(void (^)(NSArray *stories, NSError *error))completion {

    NSDictionary *params = @{
        @"limit" : [NSNumber numberWithInteger:limit],
        @"last" : (offsetID != Nil) ? offsetID : @""
    };

    if (!offsetID) {
        params = @{
            @"limit" : [NSNumber numberWithInteger:limit],
        };
    }

    [self get:storiesEndpoint
        withParameters:params
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (void)createPaymentWithToken:(nonnull NSString *)token completion:(FRSAPIDefaultCompletionBlock)completion {

    if (!token) {
        completion(Nil, Nil);
    }

    [self post:createPayment
        withParameters:@{ @"token" : token,
                          @"active" : @(TRUE) }
        completion:^(id responseObject, NSError *error) {
          completion(responseObject, error);
        }];
}

- (void)startLocator {
    [FRSLocator sharedLocator];
}

- (void)fetchFollowing:(void (^)(NSArray *galleries, NSError *error))completion {
    FRSUser *authenticatedUser = [[FRSUserManager sharedInstance] authenticatedUser];

    if (!authenticatedUser) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresconews.fresco" code:404 userInfo:@{ @"error" : @"no user u dingus" }]);
    }

    NSString *endpoint = [NSString stringWithFormat:followingFeed, authenticatedUser.uid];

    [self get:endpoint
        withParameters:Nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (void)fetchLikesFeedForUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:likeFeed, user.uid];
    [self get:endpoint
        withParameters:Nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (void)unlikeGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    [FRSTracker track:galleryUnliked parameters:@{ @"gallery_id" : (gallery.uid != Nil) ? gallery.uid : @"" }];

    NSString *endpoint = [NSString stringWithFormat:galleryUnlikeEndpoint, gallery.uid];
    [self post:endpoint
        withParameters:Nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
              [gallery setValue:@(TRUE) forKey:@"liked"];
            }];
}
- (void)unlikeStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:storyUnlikeEndpoint, story.uid];
    [self post:endpoint
        withParameters:Nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
              [story setValue:@(FALSE) forKey:@"liked"];
            }];
}

- (AFHTTPSessionManager *)managerWithFrescoConfigurations {

    if (!self.requestManager) {
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[EndpointManager sharedInstance].currentEndpoint.baseUrl]];
        self.requestManager = manager;
        self.requestManager.requestSerializer = [[FRSRequestSerializer alloc] init];
        [self.requestManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }

    [self reevaluateAuthorization];

    return self.requestManager;
}

- (void)createGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {

    NSDictionary *params = [gallery jsonObject];

    [self post:createGalleryEndpoint
        withParameters:params
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (void)addTwitter:(TWTRSession *)twitterSession completion:(FRSAPIDefaultCompletionBlock)completion {
    NSMutableDictionary *twitterDictionary = [[NSMutableDictionary alloc] init];
    [twitterDictionary setObject:@"Twitter" forKey:@"platform"];

    if (twitterSession.authToken && twitterSession.authTokenSecret) {
        [twitterDictionary setObject:twitterSession.authToken forKey:@"token"];
        [twitterDictionary setObject:twitterSession.authTokenSecret forKey:@"secret"];
    } else {
        completion(Nil, [NSError errorWithDomain:@"com.fresconews.Fresco" code:401 userInfo:Nil]);
        return;
    }

    [self post:addSocialEndpoint
        withParameters:twitterDictionary
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (void)getFollowersForUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:followersEndpoint, user.uid];

    [self get:endpoint
        withParameters:Nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}
- (void)addFacebook:(FBSDKAccessToken *)facebookToken completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *tokenString = facebookToken.tokenString;

    if (!tokenString) {
        completion(Nil, [NSError errorWithDomain:@"com.fresconews.Fresco" code:401 userInfo:Nil]);
        return;
    }

    NSDictionary *facebookDictionary = @{ @"platform" : @"Facebook",
                                          @"token" : tokenString };

    [self post:addSocialEndpoint
        withParameters:facebookDictionary
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

/*
 Keychain-Based interaction & authentication
 */

- (void)reevaluateAuthorization {
    if (![[FRSAuthManager sharedInstance] isAuthenticated]) {
        // set client token
        [self.requestManager.requestSerializer setValue:[self clientAuthorization] forHTTPHeaderField:@"Authorization"];
    } else { // set bearer token if we haven't already
        // set bearer client token
        NSString *currentBearerToken = [[FRSAuthManager sharedInstance] authenticationToken];
        if (currentBearerToken) {
            currentBearerToken = [NSString stringWithFormat:@"Bearer %@", currentBearerToken];

            [self.requestManager.requestSerializer setValue:currentBearerToken forHTTPHeaderField:@"Authorization"];
            [self startLocator];
        } else { // something went wrong here (maybe pass to error handler)
            [self.requestManager.requestSerializer setValue:[self clientAuthorization] forHTTPHeaderField:@"Authorization"];
        }
    }
    _managerAuthenticated = TRUE;
}

- (NSString *)clientAuthorization {
    return [NSString stringWithFormat:@"Basic %@", [EndpointManager sharedInstance].currentEndpoint.frescoClientId];
}

/*
 Generic HTTP methods for use within class
 */
- (void)get:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion {
    AFHTTPSessionManager *manager = [self managerWithFrescoConfigurations];
    
    [manager GET:endPoint
      parameters:parameters
        progress:^(NSProgress *_Nonnull downloadProgress) {
        }
         success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
             completion(responseObject, Nil);
         }
         failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
             completion(Nil, error);
             [self handleError:error];
         }];
}

- (void)post:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion {
    AFHTTPSessionManager *manager = [self managerWithFrescoConfigurations];
    
    [manager POST:endPoint
       parameters:parameters
         progress:^(NSProgress *_Nonnull downloadProgress) {
         }
          success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
              completion(responseObject, Nil);
          }
          failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
              completion(Nil, error);
              [self handleError:error];
          }];
}

- (void)postAvatar:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion {
    AFHTTPSessionManager *manager = [self managerWithFrescoConfigurations];
    
    [manager POST:endPoint
       parameters:parameters
constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
    NSString *paramNameForImage = @"avatar";
    [formData appendPartWithFileData:parameters[@"avatar"] name:paramNameForImage fileName:@"photo.jpg" mimeType:@"image/jpeg"];
}
         progress:^(NSProgress *_Nonnull uploadProgress) {
             
         }
          success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
              completion(responseObject, Nil);
          }
          failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
              completion(Nil, error);
              [self handleError:error];
          }];
}

- (void)uploadStateID:(NSString *)endPoint withParameters:(NSData *)parameters completion:(FRSAPIDefaultCompletionBlock)completion {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:setStateIDEndpoint]];
    manager.requestSerializer = [[FRSRequestSerializer alloc] init];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer = [[FRSJSONResponseSerializer alloc] init];
    NSString *auth = [NSString stringWithFormat:@"Bearer %@", [EndpointManager sharedInstance].currentEndpoint.stripeKey];
    
    [manager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
    
    [manager POST:endPoint
       parameters:nil
constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
    [formData appendPartWithFileData:parameters name:@"file" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
    [formData appendPartWithFormData:[@"identity_document" dataUsingEncoding:NSUTF8StringEncoding] name:@"purpose"];
}
         progress:^(NSProgress *_Nonnull uploadProgress) {
         }
          success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
              completion(responseObject, Nil);
          }
          failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
              completion(Nil, error);
              [self handleError:error];
          }];
}

- (void)updateTaxInfoWithFileID:(NSString *)fileID completion:(FRSAPIDefaultCompletionBlock)completion {
    [self post:updateTaxInfoEndpoint
withParameters:@{ @"stripe_document_token" : fileID }
    completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

/*
 One-off tools for use within class
 */

- (NSNumber *)fileSizeForURL:(NSURL *)url {
    NSNumber *fileSizeValue = nil;
    NSError *fileSizeError = nil;
    [url getResourceValue:&fileSizeValue
                   forKey:NSURLFileSizeKey
                    error:&fileSizeError];

    return fileSizeValue;
}

- (void)getPostWithID:(NSString *)post completion:(FRSAPIDefaultCompletionBlock)completion {

    NSString *endpoint = [NSString stringWithFormat:@"post/%@", post];

    [self get:endpoint
        withParameters:nil
            completion:^(id responseObject, NSError *error) {

              if (error) {
                  completion(responseObject, error);
                  return;
              }

              if ([responseObject objectForKey:@"id"] != Nil && ![[responseObject objectForKey:@"id"] isEqual:[NSNull null]]) {
                  completion(responseObject, error);
              }

              // shouldn't happen
              completion(responseObject, error);
            }];
}

- (void)getOutletWithID:(NSString *)outlet completion:(FRSAPIDefaultCompletionBlock)completion {

    NSString *endpoint = [NSString stringWithFormat:@"outlet/%@", outlet];

    [self get:endpoint
        withParameters:nil
            completion:^(id responseObject, NSError *error) {

              if (error) {
                  completion(responseObject, error);
                  return;
              }

              if ([responseObject objectForKey:@"id"] != Nil && ![[responseObject objectForKey:@"id"] isEqual:[NSNull null]]) {
                  completion(responseObject, error);
              }

              // shouldn't happen
              completion(responseObject, error);
            }];
}

- (void)getStoryWithUID:(NSString *)story completion:(FRSAPIDefaultCompletionBlock)completion {

    NSString *endpoint = [NSString stringWithFormat:@"story/%@", story];

    [self get:endpoint
        withParameters:nil
            completion:^(id responseObject, NSError *error) {
              if (error) {
                  completion(responseObject, error);
                  return;
              }

              if ([responseObject objectForKey:@"id"] != Nil && ![[responseObject objectForKey:@"id"] isEqual:[NSNull null]]) {
                  completion(responseObject, error);
              }

              // shouldn't happen
              completion(responseObject, error);
            }];
}

- (void)getGalleryWithUID:(NSString *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {

    NSString *endpoint = [NSString stringWithFormat:@"gallery/%@", gallery];

    [self get:endpoint
        withParameters:nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (void)getAssignmentWithUID:(NSString *)assignment completion:(FRSAPIDefaultCompletionBlock)completion {

    NSString *endpoint = [NSString stringWithFormat:@"assignment/%@", assignment];

    [self get:endpoint
        withParameters:nil
            completion:^(id responseObject, NSError *error) {
              if (error) {
                  completion(responseObject, error);
                  return;
              }

              if ([responseObject objectForKey:@"id"] != Nil && ![[responseObject objectForKey:@"id"] isEqual:[NSNull null]]) {
                  completion(responseObject, error);
              } else {
                  completion(nil, error);
              }
            }];
}

- (void)acceptAssignment:(NSString *)assignmentID completion:(FRSAPIDefaultCompletionBlock)completion {
    if ([self checkAuthAndPresentOnboard]) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresco.news" code:101 userInfo:Nil]);
        return;
    }

    NSString *endpoint = [NSString stringWithFormat:acceptAssignmentEndpoint, assignmentID];

    [self post:endpoint
        withParameters:nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (void)unacceptAssignment:(NSString *)assignmentID completion:(FRSAPIDefaultCompletionBlock)completion {
    if ([self checkAuthAndPresentOnboard]) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresco.news" code:101 userInfo:Nil]);
        return;
    }

    NSString *endpoint = [NSString stringWithFormat:unacceptAssignmentEndpoint, assignmentID];

    [self post:endpoint
        withParameters:nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (void)getAcceptedAssignmentWithCompletion:(FRSAPIDefaultCompletionBlock)completion {
    [self get:acceptedAssignmentEndpoint
        withParameters:nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (NSDate *)dateFromString:(NSString *)string {
    if (!self.dateFormatter) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        self.dateFormatter.timeZone = timeZone;
        self.dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    }

    return [self.dateFormatter dateFromString:string];
}

/* 
    Social interaction
*/
- (void)likeGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    if ([self checkAuthAndPresentOnboard]) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresco.news" code:101 userInfo:Nil]);
        return;
    }

    [FRSTracker track:galleryLiked parameters:@{ @"gallery_id" : (gallery.uid != Nil) ? gallery.uid : @"" }];

    NSString *endpoint = [NSString stringWithFormat:likeGalleryEndpoint, gallery.uid];
    [self post:endpoint
        withParameters:Nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
              [gallery setValue:@(TRUE) forKey:@"liked"];
              [[self managedObjectContext] save:Nil];
            }];
}

- (void)fetchNearbyUsersWithCompletion:(FRSAPIDefaultCompletionBlock)completion {
    [self get:nearbyUsersEndpoint
        withParameters:nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (void)searchWithQuery:(NSString *)query completion:(FRSAPIDefaultCompletionBlock)completion {
    if (!query) {
        // error out

        return;
    }

    NSDictionary *params = @{ @"q" : query,
                              @"stories" : @(TRUE),
                              @"galleries" : @(TRUE),
                              @"users" : @(TRUE),
                              @"limit" : @999 };

    [self get:searchEndpoint
        withParameters:params
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}
- (void)likeStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion {
    if ([self checkAuthAndPresentOnboard]) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresco.news" code:101 userInfo:Nil]);
        return;
    }

    NSString *endpoint = [NSString stringWithFormat:likeStoryEndpoint, story.uid];
    [self post:endpoint
        withParameters:Nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
              [story setValue:@(TRUE) forKey:@"liked"];
              [[self managedObjectContext] save:Nil];
            }];
}

- (void)repostGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {

    if ([self checkAuthAndPresentOnboard]) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresco.news" code:101 userInfo:Nil]);
        return;
    }

    if ([[gallery valueForKey:@"reposted"] boolValue]) {
        [self unrepostGallery:gallery completion:completion];
        return;
    }

    [FRSTracker track:galleryReposted parameters:@{ @"gallery_id" : (gallery.uid != Nil) ? gallery.uid : @"" }];

    NSString *endpoint = [NSString stringWithFormat:repostGalleryEndpoint, gallery.uid];

    [self post:endpoint
        withParameters:Nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);

              [gallery setValue:@(TRUE) forKey:@"reposted"];
              [[self managedObjectContext] save:Nil];
            }];
}
- (void)repostStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion {
    if ([self checkAuthAndPresentOnboard]) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresco.news" code:101 userInfo:Nil]);
        return;
    }

    if ([[story valueForKey:@"reposted"] boolValue]) {
        [self unrepostStory:story completion:completion];
        return;
    }

    NSString *endpoint = [NSString stringWithFormat:repostStoryEndpoint, story.uid];
    [self post:endpoint
        withParameters:Nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);

              [story setValue:@(TRUE) forKey:@"reposted"];
              [[self managedObjectContext] save:Nil];
            }];
}

- (void)unrepostGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:unrepostGalleryEndpoint, gallery.uid];

    [FRSTracker track:galleryUnreposted parameters:@{ @"gallery_id" : (gallery.uid != Nil) ? gallery.uid : @"" }];

    [self post:endpoint
        withParameters:Nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);

              [gallery setValue:@(FALSE) forKey:@"reposted"];

              [[self managedObjectContext] save:Nil];
            }];
}

- (void)unrepostStory:(FRSStory *)story completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:unrepostStoryEndpoint, story.uid];

    [self post:endpoint
        withParameters:Nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);

              [story setValue:@(FALSE) forKey:@"reposted"];

              [[self managedObjectContext] save:Nil];
            }];
}

- (void)followUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    if ([self checkAuthAndPresentOnboard]) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresco.news" code:101 userInfo:Nil]);
        return;
    }

    if ([user valueForKey:@"following"] && [[user valueForKey:@"following"] boolValue] == TRUE) {
        [self unfollowUser:user
                completion:^(id responseObject, NSError *error) {
                  completion(responseObject, error);
                }];
        return;
    }

    [self followUserID:user.uid
            completion:^(id responseObject, NSError *error) {
              [user setValue:@(TRUE) forKey:@"following"];
              [[self managedObjectContext] save:Nil];
              completion(responseObject, error);
            }];
}
- (void)unfollowUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    if ([self checkAuthAndPresentOnboard]) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresconews.news" code:101 userInfo:Nil]);
        return;
    }

    [self unfollowUserID:user.uid
              completion:^(id responseObject, NSError *error) {
                [user setValue:@(FALSE) forKey:@"following"];
                [[self managedObjectContext] save:Nil];
                completion(responseObject, error);
              }];
}

- (void)getFollowingForUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:followingEndpoint, user.uid];

    [self get:endpoint
        withParameters:Nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (void)getFollowersForUser:(FRSUser *)user last:(FRSUser *)lastUser completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:followersEndpoint, user.uid];
    endpoint = [NSString stringWithFormat:@"%@?last=%@", endpoint, lastUser.uid];

    [self get:endpoint
        withParameters:Nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (void)getFollowingForUser:(FRSUser *)user last:(FRSUser *)lastUser completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:followingEndpoint, user.uid];
    endpoint = [NSString stringWithFormat:@"%@?last=%@", endpoint, lastUser.uid];

    [self get:endpoint
        withParameters:Nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (void)followUserID:(NSString *)userID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:followUserEndpoint, userID];
    [self post:endpoint
        withParameters:Nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}
- (void)unfollowUserID:(NSString *)userID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:unfollowUserEndpoint, userID];
    [self post:endpoint
        withParameters:Nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (void)fetchCommentsForGallery:(FRSGallery *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    [self fetchCommentsForGalleryID:gallery.uid completion:completion];
}
- (void)fetchCommentsForGalleryID:(NSString *)galleryID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:commentsEndpoint, galleryID];
    [self get:endpoint
        withParameters:Nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (void)fetchPurchasesForGalleryID:(NSString *)galleryID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:purchasesEndpoint, galleryID];
    [self get:endpoint
        withParameters:Nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (void)fetchMoreComments:(FRSGallery *)gallery last:(NSString *)last completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:paginateComments, gallery.uid, last];

    [self get:endpoint
        withParameters:Nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (void)addComment:(NSString *)comment toGallery:(NSString *)gallery completion:(FRSAPIDefaultCompletionBlock)completion {
    //    if ([self checkAuthAndPresentOnboard]) {
    //        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresco.news" code:101 userInfo:Nil]);
    //        return;
    //    }

    [self addComment:comment toGalleryID:gallery completion:completion];
}

- (void)addComment:(NSString *)comment toGalleryID:(NSString *)galleryID completion:(FRSAPIDefaultCompletionBlock)completion {

    if ([self checkAuthAndPresentOnboard]) {
        completion(Nil, [[NSError alloc] initWithDomain:@"com.fresco.news" code:101 userInfo:Nil]);
        return;
    }

    NSString *endpoint = [NSString stringWithFormat:commentEndpoint, galleryID];
    NSDictionary *parameters = @{ @"comment" : comment };

    [self post:endpoint withParameters:parameters completion:completion];
}

/* serialization */

- (id)parsedObjectsFromAPIResponse:(id)response cache:(BOOL)cache {
    if ([[response class] isSubclassOfClass:[NSDictionary class]]) {
        NSManagedObjectContext *managedObjectContext = (cache) ? [self managedObjectContext] : Nil;
        NSMutableDictionary *responseObjects = [[NSMutableDictionary alloc] init];
        NSArray *keys = [response allKeys];

        for (NSString *key in keys) {
            id valueForKey = [self objectFromDictionary:[response objectForKey:key] context:managedObjectContext];

            if (valueForKey == [response objectForKey:key]) {
                return response; // non parse
            }

            [responseObjects setObject:valueForKey forKey:key];
        }

        if (cache) {
            NSError *saveError;
            [managedObjectContext save:&saveError];
        }

        return responseObjects;
    } else if ([[response class] isSubclassOfClass:[NSArray class]]) {
        NSMutableArray *responseObjects = [[NSMutableArray alloc] init];
        NSManagedObjectContext *managedObjectContext = (cache) ? [self managedObjectContext] : Nil;

        for (NSDictionary *responseObject in response) {
            id originalResponse = [self objectFromDictionary:responseObject context:managedObjectContext];

            if (originalResponse == responseObject) {
                return response;
            }

            [responseObjects addObject:[self objectFromDictionary:responseObject context:managedObjectContext]];
        }

        return responseObjects;
    } else {
    }

    return response;
}

- (id)objectFromDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)managedObjectContext {

    NSString *objectType = dictionary[@"object"];

    if ([objectType isEqualToString:galleryObjectType]) {
        NSEntityDescription *galleryEntity = [NSEntityDescription entityForName:@"FRSGallery" inManagedObjectContext:[self managedObjectContext]];

        FRSGallery *gallery = (FRSGallery *)[[NSManagedObject alloc] initWithEntity:galleryEntity insertIntoManagedObjectContext:nil];
        gallery.currentContext = [self managedObjectContext];
        [gallery configureWithDictionary:dictionary];
        return gallery;
    } else if ([objectType isEqualToString:storyObjectType]) {
        NSEntityDescription *storyEntity = [NSEntityDescription entityForName:@"FRSStory" inManagedObjectContext:[self managedObjectContext]];
        FRSStory *story = (FRSStory *)[[NSManagedObject alloc] initWithEntity:storyEntity insertIntoManagedObjectContext:nil];
        [story configureWithDictionary:dictionary];
        return story;
    }

    return dictionary; // not serializable
}

- (NSManagedObjectContext *)managedObjectContext {
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate managedObjectContext];
}

- (BOOL)checkAuthAndPresentOnboard {

    if (![[FRSAuthManager sharedInstance] isAuthenticated]) {

        id<FRSApp> appDelegate = (id<FRSApp>)[[UIApplication sharedApplication] delegate];
        FRSOnboardingViewController *onboardVC = [[FRSOnboardingViewController alloc] init];
        UINavigationController *navController = (UINavigationController *)appDelegate.window.rootViewController;

        if ([[navController class] isSubclassOfClass:[UINavigationController class]]) {
            [navController pushViewController:onboardVC animated:FALSE];
        } else {
            UITabBarController *tab = (UITabBarController *)navController;
            tab.navigationController.interactivePopGestureRecognizer.enabled = YES;
            tab.navigationController.interactivePopGestureRecognizer.delegate = nil;
            UINavigationController *onboardNav = [[UINavigationController alloc] init];
            [onboardNav pushViewController:onboardVC animated:NO];
            [tab presentViewController:onboardNav animated:YES completion:Nil];
        }

        return TRUE;
    }

    if ([[FRSUserManager sharedInstance] authenticatedUser].suspended) {
        [self checkSuspended];
        return TRUE;
    }

    return FALSE;
}

/// not ideal
#pragma mark - Smooch
- (void)presentSmooch {
    FRSUser *currentUser = [[FRSUserManager sharedInstance] authenticatedUser];
    if (currentUser.firstName) {
        [SKTUser currentUser].firstName = currentUser.firstName;
    }
    if (currentUser.email) {
        [SKTUser currentUser].email = currentUser.email;
    }
    if (currentUser.uid) {
        [[SKTUser currentUser] addProperties:@{ @"Fresco ID" : currentUser.uid }];
    }
    [Smooch show];
}

- (void)checkSuspended {

    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate reloadUser];

    if ([[FRSUserManager sharedInstance] authenticatedUser].suspended) {
        self.suspendedAlert = [[FRSAlertView alloc] initWithTitle:@"SUSPENDED" message:[NSString stringWithFormat:@"You’ve been suspended for inappropriate behavior. You will be unable to submit, repost, or comment on galleries for 14 days."] actionTitle:@"CONTACT SUPPORT" cancelTitle:@"OK" cancelTitleColor:[UIColor frescoBlueColor] delegate:self];
        [self.suspendedAlert show];
    }
}
- (void)didPressButtonAtIndex:(NSInteger)index {

    if (self.suspendedAlert) {
        switch (index) {
        case 0:
            [self presentSmooch];
            break;

        case 1:

            break;
        default:
            break;
        }
    }
}
/// not ideal

- (void)fetchAddressFromLocation:(CLLocation *)location completion:(FRSAPIDefaultCompletionBlock)completion {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    __block NSString *address;

    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                     if (placemarks && placemarks.count > 0) {
                         CLPlacemark *placemark = [placemarks objectAtIndex:0];

                         NSString *thoroughFare = @"";
                         if ([placemark thoroughfare] && [[placemark thoroughfare] length] > 0) {
                             thoroughFare = [[placemark thoroughfare] stringByAppendingString:@", "];

                             if ([placemark subThoroughfare]) {
                                 thoroughFare = [[[placemark subThoroughfare] stringByAppendingString:@" "] stringByAppendingString:thoroughFare];
                             }
                         }

                         address = [NSString stringWithFormat:@"%@%@, %@", thoroughFare, [placemark locality], [placemark administrativeArea]];
                         completion(address, Nil);
                     } else {
                         completion(@"No address found.", Nil);
                         [FRSTracker track:addressError parameters:@{ @"coordinates" : @[ @(location.coordinate.longitude), @(location.coordinate.latitude) ] }];
                     }

                   }];
}

// FILE DEALINGS
- (void)fetchFileSizeForVideo:(PHAsset *)video callback:(FRSAPISizeCompletionBlock)callback {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;

    [[PHImageManager defaultManager] requestAVAssetForVideo:video
                                                    options:options
                                              resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                                                if ([asset isKindOfClass:[AVURLAsset class]]) {
                                                    AVURLAsset *urlAsset = (AVURLAsset *)asset;

                                                    NSNumber *size;
                                                    NSError *fetchError;

                                                    [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:&fetchError];
                                                    callback([size integerValue], fetchError);
                                                }
                                              }];
}

- (void)fetchFileSizeForImage:(PHAsset *)image callback:(FRSAPISizeCompletionBlock)callback {
    [[PHImageManager defaultManager] requestImageDataForAsset:image
                                                      options:nil
                                                resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                                                  float imageSize = imageData.length;
                                                  callback([@(imageSize) integerValue], Nil);
                                                }];
}

- (NSString *)md5:(PHAsset *)asset {
    return @"";
}

- (NSMutableDictionary *)digestForAsset:(PHAsset *)asset callback:(FRSAPIDefaultCompletionBlock)callback {
    NSMutableDictionary *digest = [[NSMutableDictionary alloc] init];

    [self fetchAddressFromLocation:asset.location
                        completion:^(id responseObject, NSError *error) {

                          digest[@"address"] = responseObject;
                          digest[@"lat"] = @(asset.location.coordinate.latitude);
                          digest[@"lng"] = @(asset.location.coordinate.longitude);

                          digest[@"captured_at"] = [(NSDate *)asset.creationDate ISODateWithTimeZone];

                          if (asset.mediaType == PHAssetMediaTypeImage) {
                              digest[@"contentType"] = @"image/jpeg";
                              [self fetchFileSizeForImage:asset
                                                 callback:^(NSInteger size, NSError *err) {
                                                   digest[@"fileSize"] = @(size);
                                                   digest[@"chunkSize"] = @(size);
                                                   callback(digest, err);
                                                 }];
                          } else {
                              [self fetchFileSizeForVideo:asset
                                                 callback:^(NSInteger size, NSError *err) {
                                                   digest[@"fileSize"] = @(size);
                                                   digest[@"chunkSize"] = @(chunkSize * megabyteDefinition);
                                                   digest[@"contentType"] = @"video/mp4";
                                                   callback(digest, err);
                                                 }];
                          }
                        }];

    return digest;
}

- (void)completePost:(NSString *)postID params:(NSDictionary *)params completion:(FRSAPIDefaultCompletionBlock)completion {

    [self post:completePostEndpoint
        withParameters:params
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (void)fetchPayments:(FRSAPIDefaultCompletionBlock)completion {
    [self get:getPaymentsEndpoint
        withParameters:Nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (void)deletePayment:(NSString *)paymentID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:deletePaymentEndpoint, paymentID];

    [self post:endpoint
        withParameters:Nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (void)makePaymentActive:(NSString *)paymentID completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:makePaymentActiveEndpoint, paymentID];

    NSDictionary *params = @{ @"active" : @(1) };

    [self post:endpoint
        withParameters:params
            completion:^(id responseObject, NSError *error) {

              completion(responseObject, error);
            }];
}

- (void)getTermsWithCompletion:(FRSAPIDefaultCompletionBlock)completion {
    [self get:getTermsEndpoint withParameters:Nil completion:completion];
}
- (void)acceptTermsWithCompletion:(FRSAPIDefaultCompletionBlock)completion {
    [self post:acceptTermsEndpoint withParameters:Nil completion:completion];
}

- (void)blockUser:(NSString *)userID withCompletion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:blockUserEndpoint, userID];

    [self post:endpoint
        withParameters:nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}

- (void)unblockUser:(NSString *)userID withCompletion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *endpoint = [NSString stringWithFormat:unblockUserEndpoint, userID];

    [self post:endpoint
        withParameters:nil
            completion:^(id responseObject, NSError *error) {
              completion(responseObject, error);
            }];
}
- (void)reportUser:(NSString *)userID params:(NSDictionary *)params completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *format = @"user/%@/report";
    NSString *endpoint = [NSString stringWithFormat:format, userID];
    [self post:endpoint withParameters:params completion:completion];
}

- (void)reportGallery:(FRSGallery *)gallery params:(NSDictionary *)params completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *format = @"gallery/%@/report";
    NSString *endpoint = [NSString stringWithFormat:format, gallery.uid];
    [self post:endpoint withParameters:params completion:completion];
}

- (void)fetchBlockedUsers:(FRSAPIDefaultCompletionBlock)completion {
    [self get:@"user/blocked" withParameters:Nil completion:completion];
}

- (void)fetchSettings:(FRSAPIDefaultCompletionBlock)completion {
    [self get:settingsEndpoint withParameters:Nil completion:completion];
}
- (void)updateSettings:(NSDictionary *)params completion:(FRSAPIDefaultCompletionBlock)completion {
    [self post:updateSettingsEndpoint withParameters:params completion:completion];
}

@end
