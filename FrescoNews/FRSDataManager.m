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
#define kFrescoUserData @"frescoUserData"

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


#pragma mark - User State
- (BOOL)login
{
    FRSUser *frsUser;

    // synchronously fetch the current user from Parse
    [[PFUser currentUser] fetch];
    
    // extract embedded FRSUser data
    frsUser = [self FRSUserFromPFUser];

    if (frsUser) {
        _currentUser = frsUser;

        // silently and asynchronously sync up the fresco user
        [self getFrescoUser:frsUser.userID withResponseBlock:^(FRSUser *responseUser, NSError *error) {
            if (!error) {
                _currentUser = responseUser;
                
                // synchronize this data back to Parse
                [[PFUser currentUser] saveInBackground];
            }
            else {
                NSLog(@"Error getting fresco user %@", error);
            }
        }];
        
        // silently and asynchronously authenticate to the API
        [self getFrescoAPITokenWithResponseBlock:^(id responseObject, NSError *error) {
            if (error)
                NSLog(@"Could not authenticate to the API");
        }];
        
        return YES;
    }
    return NO;
}

- (void)loginWithBlock:(PFBooleanResultBlock)block
{
    // get the user from Parse
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *responseUser, NSError *error) {
        if (!error) {
            FRSUser *frsUser = [self FRSUserFromPFUser];
            
            if (frsUser) {
                // set the "global" user variable
                //_currentUser = frsUser;
                
                // pull the fresco API user
                [self getFrescoUser:frsUser.userID withResponseBlock:^(FRSUser *responseUser, NSError *error) {
                    if (!error) {
                        _currentUser = responseUser;
                        
                        // and write the FRSUser portiong back to Parse
                        [self syncFRSUser:_currentUser toParse:^(BOOL succeeded, NSError *error) {
                            if (!error)
                                // here, we're returning successfuly to the caller
                                block(YES, nil);
                            else
                                block(NO, error);
                        }];
                    }
                    else {
                        block(NO, error);
                    }
                }];
                
                // Authenticate to the API
                [self getFrescoAPITokenWithResponseBlock:^(id responseObject, NSError *error) {
                    if (error)
                        NSLog(@"Could not authenticate to the API");
                }];
                
            }
            else {
                NSError *frsError = [NSError errorWithDomain:[VariableStore sharedInstance].errorDomain
                                                        code:ErrorSignupNoUserFromParseUser
                                                    userInfo:@{@"error" : @"Couldn't extract user from PFUser"}];
                block(NO, frsError);
            }
        }
        else {
            NSLog(@"Error fetching user from Parse: %@", error);
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
            
            // this sets the header on all requests (not that we need it on all requests)
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            [manager.requestSerializer setValue:self.frescoAPIToken forHTTPHeaderField:@"authtoken"];
        }
        
        if (responseBlock)
            responseBlock(token, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(responseBlock)
            responseBlock(nil, error);
    }];
}

- (void)logout
{
    [PFUser logOut];
    self.currentUser = nil;
}

- (void)signupUser:(NSString *)username email:(NSString *)email password:(NSString *)password block:(PFBooleanResultBlock)block
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


- (void)loginUser:(NSString *)username password:(NSString *)password block:(PFUserResultBlock)block
{
    [PFUser logInWithUsernameInBackground:[username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                                 password:[password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                                    block:^(PFUser *user, NSError *error) {
                                        // upon success connect parse and frs login
                                        if (user)
                                            [self login];
                                        
                                        // call the block in any event
                                        block(user, error);
                                    }
     ];
}

- (void)loginViaFacebookWithBlock:(PFUserResultBlock)block
{
    [PFFacebookUtils logInInBackgroundWithPublishPermissions:@[ @"publish_actions" ]
                                                       block:^(PFUser *user, NSError *error) {
                                                           // upon success connect parse and frs login
                                                           if (user) {
                                                               if ([self login])
                                                                   block(user, nil);
                                                               else {
                                                                   [self bindParseUserToFrescoUser:^(BOOL succeeded, NSError *error) {
                                                                       if (succeeded)
                                                                           block(user, nil);
                                                                       else
                                                                           block (nil, error);
                                                                   }];
                                                               }
                                                           }
                                                           else
                                                               block(nil, error);
                                                       }];
}

- (void)loginViaTwitterWithBlock:(PFUserResultBlock)block
{
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        // upon success connect parse and frs login
        if (user) {
            if ([self login])
                block(user, nil);
            else {
                [self bindParseUserToFrescoUser:^(BOOL succeeded, NSError *error) {
                    if (succeeded)
                        block(user, nil);
                    else
                        block (nil, error);
                }];
            }
        }
        else
            block(nil, error);
    }];
}

// maybe skip the local check becuase this is limited to signup and login
- (void)bindParseUserToFrescoUser:(PFBooleanResultBlock)block
{
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(id responseObject, NSError *error) {
        if (!error) {
            FRSUser *frsUser = [self FRSUserFromPFUser];
            
            if (frsUser) {
                _currentUser = frsUser;
                block(YES, nil);
            }
            // no FRS user? Then this must be the very first time. Make one
            else {
                [self createFrescoUser:^(id responseObject, NSError *error) {
                    if ([responseObject isKindOfClass:[FRSUser class]])
                        block(YES, nil);
                    else {
                        block(NO, error);
                    }
                }];
            }
        }
        // error fetching the current user
        else {
            block(NO, error);
        }
    }];
}

// this copies a serialized FRSUser to Parse which allows us to use Parse as the
// authoritative place to read FRSUser data and will make transitioning to a "webhooked"
// architecture easier
- (void)syncFRSUser:(FRSUser *)frsUser toParse:(PFBooleanResultBlock)block
{
    if ([frsUser isKindOfClass:[FRSUser class]]) {
        NSString *jsonUser = [frsUser asJSONString];
        if (jsonUser)
            [[PFUser currentUser] setObject:jsonUser forKey:kFrescoUserData];
        
        // save locally -- not doing anything with this yet
        //[[PFUser currentUser] pinWithName:kFrescoUserData];
        
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
            if (success) {
                _currentUser = frsUser;
                block(YES, nil);
            }
            else {
                // if we're going to codify this it needs to be centralized -- this is arbitrary
                NSError *saveError = [NSError errorWithDomain:@"com.fresconews" code:100 userInfo:@{@"error" : @"Couldn't save user"}];
                block (NO, saveError);
            }
        }];
    }
    else {
        // if we're going to codify this it needs to be centralized -- this is arbitrary
        NSError *saveError = [NSError errorWithDomain:@"com.fresconews" code:100 userInfo:@{@"error" : @"Not a user"}];
        block (NO, saveError);
    }
}

// this extracts embedded FRSUser data within the PFUser which may or may not be sync'd to disk or the server
- (FRSUser *)FRSUserFromPFUser
{
    FRSUser *frsUser;
    NSString *serializedUserData = [[PFUser currentUser] objectForKey:kFrescoUserData];
    
    if ([serializedUserData length]) {
        NSError *jsonError;
        NSData *objectData = [serializedUserData dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:objectData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];
        
        frsUser = [MTLJSONAdapter modelOfClass:[FRSUser class] fromJSONDictionary:jsonDict error:nil];
    }
    return frsUser;
}

// pull fresco user information from Fresco's API
// we could transition away from this when webhooks or other server solution is in place
- (void)getFrescoUser:(NSString *)userId withResponseBlock:(FRSAPIResponseBlock)responseBlock {
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

- (BOOL)currentUserValid
{
    if (self.currentUser.first && self.currentUser.last) {
        return YES;
    }
    return NO;
}

- (void)createFrescoUser:(FRSAPIResponseBlock)responseBlock
{
    NSString *email = [PFUser currentUser].email;
    
    NSDictionary *params = @{@"email" : email ?: [NSNull null], @"parse_id" : [PFUser currentUser].objectId};
    
    [self POST:@"user/create"
    parameters:params constructingBodyWithBlock:nil
       success:^(NSURLSessionDataTask *task, id responseObject) {
           NSDictionary *data = [NSDictionary dictionaryWithDictionary:[responseObject objectForKey:@"data"]];
           FRSUser *user = [MTLJSONAdapter modelOfClass:[FRSUser class] fromJSONDictionary:data error:NULL];
           
           if (user.userID) {
               // synchronize the user
               [self syncFRSUser:user toParse:^(BOOL succeeded, NSError *error) {
                   if (responseBlock)
                       responseBlock(user, nil);
               }];
           }
           else {
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
           if (responseBlock) responseBlock(nil, error);
       }];
}

- (void)updateFrescoUserWithParams:(NSDictionary *)inputParams withImageData:(NSData *)imageData block:(FRSAPIResponseBlock)responseBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id" : _currentUser.userID}];
    
    [params addEntriesFromDictionary:inputParams];

    // sorry to keep this cruft around but let's do so until we verify API auth is in place
    /*
    // if we don't have an API token request one
    if (!self.frescoAPIToken) {
        [self getFrescoAPITokenWithResponseBlock:^(id responseObject, NSError *error) {
            // on success we call ourselves again
            if (!error) {
                // self.frescoAPIToken is set on success so this will not endlessly loop
                // but let's check just to make this code trustable when read
                if (self.frescoAPIToken)
                    [self updateFrescoUserWithParams:inputParams block:responseBlock];
                else
                    NSLog(@"Unexpected error authenticating to the API");
            }
            else {
                NSLog(@"Could not authenticate to the API");
            }
        }];
    }*/
    
    [self POST:@"user/update" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (imageData != nil) {
            [params removeObjectForKey:@"avatar"];
            [formData appendPartWithFileData:imageData name:@"avatar" fileName:@"avatar.jpg" mimeType:@"image/jpeg"];
        }
    }
       success:^(NSURLSessionDataTask *task, id responseObject) {
           
           NSDictionary *data = [NSDictionary dictionaryWithDictionary:[responseObject objectForKey:@"data"]];
           FRSUser *user = [MTLJSONAdapter modelOfClass:[FRSUser class] fromJSONDictionary:data error:NULL];
           // synchronize the user
           [self syncFRSUser:user toParse:^(BOOL succeeded, NSError *error) {
               if (responseBlock) responseBlock(user, nil);
           }];
           
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
           
           // synchronize the user
           [self syncFRSUser:user toParse:^(BOOL succeeded, NSError *error) {
               if (responseBlock) responseBlock(user, nil);
           }];
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
