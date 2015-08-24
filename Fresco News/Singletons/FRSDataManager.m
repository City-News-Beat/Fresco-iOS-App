//
//  FRSDataManager.m
//  Fresco
//
//  Created by Team Fresco on 2/2/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

@import Parse;
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <NSArray+F.h>
#import "FRSDataManager.h"
#import "FRSLocationManager.h"
#import "NSFileManager+Additions.h"
#import "FRSStory.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#define kFrescoUserIdKey @"frescoUserId"
#define kFrescoTokenKey @"frescoAPIToken"

@interface FRSDataManager () {
    @protected
    FRSUser *_currentUser;
    NSString *_frescoAPIToken;
}

@property (nonatomic, strong) NSURLSessionTask *searchTask;

+ (NSURLSessionConfiguration *)frescoSessionConfiguration;

@end

@implementation FRSDataManager

#pragma mark - static methods

+ (FRSDataManager *)sharedManager
{
    static FRSDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FRSDataManager alloc] init];

    });
    return manager;
}

- (BOOL)connected {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

+ (NSURLSessionConfiguration *)frescoSessionConfiguration
{
    NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    return configuration;
}


#pragma mark - object lifecycle

- (id)init
{
    NSURL *baseURL = [NSURL URLWithString:BASE_API];

    if (self = [super initWithBaseURL:baseURL sessionConfiguration:[[self class] frescoSessionConfiguration]]) {
        
        [[self responseSerializer] setAcceptableContentTypes:nil];
        
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            
            //Check if the network is reachable, there's no current user, and there's no login in process
            if(self.reachabilityManager.reachable && self.currentUser == nil && !self.loggingIn){
                
                static dispatch_once_t onceToken;
                
                dispatch_once(&onceToken, ^{
                
                    [self refreshUser:^(BOOL succeeded, NSError *error) {}];
            
                });
            
            }
            
            NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
            
        }];
        
    }
    return self;
}

- (NSString *)endpointForPath:(NSString *)endpoint
{
    return [NSString stringWithFormat:@"%@%@%@",
            [NSURL URLWithString:BASE_API],
            [NSURL URLWithString:BASE_PATH],
            endpoint];
}

#pragma mark - AFHTTPSessionManager overrides

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLResponse *, id, NSError *))completionHandler
{
    NSMutableURLRequest *req = (NSMutableURLRequest *)request;

    if (self.frescoAPIToken) [req setValue:self.frescoAPIToken forHTTPHeaderField:@"authtoken"];
    
    return [super dataTaskWithRequest:req completionHandler:completionHandler];
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromFile:(NSURL *)fileURL
                                         progress:(NSProgress * __autoreleasing *)progress
                                completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    NSMutableURLRequest *req = (NSMutableURLRequest *)request;
    
    if (self.frescoAPIToken) [req setValue:self.frescoAPIToken forHTTPHeaderField:@"authtoken"];
    
    return [super uploadTaskWithRequest:req fromFile:fileURL progress:progress completionHandler:completionHandler];
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromData:(NSData *)bodyData
                                         progress:(NSProgress * __autoreleasing *)progress
                                completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    NSMutableURLRequest *req = (NSMutableURLRequest *)request;
    
    if (self.frescoAPIToken)
        [req setValue:self.frescoAPIToken forHTTPHeaderField:@"authtoken"];
    
    return [super uploadTaskWithRequest:req fromData:bodyData progress:progress completionHandler:completionHandler];
}

- (NSURLSessionUploadTask *)uploadTaskWithStreamedRequest:(NSURLRequest *)request
                                                 progress:(NSProgress * __autoreleasing *)progress
                                        completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;

{
    NSMutableURLRequest *req = (NSMutableURLRequest *)request;
    
    if (self.frescoAPIToken)
        [req setValue:self.frescoAPIToken forHTTPHeaderField:@"authtoken"];
    
    return [super uploadTaskWithStreamedRequest:req progress:progress completionHandler:completionHandler];
    
}


- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                             progress:(NSProgress * __autoreleasing *)progress
                                          destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                    completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;
{
    NSMutableURLRequest *req = (NSMutableURLRequest *)request;
    
    if (self.frescoAPIToken)
        [req setValue:self.frescoAPIToken forHTTPHeaderField:@"authtoken"];
    
    return [super downloadTaskWithRequest:req progress:progress destination:destination completionHandler:completionHandler];
}

#pragma mark - User Methods

/*
** Initiate Parse Sign Up, then run to API sign up
*/

- (void)signupUser:(NSString *)username email:(NSString *)email password:(NSString *)password block:(PFBooleanResultBlock)block
{
    assert(block);
    
    PFUser *user = [PFUser user];
    user.username = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    user.password = password;
    user.email = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([user.email length]) {
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            //Now that we're signed up with Parse create the Fresco user
            if (succeeded) {
                
                [self createFrescoUserWithResponseBlock:^(id responseObject, NSError *error) {

                    if(self.currentUser != nil){
                    
                        [Answers logSignUpWithMethod:@"Fresco"
                                             success:@YES
                                    customAttributes:@{}];
                        
                        block(YES, nil);
 
                    }
                    else{
                        
                        block(NO, error);
                    }
                    
                }];
            }
            // bubble failure back up to caller
            else
                block(NO, error);
        }];
    }
    else {
        NSError *error = [NSError errorWithDomain:ERROR_DOMAIN code:ErrorSignupCantCreateUser userInfo:@{@"error" : @"User has no email"}];
        block(NO, error);
    }
}

/*
** Create a Fresco User in the API
*/

- (void)createFrescoUserWithResponseBlock:(FRSAPIResponseBlock)responseBlock
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    //Construct params to create user
    NSDictionary *params = @{
                             @"email" : [PFUser currentUser].email ?: [NSNull null],
                             @"parse_id" : [PFUser currentUser].objectId};
    
    //Run the API call to create the user on the database side
    [self POST:@"user/create" parameters:params constructingBodyWithBlock:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        FRSUser *user = [MTLJSONAdapter modelOfClass:[FRSUser class] fromJSONDictionary:responseObject[@"data"] error:NULL];
        
        //If the response from the server is valid
        if (user != nil && [user isKindOfClass:[FRSUser class]]) {
            
            self.currentUser = user;
            
            //Update Parse User with Fresco ID
            [[PFUser currentUser] setObject:self.currentUser.userID forKey:kFrescoUserIdKey];
            
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
                
                //User is saved
                if (success){
                    
                    //Check for duplicate installation
                    [self tieUserToInstallation];
                    
                    //Set a new API token with our Parse session
                    [self setNewTokenWithSession:[PFUser currentUser].sessionToken withResonseBlock:^(id responseObject, NSError *error) {
                        
                        if (responseObject != nil){
                            
                            if(responseBlock) responseBlock(user, nil);

                        }
                        else{
                            
                            if(responseBlock) responseBlock(nil, error);
                            
                            NSLog(@"Could not authenticate to the API");
                        }
                        
                    }];

                }
                //User is not saved, delete user from parse
                else {
                    
                    self.currentUser = nil;
                    
                    [[PFUser currentUser] deleteInBackground];
                    
                    NSError *saveError = [NSError errorWithDomain:ERROR_DOMAIN
                                                             code:ErrorSignupCantSaveUser
                                                         userInfo:@{@"error" : @"Couldn't save user"}];
                    
                    responseBlock(nil, saveError);
                    
                }
                
            }];
            
        }
        //If we get an invalid repsonse from the API
        else {
            
            self.currentUser = nil;
            
            [[PFUser currentUser] deleteInBackground];
            
            if(responseBlock){
                
                NSError *error;
                
                if ([[responseObject objectForKey:@"err"] isEqualToString:@"EMAIL_IN_USE"])
                    error = [NSError errorWithDomain:ERROR_DOMAIN code:ErrorSignupCantCreateUser userInfo:@{@"error" : @"Email is already in use"}];
                else
                    error = [NSError errorWithDomain:ERROR_DOMAIN code:ErrorSignupCantCreateUser userInfo:@{@"error" : @"Couldn't create the user"}];
                
                if (responseBlock) responseBlock(nil, error);
                
            }
            
        }
        
    }
    //The request completely fails
    failure:^(NSURLSessionDataTask *task, NSError *error) {
       
        NSLog(@"Error creating new user %@", error);
        
        // delete on Parse
        [[PFUser currentUser] deleteInBackground];
        
        if (responseBlock) responseBlock(nil, error);
        
    }];
}


/*
** Master Logout
*/

- (void)logout
{
    
    [PFUser logOut];
    
    self.currentUser = nil;
    
    self.frescoAPIToken = nil;
    
    self.tokenValidatedForSession = false;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_FIRSTNAME];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_LASTNAME];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_AVATAR];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_TOKEN];
    
    [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:UD_NOTIFICATIONS_COUNT];
    
    //Sync Defaults
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //Send notifications to the rest of the app to update front-end elements
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BADGE_RESET object:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"profilePicReset" object:self];

}

/*
** General Login Method
*/

- (void)loginUser:(NSString *)username password:(NSString *)password block:(PFUserResultBlock)block
{
    assert(block);
    
    username = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                          
    password = [password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
        // upon success connect parse and frs login
        if (user) {
            [self refreshUser:^(BOOL succeeded, NSError *error) {
                
                if(!succeeded)
                    [self logout];
                else
                    block(user, error);
            
            }];
        }
        else block(nil, error);
    }];
}

/*
** Social Login Method
*/

- (void)socialLoginWithUser:(PFUser *)user error:(NSError *)error block:(PFUserResultBlock)block withNetwork:(NSString *)network
{
    
    //If the it's a new user
    if (user.isNew) {
        [self createFrescoUserWithResponseBlock:^(id responseObject, NSError *error) {
            if(!error){
                
                [Answers logSignUpWithMethod:network
                                     success:@YES
                            customAttributes:@{}];
                
                block(user, error);
            }
            else{
                block(nil, error);
            }
        }];
    }
    //Existing user
    else if (user) {
        [self refreshUser:^(BOOL succeeded, NSError *error) {
            if(succeeded)
                block(user, error);
            else
                block(nil, error);

        }];
    }
    // Failure
    else
        block(nil, error);
    
}


/*
** Social Login via Facebook
*/

- (void)loginViaFacebookWithBlock:(PFUserResultBlock)resultBlock
{
    assert(resultBlock);
    
    [PFFacebookUtils logInInBackgroundWithReadPermissions:@[ @"public_profile" ] block:^(PFUser *user, NSError *error) {
    
        [self socialLoginWithUser:user error:error block:resultBlock withNetwork:@"Facebook"];
    
    }];
}

/*
** Social Login via Twitter
*/

- (void)loginViaTwitterWithBlock:(PFUserResultBlock)resultBlock
{
    assert(resultBlock);
    
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
    
        [self socialLoginWithUser:user error:error block:resultBlock withNetwork:@"Twitter"];
   
    }];
}

/*
** Refreshes current user signed in
*/

- (void)refreshUser:(PFBooleanResultBlock)block
{
    self.loggingIn = YES;
    
    //Check if we have a Parse User set
    if([PFUser currentUser] != nil){
    
        //Check to make sure we already have the fresco user id in the PFUser, if not, delete the user from parse as it's invalid
        if([[PFUser currentUser] objectForKey:kFrescoUserIdKey] == nil){
            
            [[PFUser currentUser] deleteInBackground];
            
            self.loggingIn = NO;
        
        }
        //The fresco user id exists and proceed normally
        else{
        
            NSString *userId = [[PFUser currentUser] objectForKey:kFrescoUserIdKey];
            
            [self setCurrentUser:userId withResponseBlock:^(BOOL success, NSError *error) {
            
                //Successful refresh and log in
                if(success){
                    
                    [[FRSLocationManager sharedManager] setupLocationMonitoring];
                    
                    block(YES, nil);
                    
                }
                //Failed refresh and log in
                else{
                    
                    [[FRSDataManager sharedManager] logout];
                    
                    block(NO, nil);
                }

                _loggingIn = NO;
            
            }];
            
        }
    }
}

/*
** Runs a check on the current userId to make sure everything is valid, otherwise cleans up and removes it
*/

- (void)setCurrentUser:(NSString *)frescoUserId withResponseBlock:(FRSAPISuccessBlock)responseBlock
{
    
    __block FRSDataManager *dM = self;
    
    [self setNewTokenWithSession:[PFUser currentUser].sessionToken withResonseBlock:^(FRSUser *user, NSError *error) {
        
        if(!error){
            
            if(user.userID != nil){
                
                [dM tieUserToInstallation];
                
                dM.currentUser = user;
                
                //Cache the user fields
                [[NSUserDefaults standardUserDefaults] setObject:dM.currentUser.first forKey:UD_FIRSTNAME];
                
                [[NSUserDefaults standardUserDefaults] setObject:dM.currentUser.last forKey:UD_LASTNAME];
                
                [[NSUserDefaults standardUserDefaults] setObject:dM.currentUser.avatar forKey:UD_AVATAR];
                
                [[NSUserDefaults standardUserDefaults] synchronize];

                //Send notif to app
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_API_KEY_AVAILABLE object:nil];
                
                responseBlock(YES, nil);
                
            }
            else{
                
                responseBlock(NO, nil);
            
                dM.frescoAPIToken = nil;
                
                NSLog(@"Could not connect retrieve user");
            
            }
        }
        else{
            
            responseBlock(NO, error);
            
            NSLog(@"Could not connect to the API");
            
        }
        
    }];
    
}

/*
** Pull Fresco user information from Fresco's API
*/

- (void)getFrescoUser:(NSString *)userId withResponseBlock:(FRSAPIResponseBlock)responseBlock{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSDictionary *params = @{@"id" : userId};
    
    [self GET:@"user/profile" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        FRSUser *frsUser = [MTLJSONAdapter modelOfClass:[FRSUser class] fromJSONDictionary:responseObject[@"data"] error:NULL];
        
        if(responseBlock) responseBlock(frsUser, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(responseBlock) responseBlock(nil, error);
        
    }];
}


/*
** Request Auth Token from API with Session String
*/

- (void)setNewTokenWithSession:(NSString *)sessionToken withResonseBlock:(FRSAPIResponseBlock)responseBlock{
    
    NSDictionary *params = @{@"parseSession" : sessionToken};
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self POST:@"auth/loginparse" parameters:params success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSString *token = [responseObject valueForKeyPath:@"data.token"];
        
        if(token != nil){
            
            //This token will be used to authenticate data calls that require it
            self.frescoAPIToken = token;
            
            //Set manager var to know that the token is validated
            self.tokenValidatedForSession = YES;
            
            // cache the token
            [[NSUserDefaults standardUserDefaults] setObject:self.frescoAPIToken forKey:kFrescoTokenKey];
            
            FRSUser *user = [MTLJSONAdapter modelOfClass:[FRSUser class] fromJSONDictionary:[responseObject valueForKeyPath:@"data.user"] error:NULL];
            
            responseBlock(user, nil);
            
        }
        else{
            
            NSError *error;
            error = [NSError errorWithDomain:ERROR_DOMAIN
                                        code:ErrorSignupCantGetUser
                                    userInfo:@{@"error" : @"Couldn't retrieve session"}];
            
            responseBlock(nil, error);
        }
        

    } failure:^(NSURLSessionDataTask *task, NSError *error){
    
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        responseBlock(nil, error);
        
    }];
}

/*
** Addresses the possibility that one installation (device) can have several users on it
*/

- (void)tieUserToInstallation
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    PFUser *user = [PFUser currentUser];
    
    if (user && currentInstallation.deviceToken) {
        PFUser *installationOwner = [currentInstallation objectForKey:@"owner"];
        if (![installationOwner.objectId isEqualToString:user.objectId]) {
            [currentInstallation setObject:user forKey:@"owner"];
            [currentInstallation saveInBackground];
        }
    }
}

/*
** Tells us if the user is logged in and loaded
*/

- (BOOL)currentUserIsLoaded
{
    return (self.currentUser.userID && self.frescoAPIToken);
}

- (BOOL)isLoggedIn
{
    if([PFUser currentUser] != nil) return YES;
    
    return NO;
}

// this tests for completeness and should be more comprehensive
- (BOOL)currentUserValid
{
    if (self.currentUser.first && self.currentUser.last) {
        return YES;
    }
    return NO;
}

- (void)updateFrescoUserWithParams:(NSDictionary *)inputParams withImageData:(NSData *)imageData block:(FRSAPISuccessBlock)responseBlock{
    
    if(self.currentUser.userID){
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id" : self.currentUser.userID}];
        
        [params addEntriesFromDictionary:inputParams];
        
        if(!self.tokenValidatedForSession) return;
            
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        [self POST:@"user/update" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            if (imageData != nil) {
                [params removeObjectForKey:@"avatar"];
                [formData appendPartWithFileData:imageData name:@"avatar" fileName:@"avatar.jpg" mimeType:@"image/jpeg"];
            }
            
        }success:^(NSURLSessionDataTask *task, id responseObject) {
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            if(responseObject[@"data"] == nil)
                responseBlock(NO, nil);
            else{
                
                FRSUser *user = [MTLJSONAdapter modelOfClass:[FRSUser class] fromJSONDictionary:responseObject[@"data"] error:NULL];
                
                NSError *error;
                
                if (user.userID != nil) {
                    
                    self.currentUser = user;
                    
                    [[NSUserDefaults standardUserDefaults] setObject:self.currentUser.first forKey:UD_FIRSTNAME];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:self.currentUser.last forKey:UD_LASTNAME];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:self.currentUser.avatar forKey:UD_AVATAR];
                    
                    //Sync defaults
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    if (responseBlock) responseBlock(YES, error);
                    
                }
                else {
                    error = [NSError errorWithDomain:ERROR_DOMAIN
                                                code:ErrorSignupCantGetUser
                                            userInfo:@{@"error" : @"Couldn't get user"}];
                    user = nil;
                    
                    if (responseBlock) responseBlock(NO, error);
                }
                
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            NSLog(@"Error updating user %@", error);
            
            if (responseBlock) responseBlock(NO, error);
            
        }];

    }
    else{
    
        if (responseBlock) responseBlock(NO, nil);
    
    }
}

- (void)disableFrescoUser:(FRSAPISuccessBlock)responseBlock{

    //Make sure we have a user signed in
    if(self.currentUser.userID){
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id" : self.currentUser.userID}];
        
        //Run the disable request
        [self POST:@"user/deactivate" parameters:params success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
            //Successfully disabled
            if ([responseObject[@"err"] isKindOfClass:[NSNull class]]){
                if(responseBlock) responseBlock(YES, nil);
            }
            else{
                if(responseBlock) responseBlock(NO, nil);
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error){
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            if(responseBlock) responseBlock(NO, nil);
            
        }];
    }

}

#pragma mark - Stories

- (void)getStoriesWithResponseBlock:(NSNumber*)offset shouldRefresh:(BOOL)refresh withReponseBlock:(FRSAPIResponseBlock)responseBlock{
    
    NSString *path = @"story/recent";
    
    NSDictionary *params = @{
                             @"limit" :@"8",
                             @"notags" : @"true",
                             @"offset" : offset ?: [NSNumber numberWithInteger:0]
                             };
    
    //If we are refreshing, removed the cached response for the request by setting the cache policy
    if(refresh) self.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    
//    //If we are refreshing, removed the cached response for the request
//    if(refresh){
//        
//        NSMutableURLRequest *request = [[[FRSDataManager sharedManager] requestSerializer]
//                                        requestWithMethod:@"GET"
//                                        URLString:[NSString stringWithFormat:@"%@%@", BASE_API, path]
//                                        parameters:params error:nil];
//        
//        [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
//        
//    }

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSArray *stories = [[responseObject objectForKey:@"data" ] map:^id(id obj) {
            return [MTLJSONAdapter modelOfClass:[FRSStory class] fromJSONDictionary:obj error:NULL];
        }];

        if(responseBlock) responseBlock(stories, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(responseBlock) responseBlock(nil, error);
    }];
    
    //Set the policy back to normal
    self.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    
}

- (void)getStory:(NSString *)storyId withResponseBlock:(FRSAPIResponseBlock)responseBlock {
    
    NSDictionary *params = @{@"id" : storyId};
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self GET:@"story/get/" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
       
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        FRSStory *story = [MTLJSONAdapter modelOfClass:[FRSStory class] fromJSONDictionary:responseObject[@"data"] error:NULL];
        
        if(responseBlock) responseBlock(story, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(responseBlock) responseBlock(nil, error);
        
    }];
    
}

#pragma mark - Galleries

- (void)getGalleriesForUser:(NSString *)userId offset:(NSNumber *)offset shouldRefresh:(BOOL)refresh withResponseBlock:(FRSAPIResponseBlock)responseBlock {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if(userId != nil){
    
        NSDictionary *params = @{ @"id" : userId, @"offset" : offset ?: 0 };
        
        //If we are refreshing, removed the cached response for the request by setting the cache policy
        if(refresh) self.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringCacheData;
        
        [self GET:@"user/galleries" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            NSArray *galleries = [[responseObject objectForKey:@"data"] map:^id(id obj) {
                return [MTLJSONAdapter modelOfClass:[FRSGallery class] fromJSONDictionary:obj error:NULL];
            }];
            
            if(responseBlock) responseBlock(galleries, nil);

            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            if(responseBlock) responseBlock(nil, error);
            
        }];
        
        //Set the policy back to normal
        self.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    
    }

}

- (void)getGalleries:(NSDictionary *)params shouldRefresh:(BOOL)refresh withResponseBlock:(FRSAPIResponseBlock)responseBlock{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    //If we are refreshing, removed the cached response for the request by setting the cache policy
    if(refresh) self.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    
    [self GET:@"gallery/highlights" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSArray *galleries = [[responseObject objectForKey:@"data"] map:^id(id obj) {
            return [MTLJSONAdapter modelOfClass:[FRSGallery class] fromJSONDictionary:obj error:NULL];
        }];
        
        if(responseBlock) responseBlock(galleries, nil);
        
    
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(responseBlock) responseBlock(nil, error);
        
    }];
    
    //Set the policy back to normal
    self.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    
}

- (void)getGallery:(NSString *)galleryId WithResponseBlock:(FRSAPIResponseBlock)responseBlock {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self GET:[NSString stringWithFormat:@"gallery/get?id=%@", galleryId] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        FRSGallery *assignment = [MTLJSONAdapter modelOfClass:[FRSGallery class] fromJSONDictionary:responseObject[@"data"] error:NULL];
        
        if(responseBlock) responseBlock(assignment, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(responseBlock) responseBlock(nil, error);
        
    }];
}

- (void)getGalleriesFromStory:(NSString *)storyId withOffset:(NSNumber *)offset responseBlock:(FRSAPIResponseBlock)responseBlock {
    
    NSDictionary *params;
    
    if(offset != nil && storyId != nil){
        params = @{
                   @"id" : storyId,
                   @"offset" : offset,
                   @"sort" : @"1",
                   @"limit" : @"5",
                   @"hide" : @"1"
                   };
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self GET:@"story/galleries/" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSArray *galleries;
        
        if(responseObject){
            galleries = [[responseObject objectForKey:@"data"] map:^id(id obj) {
                return [MTLJSONAdapter modelOfClass:[FRSGallery class] fromJSONDictionary:obj error:NULL];
            }];
        }
        
        if(responseBlock) responseBlock(galleries, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(responseBlock) responseBlock(nil, error);
        
    }];
    
}

- (void)resetDraftGalleryPost
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:UD_CAPTION_STRING_IN_PROGRESS];
    [defaults setObject:nil forKey:UD_DEFAULT_ASSIGNMENT_ID];
    [defaults setObject:nil forKey:UD_SELECTED_ASSETS];
}

#pragma mark - Assignments

/*
** Get a single assignment with an ID
*/

- (void)getAssignment:(NSString *)assignmentId withResponseBlock:(FRSAPIResponseBlock)responseBlock {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self GET:[NSString stringWithFormat:@"assignment/get?id=%@", assignmentId] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        FRSAssignment *assignment = [MTLJSONAdapter modelOfClass:[FRSAssignment class] fromJSONDictionary:responseObject[@"data"] error:NULL];
        if(responseBlock) responseBlock(assignment, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if(responseBlock) responseBlock(nil, error);
    }];
}

/*
** Get all assignments within a geo and radius
*/

- (void)getAssignmentsWithinRadius:(float)radius ofLocation:(CLLocationCoordinate2D)coordinate withResponseBlock:(FRSAPIResponseBlock)responseBlock
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSDictionary *params = @{@"lat" :@(coordinate.latitude), @"lon" : @(coordinate.longitude), @"radius" : @(radius), @"active" : @"true"};

    [self GET:@"assignment/find" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        if (![responseObject[@"data"] isEqual:[NSNull null]]) {
            NSArray *assignments = [[responseObject objectForKey:@"data"] map:^id(id obj) {
                return [MTLJSONAdapter modelOfClass:[FRSAssignment class] fromJSONDictionary:obj error:NULL];
            }];

            if(responseBlock) responseBlock(assignments, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(responseBlock) responseBlock(nil, error);
        
    }];
}

/*
** Get all clusters within a geo and radius
*/

- (void)getClustersWithinLocation:(float)lat lon:(float)lon radius:(float)radius withResponseBlock:(FRSAPIResponseBlock)responseBlock{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSDictionary *params = @{@"lat" :@(lat), @"lon" : @(lon), @"radius" : @(radius), @"active" : @"true"};
    
    [self GET:@"assignment/findclustered" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(![responseObject[@"data"] isEqual:[NSNull null]]){
            
            NSArray *clusters = [[responseObject objectForKey:@"data"] map:^id(id obj) {
                return [MTLJSONAdapter modelOfClass:[FRSCluster class] fromJSONDictionary:obj error:NULL];
            }];
            
            if(responseBlock) responseBlock(clusters, nil);
            
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(responseBlock) responseBlock(nil, error);
        
    }];
}


#pragma mark - Notifications

/*
** Get notifications for the user
*/

- (void)getNotificationsForUser:(NSNumber*)offset withResponseBlock:(FRSAPIResponseBlock)responseBlock{

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSDictionary *params = @{@"id" : [FRSDataManager sharedManager].currentUser.userID, @"limit" : @"8", @"offset" : offset ?: @"0"};
    
    //Check cache first and short circuit if it exists
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:kFrescoTokenKey];
    
    [self.requestSerializer setValue:token forHTTPHeaderField:@"authToken"];
    
    [self GET:@"notification/list" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(![responseObject[@"data"] isEqual:[NSNull null]]){
            
            self.updatedNotifications = true;
            
            NSArray *notifications = [[responseObject objectForKey:@"data"] map:^id(id obj) {
                return [MTLJSONAdapter modelOfClass:[FRSNotification class] fromJSONDictionary:obj error:NULL];
            }];
            
            if(responseBlock) responseBlock(notifications, nil);
            
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(responseBlock) responseBlock(nil, error);
        
    }];

}

/*
** Set notification as seen
*/

- (void)setNotificationSeen:(NSNumber *)notificationId withResponseBlock:(FRSAPIResponseBlock)responseBlock{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSDictionary *params = @{@"id" : notificationId};
    
    //Check cache first and short circuit if it exists
    NSString *token = self.frescoAPIToken;
    
    [self.requestSerializer setValue:token forHTTPHeaderField:@"authToken"];
    
    [self POST:@"notification/see" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(![responseObject[@"data"] isEqual:[NSNull null]]){
            
            if(responseBlock) responseBlock(responseObject, nil);
            
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(responseBlock) responseBlock(nil, error);
        
    }];
    
}


/*
** Delete a specific notification
*/

- (void)deleteNotification:(NSString *)notificationId withResponseBlock:(FRSAPIResponseBlock)responseBlock{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSDictionary *params = @{@"id" : notificationId};
    
    //Check cache first and short circuit if it exists
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:kFrescoTokenKey];
    
    [self.requestSerializer setValue:token forHTTPHeaderField:@"authToken"];
    
    [self POST:@"notification/delete" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(responseBlock) responseBlock(responseObject, nil);
    
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(responseBlock) responseBlock(nil, error);
        
    }];
    

}

#pragma mark - Location

- (void)updateUserLocation:(NSDictionary *)inputParams block:(FRSAPIResponseBlock)responseBlock
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if (self.currentUser.userID) {
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id" : self.currentUser.userID}];
        
        [params addEntriesFromDictionary:inputParams];
        
        [self POST:@"user/locate" parameters:params constructingBodyWithBlock:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
              
            }failure:^(NSURLSessionDataTask *task, NSError *error) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                NSLog(@"Error: %@", error);
            }];
    }
}

#pragma mark - TOS

- (void)getTermsOfService:(FRSAPIResponseBlock)responseBlock
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    [self GET:@"terms" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (![responseObject[@"data"] isEqual:[NSNull null]]) {
            if(responseBlock) responseBlock(responseObject, nil);
        }

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (responseBlock) responseBlock(nil, error);
    }];
}

@end
