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
    
    NSURL *baseURL = [NSURL URLWithString:[VariableStore sharedInstance].baseURL];

    if (self = [super initWithBaseURL:baseURL sessionConfiguration:[[self class] frescoSessionConfiguration]]) {
        
        [[self responseSerializer] setAcceptableContentTypes:nil];
    }
    return self;
}

#pragma mark - AFHTTPSessionManager overrides

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLResponse *, id, NSError *))completionHandler
{
    NSMutableURLRequest *req = (NSMutableURLRequest *)request;

    if (self.frescoAPIToken)
        [req setValue:self.frescoAPIToken forHTTPHeaderField:@"authtoken"];
    
    return [super dataTaskWithRequest:req completionHandler:completionHandler];
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromFile:(NSURL *)fileURL
                                         progress:(NSProgress * __autoreleasing *)progress
                                completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    NSMutableURLRequest *req = (NSMutableURLRequest *)request;
    
    if (self.frescoAPIToken)
        [req setValue:self.frescoAPIToken forHTTPHeaderField:@"authtoken"];
    
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

#pragma mark - User State
- (void)loginWithBlock:(PFBooleanResultBlock)block
{
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *responseUser, NSError *error) {

        NSString *frescoUserId = [[PFUser currentUser] objectForKey:kFrescoUserIdKey];
        if (frescoUserId) {
            
            [self tieUserToInstallation];
            
            [self getFrescoUser:frescoUserId withResponseBlock:^(FRSUser *responseUser, NSError *error) {
                if (!error) {
                    _currentUser = responseUser;
                    
                    // authenticate to the API
                    [self getFrescoAPITokenWithResponseBlock:^(id responseObject, NSError *error) {
                        if (error)
                            NSLog(@"Could not authenticate to the API");
                        
                        block(!error, error);
                    }];
                }
                else {
                    self.frescoAPIToken = nil;
                    block(NO, error);
                    NSLog(@"Error getting fresco user %@", error);
                }
            }];
        }
        else {
            block(NO, error);
        }
    }];
}

- (void)getFrescoAPITokenWithResponseBlock:(FRSAPIResponseBlock)responseBlock {
    
    NSDictionary *params = @{@"parseSession" : [PFUser currentUser].sessionToken};
    
    [self POST:@"auth/loginparse" parameters:params success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
        NSString *token = [responseObject valueForKeyPath:@"data.token"];
       
        if (token) {
            // this token will be used to authenticate data calls that require it
            self.frescoAPIToken = token;
        }
        
        if (responseBlock)
            responseBlock(token, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(responseBlock)
            responseBlock(nil, error);
    }];
}

// this addresses the possibility that one installation (device) can
// have several users on it
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

- (void)logout
{
    [PFUser logOut];
    self.currentUser = nil;
}

- (void)signupUser:(NSString *)username email:(NSString *)email password:(NSString *)password block:(PFBooleanResultBlock)block
{
    assert(block);
    
    PFUser *user = [PFUser user];
    user.username = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    user.password = password;
    user.email = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([user.email length]) {
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // now that we're signed up with Parse create the Fresco user
            if (succeeded) {
                [self tieUserToInstallation];
                
                [self createFrescoUserWithResponseBlock:^(id responseObject, NSError *error) {

                    // authenticate to the API
                    [self getFrescoAPITokenWithResponseBlock:^(id responseObject, NSError *error) {
                        if (error)
                            NSLog(@"Could not authenticate to the API");
                        
                        block(self.currentUser ? YES : NO, error);
                    }];
                }];
            }
            // bubble failure back up to caller
            else
                block(succeeded, error);
        }];
    }
    else {
        NSError *error = [NSError errorWithDomain:[VariableStore sharedInstance].errorDomain
                                                 code:ErrorSignupCantCreateUser
                                             userInfo:@{@"error" : @"User has no email"}];
        block(NO, error);
    }
}

/*
- (void)updateUserPassword:(NSString *)username email:(NSString *)email password:(NSString *)password block:(PFBooleanResultBlock)block
{
    PFUser *user = [PFUser user];
    user.username = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    user.password = password;
    user.email = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([user.email length]) {
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // now that we're signed in, let's bind the Parse and FRSUsers
            if (succeeded)
                [self bindParseUserToFrescoUser:block];
            // bubble failure back up to caller
            else
                block(succeeded, error);
        }];
    }
}
*/

- (void)loginUser:(NSString *)username password:(NSString *)password block:(PFUserResultBlock)block
{
    assert(block);
    
    [PFUser logInWithUsernameInBackground:[username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                                 password:[password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                                    block:^(PFUser *user, NSError *error) {
                                        // upon success connect parse and frs login
                                        if (user) {
                                            [self loginWithBlock:^(BOOL succeeded, NSError *error) {
                                                block(user, error);
                                            }];
                                            [self tieUserToInstallation];
                                        }
                                        else
                                            // call the block in any event
                                            block(nil, error);
                                    }
     ];
}

- (void)socialLoginWithUser:(PFUser *)user error:(NSError *)error block:(PFUserResultBlock)block
{
    // first successful login/signup
    if (user.isNew) {
        [self createFrescoUserWithResponseBlock:^(id responseObject, NSError *error) {
            
            // authenticate to the API
            [self getFrescoAPITokenWithResponseBlock:^(id responseObject, NSError *error) {
                if (error)
                    NSLog(@"Could not authenticate to the API");
                
                block(user, error);
            }];
        }];
    }
    // regular successful login
    else if (user) {
        [self loginWithBlock:^(BOOL succeeded, NSError *error) {
            block(user, error);
        }];
    }
    // failure
    else
        block(nil, error);
    
    // doesn't matter too much when this runs
    if (user)
        [self tieUserToInstallation];
}

- (void)loginViaFacebookWithBlock:(PFUserResultBlock)resultBlock
{
    assert(resultBlock);
    
    [PFFacebookUtils logInInBackgroundWithPublishPermissions:@[ @"publish_actions" ]
                                                       block:^(PFUser *user, NSError *error) {
                                                           [self socialLoginWithUser:user error:error block:resultBlock];
                                                       }];
     /*
    [PFFacebookUtils logInInBackgroundWithPublishPermissions:@[ @"publish_actions" ]
                                                       block:^(PFUser *user, NSError *error) {
                                                           // first successful login/signup
                                                           if (user.isNew) {
                                                               [self createFrescoUserWithResponseBlock:^(id responseObject, NSError *error) {
                                                                   
                                                                   // authenticate to the API
                                                                   [self getFrescoAPITokenWithResponseBlock:^(id responseObject, NSError *error) {
                                                                       if (error)
                                                                           NSLog(@"Could not authenticate to the API");
                                                                       
                                                                       block(user, error);
                                                                   }];
                                                               }];
                                                           }
                                                           // regular successful login
                                                           else if (user) {
                                                               [self loginWithBlock:^(BOOL succeeded, NSError *error) {
                                                                   block(user, error);
                                                               }];
                                                           }
                                                           // failure
                                                           else
                                                               block(nil, error);
                                                       }];*/
}

- (void)loginViaTwitterWithBlock:(PFUserResultBlock)resultBlock
{
    assert(resultBlock);
    
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        [self socialLoginWithUser:user error:error block:resultBlock];
    }];
}

// this should only happen once per user creation
- (void)syncFRSUserId:(NSString *)frsUserId toParse:(PFBooleanResultBlock)block
{
    assert(block);
    
    [[PFUser currentUser] setObject:frsUserId forKey:kFrescoUserIdKey];
    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
        if (success) {
            block(YES, nil);
        }
        else {
            NSError *saveError = [NSError errorWithDomain:[VariableStore sharedInstance].errorDomain
                                                     code:ErrorSignupCantSaveUser
                                                 userInfo:@{@"error" : @"Couldn't save user"}];
            block(NO, saveError);
        }
    }];
}


// pull fresco user information from Fresco's API
// we could transition away from this when webhooks or other server solution is in place
- (void)getFrescoUser:(NSString *)userId withResponseBlock:(FRSAPIResponseBlock)responseBlock {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSDictionary *params = @{@"id" : userId};

    [self GET:@"user/profile" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        FRSUser *frsUser = [MTLJSONAdapter modelOfClass:[FRSUser class] fromJSONDictionary:responseObject[@"data"] error:NULL];
        
        NSError *error;
        if (!frsUser.userID) {
            error = [NSError errorWithDomain:[VariableStore sharedInstance].errorDomain code:ErrorSignupCantGetUser userInfo:@{@"error" : @"Can't find the user"}];
            frsUser = nil;
        }
        
        if (responseBlock)
            responseBlock(frsUser, error);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if(responseBlock)
            responseBlock(nil, error);
    }];
}

- (BOOL)currentUserValid
{
    if (self.currentUser.first && self.currentUser.last) {
        return YES;
    }
    return NO;
}

- (void)createFrescoUserWithResponseBlock:(FRSAPIResponseBlock)responseBlock
{
    NSString *email = [PFUser currentUser].email;
    
    NSDictionary *params = @{@"email" : email ?: [NSNull null], @"parse_id" : [PFUser currentUser].objectId};
    
    [self POST:@"user/create"
    parameters:params constructingBodyWithBlock:nil
       success:^(NSURLSessionDataTask *task, id responseObject) {
           NSDictionary *data = [NSDictionary dictionaryWithDictionary:[responseObject objectForKey:@"data"]];
           FRSUser *user = [MTLJSONAdapter modelOfClass:[FRSUser class] fromJSONDictionary:data error:NULL];
           
           if ([user isKindOfClass:[FRSUser class]] && user.userID) {
               self.currentUser = user;
               
               // now write our id back to parse
               [self syncFRSUserId:self.currentUser.userID toParse:^(BOOL succeeded, NSError *error) {
                   if (!succeeded)
                       [[PFUser currentUser] deleteInBackground];
                   
                   if (responseBlock)
                       responseBlock(user, error);
               }];
           }
           else {
               self.currentUser = nil;
               NSError *error;
               if ([[responseObject objectForKey:@"err"] isEqualToString:@"EMAIL_IN_USE"])
                   error = [NSError errorWithDomain:[VariableStore sharedInstance].errorDomain
                                               code:ErrorSignupCantCreateUser
                                           userInfo:@{@"error" : @"Email is already in use"}];
               else
                   error = [NSError errorWithDomain:[VariableStore sharedInstance].errorDomain
                                                       code:ErrorSignupCantCreateUser
                                                   userInfo:@{@"error" : @"Couldn't create FRSUser"}];
               if (responseBlock)
                   responseBlock(nil, error);
           }
       } failure:^(NSURLSessionDataTask *task, NSError *error) {
           NSLog(@"Error creating new user %@", error);
           
           // delete on Parse
           [[PFUser currentUser] deleteInBackground];
           
           if (responseBlock) responseBlock(nil, error);
       }];
}

- (void)updateFrescoUserWithParams:(NSDictionary *)inputParams withImageData:(NSData *)imageData block:(FRSAPIResponseBlock)responseBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id" : _currentUser.userID}];
        
    [params addEntriesFromDictionary:inputParams];

    // if we don't have an API token request one
    if (!self.frescoAPIToken) {
        [self getFrescoAPITokenWithResponseBlock:^(id responseObject, NSError *error) {
            // on success we call ourselves again
            if (!error) {
                // self.frescoAPIToken is set on success so this will not endlessly loop
                // but let's check just to make this code trustable when read
                if (self.frescoAPIToken)
                    [self updateFrescoUserWithParams:inputParams withImageData:imageData block:responseBlock];
                else
                    NSLog(@"Unexpected error authenticating to the API");
            }
            else {
                NSLog(@"Could not authenticate to the API");
            }
        }];
    }
    
    [self POST:@"user/update" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (imageData != nil) {
            [params removeObjectForKey:@"avatar"];
            [formData appendPartWithFileData:imageData name:@"avatar" fileName:@"avatar.jpg" mimeType:@"image/jpeg"];
        }
    }
       success:^(NSURLSessionDataTask *task, id responseObject) {
           
           NSDictionary *data = [NSDictionary dictionaryWithDictionary:[responseObject objectForKey:@"data"]];
           FRSUser *user = [MTLJSONAdapter modelOfClass:[FRSUser class] fromJSONDictionary:data error:NULL];
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
           if (responseBlock)
               responseBlock(user, error);
               
       } failure:^(NSURLSessionDataTask *task, NSError *error) {
           NSLog(@"Error creating new user %@", error);
           if (responseBlock) responseBlock(nil, error);
           
       }];
    
}

- (void)updateFrescoUserSettingsWithParams:(NSDictionary *)inputParams block:(FRSAPIResponseBlock)responseBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id" : _currentUser.userID}];
    [params addEntriesFromDictionary:inputParams];
    
    [self POST:@"user/settings" parameters:params constructingBodyWithBlock:nil
       success:^(NSURLSessionDataTask *task, id responseObject) {
           NSDictionary *data = [NSDictionary dictionaryWithDictionary:[responseObject objectForKey:@"data"]];
           FRSUser *user = [MTLJSONAdapter modelOfClass:[FRSUser class] fromJSONDictionary:data error:NULL];
           
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
           if (responseBlock)
               responseBlock(user, error);
           
       } failure:^(NSURLSessionDataTask *task, NSError *error) {
           NSLog(@"Error creating new user %@", error);
           if (responseBlock) responseBlock(nil, error);
       }];
}

#pragma mark - Stories

- (void)getStoriesWithResponseBlock:(NSNumber*)offset  withReponseBlock:(FRSAPIResponseBlock)responseBlock {
    
    NSString *path = @"story/recent";
    
    offset = offset ?: [NSNumber numberWithInteger:0];
    
    NSDictionary *params = @{@"limit" : @"8", @"notags" : @"true", @"offset" : offset};

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

- (void)getNotificationsForUser:(FRSAPIResponseBlock)responseBlock{

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSDictionary *params = @{@"id" : [FRSDataManager sharedManager].currentUser.userID};
    
    [self GET:@"notification/list" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(![responseObject[@"data"] isEqual:[NSNull null]]){
            
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
    
    [self POST:@"notifications/delete" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(![responseObject[@"data"] isEqual:[NSNull null]]){
            
            if(responseBlock) responseBlock(responseObject, nil);
            
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(responseBlock) responseBlock(nil, error);
        
    }];
    

}

- (void)getGalleriesWithResponseBlock:(FRSAPIResponseBlock)responseBlock {
    [self getGalleriesAtURLString:[NSString stringWithFormat:@"user/galleries?id=%@", [FRSDataManager sharedManager].currentUser.userID] WithResponseBlock:responseBlock];
}

- (void)updateUserLocation:(NSDictionary *)inputParams block:(FRSAPIResponseBlock)responseBlock
{
    if (!self.currentUser.userID) {
        // NSLog(@"Not logged in, could not call user/locate");
        return;
    }

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id" : self.currentUser.userID}];
    [params addEntriesFromDictionary:inputParams];

    [self POST:@"user/locate" parameters:params constructingBodyWithBlock:nil
       success:^(NSURLSessionDataTask *task, id responseObject) {
           // NSLog(@"Successfully called user/locate: %@/%@ (returned values)", responseObject[@"data"][@"last_loc"][@"geo"][@"coordinates"][1], responseObject[@"data"][@"last_loc"][@"geo"][@"coordinates"][0]);
       } failure:^(NSURLSessionDataTask *task, NSError *error) {
           NSLog(@"Error: %@", error);
       }];
}

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
