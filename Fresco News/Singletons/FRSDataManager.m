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
#import "NSFileManager+Additions.h"
#import "FRSStory.h"

#define kFrescoUserIdKey @"frescoUserId"

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

+ (NSURLSessionConfiguration *)frescoSessionConfiguration
{
    NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    return configuration;
}

#pragma mark - object lifecycle

- (id)init
{
    NSURL *baseURL = [NSURL URLWithString:[VariableStore sharedInstance].baseAPI];

    if (self = [super initWithBaseURL:baseURL sessionConfiguration:[[self class] frescoSessionConfiguration]]) {
        
        [[self responseSerializer] setAcceptableContentTypes:nil];
    }
    return self;
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
                
                //Check for duplicate installation
                [self tieUserToInstallation];
                
                [self createFrescoUserWithResponseBlock:^(id responseObject, NSError *error) {

                    block(self.currentUser ? YES : NO, error);
                    
                }];
            }
            // bubble failure back up to caller
            else
                block(succeeded, error);
        }];
    }
    else {
        NSError *error = [NSError errorWithDomain:[VariableStore sharedInstance].errorDomain code:ErrorSignupCantCreateUser userInfo:@{@"error" : @"User has no email"}];
        block(NO, error);
    }
}

/*
** Create a Fresco User in the API
*/

- (void)createFrescoUserWithResponseBlock:(FRSAPIResponseBlock)responseBlock
{
    
    //Construct params to create user
    NSDictionary *params = @{@"email" : [PFUser currentUser].email ?: [NSNull null], @"parse_id" : [PFUser currentUser].objectId};
    
    //Run the API call to create the user on the database side
    [self POST:@"user/create" parameters:params constructingBodyWithBlock:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        FRSUser *user = [MTLJSONAdapter modelOfClass:[FRSUser class] fromJSONDictionary:responseObject[@"data"] error:NULL];
        
        //If the response from the server is valid
        if ([user isKindOfClass:[FRSUser class]] && user.userID) {
            
            self.currentUser = user;
            
            //Update Parse User with Fresco ID
            [[PFUser currentUser] setObject:self.currentUser.userID forKey:kFrescoUserIdKey];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
                
                //User is saved
                if (success){
                    
                    // authenticate to the API
                    [self validateAPIToken:^(id responseObject, NSError *error) {
                        
                        if (error)
                            NSLog(@"Could not authenticate to the API");
                        else
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAPIKeyAvailable object:nil];
                        
                    }];
                    
                    if(responseBlock) responseBlock(user, nil);
                    
                }
                //User is not saved (delete user)
                else {
                    
                    [[PFUser currentUser] deleteInBackground];
                    
                    NSError *saveError = [NSError errorWithDomain:[VariableStore sharedInstance].errorDomain
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
                    error = [NSError errorWithDomain:[VariableStore sharedInstance].errorDomain code:ErrorSignupCantCreateUser userInfo:@{@"error" : @"Email is already in use"}];
                else
                    error = [NSError errorWithDomain:[VariableStore sharedInstance].errorDomain code:ErrorSignupCantCreateUser userInfo:@{@"error" : @"Couldn't create the user"}];
                
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
** Master Logout
*/

- (void)logout
{
    [PFUser logOut];
    self.currentUser = nil;
    self.frescoAPIToken = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"frescoAPIToken"];
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
                
                block(user, error);
            
            }];
        }
        else block(nil, error);
    }];
}

/*
** Social Login Method
*/

- (void)socialLoginWithUser:(PFUser *)user error:(NSError *)error block:(PFUserResultBlock)block
{
    
    //If the it's a new user
    if (user.isNew) {
        [self createFrescoUserWithResponseBlock:^(id responseObject, NSError *error) {
            if(!error)
                block(user, error);
            else
                block(nil, error);
        }];
    }
    //Existing user
    else if (user) {
        [self refreshUser:^(BOOL succeeded, NSError *error) {
            if(!error)
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
    
    [PFFacebookUtils logInInBackgroundWithPublishPermissions:@[ @"publish_actions" ] block:^(PFUser *user, NSError *error) {
    
        [self socialLoginWithUser:user error:error block:resultBlock];
    
    }];
}

/*
** Social Login via Twitter
*/

- (void)loginViaTwitterWithBlock:(PFUserResultBlock)resultBlock
{
    assert(resultBlock);
    
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
    
        [self socialLoginWithUser:user error:error block:resultBlock];
   
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
        
        NSError *error;
        
        //Check if the user exists
        if (!frsUser.userID) {

            frsUser = nil;
            
            //Delete user from Parse if it doesn't exist in the DB
            [[PFUser currentUser] deleteInBackground];
            
            error = [NSError errorWithDomain:[VariableStore sharedInstance].errorDomain code:ErrorSignupCantGetUser userInfo:@{@"error" : @"Can't find the user"}];
            
        }
        
        if(responseBlock) responseBlock(frsUser, error);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
        if(responseBlock) responseBlock(nil, error);
    
    }];
}


/*
** Refreshes current user signed in
*/

- (void)refreshUser:(PFBooleanResultBlock)block
{
    
    //Check to make sure we already have the fresco user id in the PFUser, if not, get the fresco id from parse
    if([[PFUser currentUser] objectForKey:kFrescoUserIdKey] == nil){
    
        [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *responseUser, NSError *error) {
            
            if(error){
    
                NSError *error = [NSError errorWithDomain:[VariableStore sharedInstance].errorDomain code:ErrorSignupCantGetUser userInfo:@{@"error" : @"No user signed in"}];
                
                if(block) block(NO, error);
                
            }
            else{
                
                NSString *userId = [[PFUser currentUser] objectForKey:kFrescoUserIdKey];
                
                [self validateCurrentUser:userId withResponseBlock:^(id responseObject, NSError *error) {
                    
                    if(!error){
                        
                        if(block) block(YES, nil);
                        
                    }
                    
                }];
            
            }
            
        }];
    }
    //The fresco user id exists
    else{
        
        NSString *userId = [[PFUser currentUser] objectForKey:kFrescoUserIdKey];
        
        [self validateCurrentUser:userId withResponseBlock:^(id responseObject, NSError *error) {
        
            if(!error){
                
                block(YES, nil);
            
            }
        
        }];
    
    }
}

/*
 ** Check and validate existing token, otherwise grab a new one
 */

- (void)validateAPIToken:(FRSAPIResponseBlock)responseBlock {
    
    //Check cache first and short circuit if it exists
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"frescoAPIToken"];
    
    if ([token length]) {
        
        [self.requestSerializer setValue:token forHTTPHeaderField:@"authToken"];
        
        //Make sure token is still valid
        [self GET:@"user/me" parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
            
            //If token is valid
            if([responseObject valueForKeyPath:@"data"]){
                
                self.frescoAPIToken = token;
                
                if(responseBlock) responseBlock(self.frescoAPIToken, nil);
                
            }
            //If token is invalid, get a new one
            else{
                
                [self requestNewTokenWithSession:[PFUser currentUser].sessionToken withResonseBlock:^(id responseObject, NSError *error) {
                    
                    if(!error){
                        
                        if(responseBlock) responseBlock(self.frescoAPIToken, nil);
                        
                    }
                    
                }];
                
            }
            
        }failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            [self requestNewTokenWithSession:[PFUser currentUser].sessionToken withResonseBlock:^(id responseObject, NSError *error) {
                
                if(!error){
                    
                    if(responseBlock) responseBlock(self.frescoAPIToken, nil);
                    
                }
                else{
                    if(responseBlock) responseBlock(nil, error);
                }
                
            }];
            
        }];
        
    }
    //If token is not set, get a new one
    else{
        
        [self requestNewTokenWithSession:[PFUser currentUser].sessionToken withResonseBlock:^(id responseObject, NSError *error) {
            
            if(!error){
                
                if(responseBlock) responseBlock(self.frescoAPIToken, nil);
                
            }
            
        }];
        
    }
    
}

/*
 ** Request Auth Token from API with Session String
 */

- (void)requestNewTokenWithSession:(NSString *)sessionToken withResonseBlock:(FRSAPIResponseBlock)responseBlock{
    
    NSDictionary *params = @{@"parseSession" : sessionToken};
    
    [self POST:@"auth/loginparse" parameters:params success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
        
        NSString *token = [responseObject valueForKeyPath:@"data.token"];
        
        if (token) {
            
            //This token will be used to authenticate data calls that require it
            self.frescoAPIToken = token;
            
            // cache the token
            [[NSUserDefaults standardUserDefaults] setObject:self.frescoAPIToken forKey:@"frescoAPIToken"];
            
            if(responseBlock) responseBlock(responseObject, nil);
            
        }
        else{
            
            
        }
        
    } failure:nil];
}

/*
** Runs a check on the curren userId to make sure everything is valid, otherwise cleans up and removes it
*/

- (void)validateCurrentUser:(NSString *)frescoUserId withResponseBlock:(FRSAPIResponseBlock)responseBlock
{

    if (frescoUserId) {
        
        [self getFrescoUser:frescoUserId withResponseBlock:^(FRSUser *responseUser, NSError *error) {
            
            if (!error) {
                
                // this supports notifications, not login state
                [self tieUserToInstallation];
                
                self.currentUser = responseUser;
                
                // authenticate to the API
                [self validateAPIToken:^(id responseObject, NSError *error) {
                    
                    if (error)
                        NSLog(@"Could not authenticate to the API");
                    else
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAPIKeyAvailable object:nil];
                    
                    if(responseBlock) responseBlock(nil, error);
                    
                }];
                
            }
            else {
                
                self.frescoAPIToken = nil;
                
                if(responseBlock) responseBlock(nil, error);
                
                NSLog(@"Error getting fresco user %@", error);
                
            }
            
        }];
        
    }
    //Invalid User Profile
    else {
        
        [[PFUser currentUser] deleteInBackground];
        
    }

}

- (BOOL)isLoggedIn
{
    return (self.currentUser.userID && self.frescoAPIToken);
}

// this tests for completeness and should be more comprehensive
- (BOOL)currentUserValid
{
    if (self.currentUser.first && self.currentUser.last) {
        return YES;
    }
    return NO;
}

- (void)updateFrescoUserWithParams:(NSDictionary *)inputParams withImageData:(NSData *)imageData block:(FRSAPIResponseBlock)responseBlock
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id" : _currentUser.userID}];
    
    [params addEntriesFromDictionary:inputParams];
    
    if(self.currentUser.userID){
    
        [self validateAPIToken:^(id responseObject, NSError *error) {
            
            // on success we call ourselves again
            if (!error) {
                

                [self POST:@"user/update" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                
                    if (imageData != nil) {
                        [params removeObjectForKey:@"avatar"];
                        [formData appendPartWithFileData:imageData name:@"avatar" fileName:@"avatar.jpg" mimeType:@"image/jpeg"];
                    }
                
                }success:^(NSURLSessionDataTask *task, id responseObject) {
                    
                    FRSUser *user = [MTLJSONAdapter modelOfClass:[FRSUser class] fromJSONDictionary:responseObject[@"data"] error:NULL];
                    
                    NSError *error;
                    
                    if ([user isKindOfClass:[FRSUser class]]) {
                        
                        self.currentUser = user;
                    }
                    else {
                        error = [NSError errorWithDomain:[VariableStore sharedInstance].errorDomain
                                                    code:ErrorSignupCantGetUser
                                                userInfo:@{@"error" : @"Couldn't get user"}];
                        user = nil;
                    }
                    
                    if (responseBlock) responseBlock(user, error);
                    
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    
                    NSLog(@"Error updating user %@", error);
                    
                    if (responseBlock) responseBlock(nil, error);
                    
                }];
                
            }
            else {
                NSLog(@"Could not authenticate to the API");
            }
            
        }];
    }
}

#pragma mark - Stories

- (void)getStoriesWithResponseBlock:(NSNumber*)offset  withReponseBlock:(FRSAPIResponseBlock)responseBlock {
    
    NSString *path = @"story/recent";
    
    offset = offset ?: [NSNumber numberWithInteger:0];
    
    NSDictionary *params = @{@"limit" : @"8", @"notags" : @"true", @"offset" : offset, @"min" : @"6"};

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSArray *stories = [[responseObject objectForKey:@"data" ] map:^id(id obj) {
            return [MTLJSONAdapter modelOfClass:[FRSStory class] fromJSONDictionary:obj error:NULL];
        }];

        if(responseBlock)
            responseBlock(stories, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(responseBlock)
            responseBlock(nil, error);
    }];
    
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

- (void)getGalleriesForUser:(NSString *)userId offset:(NSNumber *)offset WithResponseBlock:(FRSAPIResponseBlock)responseBlock {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    offset = offset ?: 0;
    
    [self GET:[NSString stringWithFormat:@"user/galleries?id=%@&offset=%@", userId, offset] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSArray *galleries = [[responseObject objectForKey:@"data"] map:^id(id obj) {
            return [MTLJSONAdapter modelOfClass:[FRSGallery class] fromJSONDictionary:obj error:NULL];
        }];
        
        if(responseBlock) responseBlock(galleries, nil);

        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(responseBlock) responseBlock(nil, error);
        
    }];
}

- (void)getGalleriesAtURLString:(NSString *)urlString WithResponseBlock:(FRSAPIResponseBlock)responseBlock {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSArray *galleries = [[responseObject objectForKey:@"data"] map:^id(id obj) {
            return [MTLJSONAdapter modelOfClass:[FRSGallery class] fromJSONDictionary:obj error:NULL];
        }];
        if(responseBlock)
            responseBlock(galleries, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(responseBlock)
            responseBlock(nil, error);
    }];
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

- (void)getGalleriesFromIds:(NSArray *)ids responseBlock:(FRSAPIResponseBlock)responseBlock {
    
    NSDictionary *params = @{@"galleries" : ids};
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self GET:@"gallery/resolve/" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSArray *galleries = [[responseObject objectForKey:@"data"] map:^id(id obj) {
            return [MTLJSONAdapter modelOfClass:[FRSGallery class] fromJSONDictionary:obj error:NULL];
        }];
        
        if(responseBlock) responseBlock(galleries, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(responseBlock) responseBlock(nil, error);
        
    }];
    
}


- (void)getGalleriesWithResponseBlock:(FRSAPIResponseBlock)responseBlock {
    [self getGalleriesAtURLString:[NSString stringWithFormat:@"user/galleries?id=%@", [FRSDataManager sharedManager].currentUser.userID] WithResponseBlock:responseBlock];
}

- (void)getHomeDataWithResponseBlock:(NSNumber*)offset responseBlock:(FRSAPIResponseBlock)responseBlock{
    
    if (offset != nil) {
        
        [self getGalleriesAtURLString:[NSString stringWithFormat:@"gallery/highlights?offset=%@&stories=true", offset] WithResponseBlock:responseBlock];
    }
    else{
        [self getGalleriesAtURLString:@"gallery/highlights?stories=true" WithResponseBlock:responseBlock];
    }
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
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"frescoAPIToken"];
    
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
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"frescoAPIToken"];
    
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
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"frescoAPIToken"];
    
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
    
    if (self.currentUser.userID) {
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id" : self.currentUser.userID}];
        
        [params addEntriesFromDictionary:inputParams];
        
        [self POST:@"user/locate" parameters:params constructingBodyWithBlock:nil
            success:^(NSURLSessionDataTask *task, id responseObject) {
               // NSLog(@"Successfully called user/locate: %@/%@ (returned values)", responseObject[@"data"][@"last_loc"][@"geo"][@"coordinates"][1], responseObject[@"data"][@"last_loc"][@"geo"][@"coordinates"][0]);
            }failure:^(NSURLSessionDataTask *task, NSError *error) {
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