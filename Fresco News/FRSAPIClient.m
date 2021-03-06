//
//  FRSAPIClient.m
//  Fresco
//
//  Created by Daniel Sun on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSAPIClient.h"
#import "FRSPost.h"
#import "FRSRequestSerializer.h"
#import "FRSOnboardingViewController.h"
#import "FRSTabBarController.h"
#import "Fresco.h"
#import "FRSRequestSerializer.h"
#import "FRSAppDelegate.h"
#import "FRSTracker.h"
#import "FRSAppDelegate.h"
#import "EndpointManager.h"
#import "FRSAuthManager.h"
#import "FRSSessionManager.h"
#import "FRSSessionManager.h"
#import "NSDate+ISO.h"
#import "FRSGallery.h"
#import "FRSStory.h"
#import "NSError+Fresco.h"

@implementation FRSAPIClient

+ (instancetype)sharedClient {
    static FRSAPIClient *client = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        client = [[FRSAPIClient alloc] init];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    });
    
    return client;
}

- (AFHTTPSessionManager *)managerWithFrescoConfigurations:(NSString *)endpoint withRequestType:(NSString *)requestType{
    if (!self.requestManager) {
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]
                                         initWithBaseURL:[NSURL URLWithString:[EndpointManager sharedInstance].currentEndpoint.baseUrl]];
        self.requestManager = manager;
        self.requestManager.requestSerializer = [[FRSRequestSerializer alloc] init];
//        [self.requestManager.requestSerializer setTimeoutInterval:20.0];
        [self.requestManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }

    [self reevaluateAuthorization:endpoint withRequestType:requestType];

    return self.requestManager;
}

#pragma mark - Authorizaiton headers

/**
  Keychain-Based interaction & authentication

 @param endpoint Endpoint the request is being made to
 @param requestType Request type e.g. "POST", "DELETE", "GET"
 */
- (void)reevaluateAuthorization:(NSString *)endpoint withRequestType:(NSString *)requestType {
    if ([self shouldSendUserToken:endpoint withRequestType:requestType]) {
        [self.requestManager.requestSerializer setValue:[self userAuthorization] forHTTPHeaderField:@"Authorization"];
        self.requestAuth = FRSUserAuth;
    } else if ([self shouldSendClient:endpoint withRequestType:requestType]) {
        [self.requestManager.requestSerializer setValue:[self clientAuthorization] forHTTPHeaderField:@"Authorization"];
        self.requestAuth = FRSClientAuth;
    } else {
        //Generate credentials if needed
        [[FRSSessionManager sharedInstance] generateClientCredentials];
        //Fallback to basic auth
        [self.requestManager.requestSerializer setValue:[self basicAuthorization] forHTTPHeaderField:@"Authorization"];
        self.requestAuth = FRSBasicAuth;
    }
}


/**
 Lets us know if we need a user token to be sent
 
 @return Authorization header with user-level authorization
 */
- (BOOL)shouldSendUserToken:(NSString *)endpoint withRequestType:(NSString *)requestType {
    //If we're authenticated && we don't need to send basic auth
    return (
            [[FRSAuthManager sharedInstance] isAuthenticated] &&
            ![self shouldSendBasic:endpoint withRequestType:requestType]
            );
}

/**
 Lets us know if we need a client token to be sent
 
 @return Authorization header with client-level authorization
 */
- (BOOL)shouldSendClient:(NSString *)endpoint withRequestType:(NSString *)requestType {
    NSString *clientToken = [[FRSSessionManager sharedInstance] bearerForToken:kClientToken];
    
    //Check if we don't need to send basic && we're not authenticated && we actually have a client token to use
    return (
            ![self shouldSendBasic:endpoint withRequestType:requestType] &&
            ![[FRSAuthManager sharedInstance] isAuthenticated] &&
            ![clientToken isEqualToString:@""]
            );
}


/**
 Lets us know if we need to send a Basic auth header
 
 @return Yes if Basic is needed, No if not
 */
- (BOOL)shouldSendBasic:(NSString *)endpoint withRequestType:(NSString *)requestType {
    //Check if using an auth endpointnot or the client endpoint
    //Not making a delete request i.e. deleting a token
    //And not making a request to the token/me endpoint
    return (
            [endpoint containsString:@"auth/"] ||
            [endpoint containsString:clientEndpoint]
    ) &&
    ![requestType isEqualToString:@"DELETE"] &&
    ![endpoint containsString:tokenSelfEndpoint];
}

- (NSString *)userAuthorization {
    return [NSString stringWithFormat:@"Bearer %@", [[FRSSessionManager sharedInstance] authenticationToken]];
}

- (NSString *)clientAuthorization {
    return [NSString stringWithFormat:@"Bearer %@", [[FRSSessionManager sharedInstance] bearerForToken:kClientToken]];
}

- (NSString *)basicAuthorization {
    // Create NSData object
    NSData *nsdata = [
                      [NSString stringWithFormat:@"%@:%@", [EndpointManager sharedInstance].currentEndpoint.frescoClientId, [EndpointManager sharedInstance].currentEndpoint.frescoClientSecret]
                      dataUsingEncoding:NSUTF8StringEncoding];
    
    // Get NSString from NSData object in Base64
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
    
    return [NSString stringWithFormat:@"Basic %@", base64Encoded];
}


/**
 Tells us whether we should refresh the currently being used token.
 
 @param error Error from the request made
 @param authHeader The authorization header used in the request sent

 @return Yes if we should refresh, No if should not
 */
- (BOOL)shouldRefresh:(NSError *)error usingHeader:(NSString *)authHeader usingAuth:(FRSRequestAuth)authUsed {
    NSString *responseError = [NSError errorStringFromAPIError:error];
    NSInteger responseCode = [[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
    //Only refresh when the token has expired via the key in the response, or it's a client request and we're getting un-authenticated
    BOOL responseConstitutesRefresh = ([responseError containsString:@"token-expired"]) || (authUsed == FRSClientAuth && responseCode == 401);
    //Never refresh on basic requests, cause that's possible
    return responseConstitutesRefresh && ![authHeader containsString:@"Basic"];
}

#pragma mark - HTTP Methods

- (void)get:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion {
    AFHTTPSessionManager *manager = [self managerWithFrescoConfigurations:endPoint withRequestType:@"GET"];
    FRSRequestAuth requestAuthUsed = self.requestAuth;
    
    [manager GET:endPoint
      parameters:parameters
        progress:nil
         success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
             completion(responseObject, Nil);
         }
         failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
             if([self shouldRefresh:error usingHeader:[[manager requestSerializer] valueForHTTPHeaderField:@"Authorization"] usingAuth:requestAuthUsed]) {
                 [[FRSSessionManager sharedInstance] refreshToken:(requestAuthUsed == FRSUserAuth)
                                                       completion:^(id responseObject, NSError *error) {
                                                           if (!error) {
                                                               [self get:endPoint withParameters:parameters completion:completion];
                                                           } else {
                                                               completion(nil, error);
                                                           }
                                                       }];
                 
             } else {
                 completion(Nil, error);
             }
         }];
}

- (void)post:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion {
    AFHTTPSessionManager *manager = [self managerWithFrescoConfigurations:endPoint withRequestType:@"POST"];
    FRSRequestAuth requestAuthUsed = self.requestAuth;
    
    [manager POST:endPoint
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
              if(completion) completion(responseObject, nil);
          }
          failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
              if([self shouldRefresh:error usingHeader:[[manager requestSerializer] valueForHTTPHeaderField:@"Authorization"] usingAuth:requestAuthUsed]) {
                  [[FRSSessionManager sharedInstance] refreshToken:(requestAuthUsed == FRSUserAuth)
                                                        completion:^(id responseObject, NSError *error) {
                                                            if (!error) {
                                                                [self post:endPoint withParameters:parameters completion:completion];
                                                            } else {
                                                                if(completion) completion(nil, error);
                                                            }
                                                        }];
                  
              } else {
                  if(completion) completion(Nil, error);
              }
          }];
}

- (void)delete:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion {
    AFHTTPSessionManager *manager = [self managerWithFrescoConfigurations:endPoint withRequestType:@"DELETE"];
    
    [manager DELETE:endPoint
         parameters:parameters
            success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
                if(completion) completion(responseObject, Nil);
            }
            failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                if(completion) completion(Nil, error);
            }];
}

- (void)postAvatar:(NSString *)endPoint withParameters:(NSDictionary *)parameters withData:(NSData *)data withName:(NSString *)name withFileName:(NSString *)fileName completion:(FRSAPIDefaultCompletionBlock)completion {
    AFHTTPSessionManager *manager = [self managerWithFrescoConfigurations:endPoint withRequestType:@"POST"];

    [manager POST:endPoint
        parameters:parameters
        constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
          [formData appendPartWithFileData:data name:name fileName:fileName mimeType:@"image/jpeg"];
        }
        progress:^(NSProgress *_Nonnull uploadProgress) {

        }
        success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
          completion(responseObject, nil);
        }
        failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
          completion(nil, error);
        }];
}

#pragma mark - Helpers

- (id)parsedObjectsFromAPIResponse:(id)response cache:(BOOL)cache {
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([[response class] isSubclassOfClass:[NSDictionary class]]) {
        NSManagedObjectContext *managedObjectContext = (cache) ? [appDelegate.coreDataController managedObjectContext] : Nil;
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
        NSManagedObjectContext *managedObjectContext = (cache) ? [appDelegate managedObjectContext] : Nil;

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
    FRSAppDelegate *appDelegate = (FRSAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *objectType = dictionary[@"object"];

    if ([objectType isEqualToString:galleryObjectType]) {
        FRSGallery *galleryToSave = [NSEntityDescription insertNewObjectForEntityForName:@"FRSGallery" inManagedObjectContext:[appDelegate.coreDataController managedObjectContext]];
        [galleryToSave configureWithDictionary:dictionary context:[appDelegate.coreDataController managedObjectContext]];
        
        return galleryToSave;
    } else if ([objectType isEqualToString:storyObjectType]) {
        NSEntityDescription *storyEntity = [NSEntityDescription entityForName:@"FRSStory" inManagedObjectContext:[appDelegate managedObjectContext]];
        FRSStory *story = (FRSStory *)[[NSManagedObject alloc] initWithEntity:storyEntity insertIntoManagedObjectContext:nil];
        [story configureWithDictionary:dictionary];
        return story;
    }

    return dictionary; // not serializable
}

@end
