 
    

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
#import "FRSSessionManager.h"
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

- (AFHTTPSessionManager *)managerWithFrescoConfigurations:(NSString *)endpoint withRequestType:(NSString *)requestType {
    if (!self.requestManager) {
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[EndpointManager sharedInstance].currentEndpoint.baseUrl]];
        self.requestManager = manager;
        self.requestManager.requestSerializer = [[FRSRequestSerializer alloc] init];
        [self.requestManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }

    [self reevaluateAuthorization:endpoint withRequestType:requestType];

    return self.requestManager;
}

/*
 Keychain-Based interaction & authentication
 */
- (void)reevaluateAuthorization:(NSString *)endpoint withRequestType:(NSString *)requestType {
    if ([self shouldSendBasic:endpoint withRequestType:requestType]) {
        [self.requestManager.requestSerializer setValue:[self basicAuthorization] forHTTPHeaderField:@"Authorization"];
    } else if ([self shouldSendClientToken:endpoint]) {
        [self.requestManager.requestSerializer setValue:[self clientAuthorization] forHTTPHeaderField:@"Authorization"];
    } else if ([self shouldSendUserToken:endpoint]) {
        [self.requestManager.requestSerializer setValue:[self userAuthorization] forHTTPHeaderField:@"Authorization"];
    } else {
        [[FRSSessionManager sharedInstance] generateClientCredentials];
        [self.requestManager.requestSerializer setValue:[self basicAuthorization] forHTTPHeaderField:@"Authorization"];
    }
}

- (BOOL)shouldSendClientToken:(NSString *)endpoint {
    NSString *clientToken = [[FRSSessionManager sharedInstance] clientToken];
    return (![[FRSAuthManager sharedInstance] isAuthenticated] && ![endpoint containsString:@"auth/signin"] && ![endpoint containsString:@"auth/token"] && clientToken);
}

- (BOOL)shouldSendUserToken:(NSString *)endpoint {
    return ([[FRSAuthManager sharedInstance] isAuthenticated] && ![endpoint containsString:@"auth/signin"] && ![endpoint containsString:@"auth/token"]);
}

- (BOOL)shouldSendBasic:(NSString *)endpoint withRequestType:(NSString *)requestType {
    return ![requestType isEqualToString:@"DELETE"] && ([endpoint containsString:@"auth/signin"] || [endpoint containsString:@"auth/token"]);
}

- (NSString *)basicAuthorization {
    return [NSString stringWithFormat:@"Basic %@", [EndpointManager sharedInstance].currentEndpoint.frescoClientId];
}

- (NSString *)userAuthorization {
    return [NSString stringWithFormat:@"Bearer %@", [[FRSSessionManager sharedInstance] authenticationToken]];
}

- (NSString *)clientAuthorization {
    return [NSString stringWithFormat:@"Bearer %@", [[FRSSessionManager sharedInstance] clientToken]];
}

/*
 Generic HTTP methods for use within class
 */
- (void)get:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion {
    AFHTTPSessionManager *manager = [self managerWithFrescoConfigurations:endPoint withRequestType:@"GET"];

    [manager GET:endPoint
        parameters:parameters
        progress:^(NSProgress *_Nonnull downloadProgress) {
        }
        success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
          completion(responseObject, Nil);
        }
        failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
          NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
          if (response && response.statusCode == 401) {
              [[FRSSessionManager sharedInstance] refreshToken:[[FRSAuthManager sharedInstance] isAuthenticated]
                                                    completion:^(id responseObject, NSError *error) {
                                                      if (!error) {
                                                          [self get:endPoint withParameters:parameters completion:completion];
                                                      }
                                                    }];
          } else {
              completion(Nil, error);
          }
        }];
}

- (void)post:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion {
    AFHTTPSessionManager *manager = [self managerWithFrescoConfigurations:endPoint withRequestType:@"POST"];

    [manager POST:endPoint
        parameters:parameters
        progress:^(NSProgress *_Nonnull downloadProgress) {
        }
        success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
          completion(responseObject, Nil);
        }
        failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
          NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
          if (response && response.statusCode == 401) {
              [[FRSSessionManager sharedInstance] refreshToken:[[FRSAuthManager sharedInstance] isAuthenticated]
                                                    completion:^(id responseObject, NSError *error) {
                                                      if (!error) {
                                                          [self post:endPoint withParameters:parameters completion:completion];
                                                      }
                                                    }];
          } else {
              completion(Nil, error);
          }
        }];
}

- (void)delete:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion {
    AFHTTPSessionManager *manager = [self managerWithFrescoConfigurations:endPoint withRequestType:@"DELETE"];

    [manager DELETE:endPoint
        parameters:parameters
        success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
          completion(responseObject, Nil);
        }
        failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
          completion(Nil, error);
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
