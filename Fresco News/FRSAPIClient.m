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
-(void)signInWithTwitter:(TWTRSession *)session completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *twitterAccessToken = session.authToken;
    NSString *twitterAccessTokenSecret = session.authTokenSecret;
    NSDictionary *authDictionary = @{@"platform" : @"twitter", @"token" : twitterAccessToken, @"secret" : twitterAccessTokenSecret};
    NSLog(@"%@", authDictionary);
    
    [self post:socialLoginEndpoint withParameters:authDictionary completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
        NSLog(@"%@", error);
        // handle cacheing of authentication
        if (!error) {
            [self handleUserLogin:responseObject];
        }
    }];
}

-(void)signInWithFacebook:(FBSDKAccessToken *)token completion:(FRSAPIDefaultCompletionBlock)completion {
    NSString *facebookAccessToken = token.tokenString;
    NSDictionary *authDictionary = @{@"platform" : @"facebook", @"token" : facebookAccessToken};
    NSLog(@"%@", authDictionary);
    [self post:socialLoginEndpoint withParameters:authDictionary completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
        
        // handle internal cacheing of authentication
        if (!error) {
            [self handleUserLogin:responseObject];
        }
    }];
}

-(void)handleUserLogin:(id)responseObject {
    NSLog(@"%@", responseObject);
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
-(void)post:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion
{
    
    AFHTTPRequestOperationManager *manager = [self managerWithFrescoConfigurations];
    
    [manager POST:endPoint parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
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

-(void)getRecentGalleriesFromLastGalleryID:(NSString *)galleryID completion:(void(^)(NSArray *galleries, NSError *error))completion {
    
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
    if (![self isAuthenticated]) {
        return;
    }
    
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


-(AFHTTPRequestOperationManager *)managerWithFrescoConfigurations {
    
    if (!self.requestManager) {
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
        [manager.requestSerializer setValue:@"Basic MTMzNzp0aGlzaXNhc2VjcmV0" forHTTPHeaderField:@"Authorization"];
        [manager.requestSerializer setValue:@"x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        manager.responseSerializer = [[FRSJSONResponseSerializer alloc] init];
        return manager;
    }
    
    return self.requestManager;
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
