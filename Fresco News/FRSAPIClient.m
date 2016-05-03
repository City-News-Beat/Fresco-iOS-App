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
    
    [self post:socialLoginEndpoint withParameters:authDictionary completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
        // handle cacheing of authentication
        if (!error) {
            [self handleUserLogin:responseObject];
        }
    }];
}

-(NSString *)authenticationToken {
    
    NSArray *allAccounts = [SSKeychain accountsForService:serviceName];
    
    if ([allAccounts count] == 0) {
        return Nil;
    }
    
    NSDictionary *credentialsDictionary = [allAccounts firstObject];
    NSString *accountName = credentialsDictionary[kSSKeychainAccountKey];
    
    return [SSKeychain passwordForService:serviceName account:accountName];
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

/* 
 Register:
 
 email:              'str', // User's email
 username:           'str', // User's username (no @ at beginning)
 password:           'str', // User's plaintext password
 phone_:             'str', // User's phone number (include country code)
 twitter_handle_:    'str', // User's twitter handle
 social_links_: { // Info for linking social media accounts
   
 },
 installation_: { // Used for push notifications + linking devices to users
    app_version:        'str',
    platform:           'str',
    device_token:       'str',
    timezone_:          'str', // TODO What type??
    locale_identifier_: 'str' // EN-US
 }
 
 Update:
 
 full_name_:         'str', // User's full name
 bio_:               'str', // User's profile bio
 avatar_:            'str', // User's avatar URL
 */


-(void)registerWithUsername:(NSString *)username password:(NSString *)password social:(NSDictionary *)social installation:(NSDictionary *)installation {
    
    // create registration request
    
    NSMutableDictionary *registrationInfo = [[NSMutableDictionary alloc] init];
    [registrationInfo setObject:username forKey:@"username"];
    
    if (password) {
        [registrationInfo setObject:password forKey:@"password"];
    }
    
    if (social) {
        [registrationInfo setObject:social forKey:@"social_links"];
    }
    
    if (installation) {
        [registrationInfo setObject:installation forKey:@"installation"];
    }
    else {
        [registrationInfo setObject:[self currentInstallation] forKey:@"installation"];
    }
    
    // start request
}

/*
  Creates dictionary w/ all current (provided) social links within the application, creates a dictionary with the format needed to be serialized into JSON for the API, will be {} with no links
 */

-(NSDictionary *)socialDigestionWithTwitter:(TWTRSession *)twitterSession facebook:(FBSDKAccessToken *)facebookToken {
    NSMutableDictionary *socialDigestion = [[NSMutableDictionary alloc] init];
    
    if (twitterSession) {
        // add twitter to digestion
        if (twitterSession.authToken && twitterSession.authTokenSecret) {
            NSDictionary *twitterDigestion = @{@"token":twitterSession.authToken, @"secret": twitterSession.authTokenSecret};
            [socialDigestion setObject:twitterDigestion forKey:@"twitter"];
        }
    }
    
    if (facebookToken) {
        // add facebook to digestion
        if (facebookToken.tokenString) {
            NSDictionary *facebookDigestion = @{@"token":facebookToken.tokenString};
            [socialDigestion setObject:facebookDigestion forKey:@"facebook"];
        }
    }
    
    /* if no social links, empty dict (parses out to JSON perfectly)
     
     Result: 
     
     {
        @"facebook": {
            @"token": @"XXXXXX"
        },
        @"twitter": {
            @"token": @"XXXXXX"
            @"secret": @"XXXXX"
        }
     }

     */
    
    return socialDigestion;
}



-(NSDictionary *)currentInstallation {
    NSMutableDictionary *currentInstallation = [[NSMutableDictionary alloc] init];
    
    return currentInstallation;
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
        completion(responseObject, Nil);
        
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
            
            completion(responseObject, Nil);
        
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
        completion(responseObject[@"data"], error);
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
        completion(responseObject[@"data"], error);
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
        completion(responseObject[@"data"], error);
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
        completion(responseObject[@"data"], error);
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
        self.requestManager = manager;
    }
    
    [self reevaluateAuthorization];
    
    return self.requestManager;
}

-(void)reevaluateAuthorization {
    
    if (![self isAuthenticated]) {
        // set client token
        [self.requestManager.requestSerializer setValue:@"Basic MTMzNzp0aGlzaXNhc2VjcmV0" forHTTPHeaderField:@"Authorization"];
    }
    else {
        // set bearer client token
        NSString *currentBearerToken = [self authenticationToken];
        if (currentBearerToken) {
            currentBearerToken = [NSString stringWithFormat:@"Bearer: %@", currentBearerToken];
            [self.requestManager.requestSerializer setValue:currentBearerToken forHTTPHeaderField:@"Authorization"];
        }
        else { // something went wrong here (maybe pass to error handler)
            [self.requestManager.requestSerializer setValue:@"Basic MTMzNzp0aGlzaXNhc2VjcmV0" forHTTPHeaderField:@"Authorization"];
        }
    }
    
    [self.requestManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    self.requestManager.responseSerializer = [[FRSJSONResponseSerializer alloc] init];
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
