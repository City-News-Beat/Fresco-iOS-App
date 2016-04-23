//
//  FRSAPIClient.m
//  Fresco
//
//  Created by Daniel Sun on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSAPIClient.h"
#import <AFNetworking/AFNetworking.h>
#import "Fresco.h"
#import "FRSPost.h"

@implementation FRSAPIClient

-(void)handleError:(NSError *)error {
    switch (error.code/100) {
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
                default:
                    break;
            }
            break;
        
        case 3:
            // redirection
            break;
            
        case 2:
            // prolly not an error
            break;
            
        default:
            break;
    }
}

-(void)saveToken:(NSString *)token forUser:(NSString *)userName {
    [SSKeychain setPasswordData:[token dataUsingEncoding:NSUTF8StringEncoding] forService:serviceName account:userName];
}

-(NSString *)tokenForUser:(NSString *)userName {
    return [SSKeychain passwordForService:serviceName account:userName];
}

-(BOOL)isAuthenticated {
    if ([[SSKeychain accountsForService:serviceName] count] > 0) {
        return TRUE;
    }
    
    return FALSE;
}

-(void)signIn:(NSString *)user password:(NSString *)password completion:(FRSAPIDefaultCompletionBlock)completion {
    [self post:loginEndpoint withParameters:@{@"username":user, @"password":password} completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)signInWithTwitter:(NSString *)token withSecret:(NSString *)tokenSecret completion:(FRSAPIDefaultCompletionBlock)completion {

}

-(void)signInWithFacebook:(NSString *)token completion:(FRSAPIDefaultCompletionBlock)completion {
    
}

-(void)fetchGalleriesForUser:(FRSUser *)user completion:(FRSAPIDefaultCompletionBlock)completion {
    
    
}

-(void)pingLocation:(NSDictionary *)location completion:(FRSAPIDefaultCompletionBlock)completion {
    if (![self isAuthenticated]) {
        return;
    }
    
    [self post:locationEndpoint withParameters:location completion:^(id responseObject, NSError *error) {
        
    }];
}

-(id)init {
    self = [super init];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleLocationUpdate:)
                                                     name:FRSLocationUpdateNotification
                                                   object:nil];
    }
    
    return self;
}

-(void)handleLocationUpdate:(NSDictionary *)userInfo {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUserLocation:userInfo completion:^(NSDictionary *response, NSError *error) {
            if (!error) {
                NSLog(@"Sent Location");
            }
            else {
                NSLog(@"Location Error: %@", error);
                [self handleError:error];
            }
        }];
    });
}

/*
    Generic GET request against api BASE url + endpoint, with parameters
 */
-(void)get:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion {
    
    AFHTTPRequestOperationManager *manager = [self managerWithFrescoConfigurations];
    
    [manager GET:endPoint parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        completion(responseObject[@"data"], Nil);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completion(Nil, error);

    }];
}

/*
 
 Generic POST request against api BASE url + endpoint, with parameters
 
 */
-(void)post:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion {
    
    AFHTTPRequestOperationManager *manager = [self managerWithFrescoConfigurations];
    
    [manager POST:endPoint parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        completion(responseObject[@"data"], Nil);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completion(Nil, error);
    }];
}
-(void)put:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion {
    
    AFHTTPRequestOperationManager *manager = [self managerWithFrescoConfigurations];
    
    [manager PUT:endPoint parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        completion(responseObject[@"data"], Nil);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completion(Nil, error);
    }];
}

/*
 
 Fetch assignments w/in radius of user location, calls generic method w/ parameters & endpoint
 
 */
-(void)getAssignmentsWithinRadius:(float)radius ofLocation:(NSArray *)location withCompletion:(FRSAPIDefaultCompletionBlock)completion{

    NSDictionary *params = @{
                             @"lat" :location[0],
                             @"lon" : location[1],
                             @"radius" : @(radius),
                             @"active" : @"true"
                            };
    
    [self get:assignmentsEndpoint withParameters:params completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
    
}

#pragma mark - Gallery Fetch

/*
 
 Fetch galleries w/ limit, calls generic method w/ parameters & endpoint
 
 */

-(void)fetchGalleriesWithLimit:(NSInteger)limit offsetGalleryID:(NSInteger)offset completion:(void(^)(NSArray *galleries, NSError *error))completion {
    
    NSDictionary *params = @{
                             @"limit" : [NSNumber numberWithInteger:limit],
                             @"offset" : @(offset),
                             @"hide": @2,
                             @"stories": @1
                            };
    
    [self get:highlightsEndpoint withParameters:params completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)fetchGalleriesInStory:(NSString *)storyID completion:(void(^)(NSArray *galleries, NSError *error))completion {
    
    NSDictionary *params = @{
                             
               @"id" : storyID,
               @"offset" : @(0),
               @"sort" : @"1",
               @"limit" : @"100",
               @"hide" : @"4" //HIDE NUMBER
    };

    [self get:storyGalleriesEndpoint withParameters:params completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)getRecentGalleriesFromLastGalleryID:(NSString *)galleryID completion:(void(^)(NSArray *galleries, NSError *error))completion{
    
}

#pragma mark - Stories Fetch


-(void)fetchStoriesWithLimit:(NSInteger)limit lastStoryID:(NSInteger)offsetID completion:(void(^)(NSArray *stories, NSError *error))completion {
    
    NSDictionary *params = @{
                             @"limit" : [NSNumber numberWithInteger:limit],
                             @"notags" : @"true",
                             @"offset" : @(offsetID)
                            };
    
    
    [self get:storiesEndpoint withParameters:params completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)updateUserLocation:(NSDictionary *)inputParams completion:(void(^)(NSDictionary *response, NSError *error))completion
{
    return;
    // not authed rn
    
    [self post:@"user/locate" withParameters:inputParams completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
        
}

-(void)fetchFollowing:(void(^)(NSArray *galleries, NSError *error))completion {
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"following" ofType:@"json"]];
    NSError *jsonError;
    NSDictionary *fakeData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
    completion(fakeData[@"data"], jsonError);
}

-(void)uploadPart:(NSInteger)part ofFile:(NSURL *)fileURL toURL:(NSURL *)destinationURL completion:(FRSAPIDefaultCompletionBlock)completion {
    
}
-(AFHTTPRequestOperationManager *)managerWithFrescoConfigurations {
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
   // [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"kFrescoAuthToken"] forHTTPHeaderField:@"authToken"]; // no auth token from user defaults, all in keychain now
    return manager;
}

-(void)createGalleryWithPosts:(NSArray *)posts completion:(FRSAPIDefaultCompletionBlock)completion {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSMutableArray *postsToSend = [[NSMutableArray alloc] init];
    
    for (FRSPost *post in posts) {
        NSMutableDictionary *currentPost = [[NSMutableDictionary alloc] init];
        NSString *localVideoURL = post.videoUrl;
        
        [postsToSend addObject:currentPost];
    }
}

/*  OAUTH 2
 
- logging in
 NSURL *baseURL = [NSURL URLWithString:@"http://example.com/"];
 AFOAuth2Manager *OAuth2Manager =
 [[AFOAuth2Manager alloc] initWithBaseURL:baseURL
 clientID:kClientID
 secret:kClientSecret];
 
 [OAuth2Manager authenticateUsingOAuthWithURLString:@"/oauth/token"
 username:@"username"
 password:@"password"
 scope:@"email"
 success:^(AFOAuthCredential *credential) {
 NSLog(@"Token: %@", credential.accessToken);
 }
 failure:^(NSError *error) {
 NSLog(@"Error: %@", error);
 }];
 
 -- authorizing requests
 
 AFHTTPRequestOperationManager *manager =
 [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
 
 [manager.requestSerializer setAuthorizationHeaderFieldWithCredential:credential];
 
 [manager GET:@"/path/to/protected/resource"
 parameters:nil
 success:^(AFHTTPRequestOperation *operation, id responseObject) {
 NSLog(@"Success: %@", responseObject);
 }
 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
 NSLog(@"Failure: %@", error);
 }];
 
-- save credential
 [AFOAuthCredential storeCredential:credential
 withIdentifier:serviceProviderIdentifier];
 
-- retrieve credential
 AFOAuthCredential *credential =
 [AFOAuthCredential retrieveCredentialWithIdentifier:serviceProviderIdentifier];

 */

/*
 Singleton
 */

+(instancetype)sharedClient {
    static FRSAPIClient *client = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        client = [[FRSAPIClient alloc] init];
        [FRSLocator sharedLocator];
    });
    
    return client;
}


@end
