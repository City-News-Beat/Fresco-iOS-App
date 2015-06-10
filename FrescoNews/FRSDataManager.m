//
//  FRSDataManager.m
//  Fresco
//
//  Created by Team Fresco on 2/2/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import <NSArray+F.h>
@import Parse;
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "FRSDataManager.h"
#import "NSFileManager+Additions.h"
#import "FRSStory.h"
#define kFrescoUserIdKey @"frescoUserId"
#define kFrescoUserData @"frescoUserData"

@interface FRSDataManager () {
    @protected
    FRSUser *_currentUser;
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

#warning Make callback block
- (BOOL)login
{
    FRSUser *frsUser;
   
    // user is logged into parse
    if ([PFUser currentUser]) {
        // check before syncing
        frsUser = [self FRSUserFromPFUser];
    }
    else {
        [[PFUser currentUser] fetch];
        
        // try again
        frsUser = [self FRSUserFromPFUser];
    }
    if (frsUser) {
        _currentUser = frsUser;
        return YES;
    }
    return NO;
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

- (void)bindParseUserToFrescoUser:(PFBooleanResultBlock)block
{
    // user is logged into parse
    if ([PFUser currentUser]) {
        // check before syncing
        FRSUser *frsUser = [self FRSUserFromPFUser];
        if (frsUser) {
            _currentUser = frsUser;
            block(YES, nil);
        }
        // not locally, check/fetch Parse's server
        else {
            [[PFUser currentUser] fetch];
            
            // try again
            frsUser = [self FRSUserFromPFUser];
            
            if (frsUser) {
                _currentUser = frsUser;
                block(YES, nil);
            }
            // still no FRS user? Make one
            else {
                [self createFrescoUser:^(id responseObject, NSError *error) {
                    if ([responseObject isKindOfClass:[FRSUser class]])
                        block(YES, nil);
                    else {
                        NSError *error = [NSError errorWithDomain:@"com.fresconews" code:100 userInfo:@{@"msg" : @"Couldn't create user"}];
                        block(NO, error);
                    }
                }];
            }
        }
    }
}

- (void)synchronizeFRSUser:(FRSUser *)frsUser withBlock:(PFBooleanResultBlock)block
{
    if ([frsUser isKindOfClass:[FRSUser class]]) {
        NSString *jsonUser = [frsUser asJSONString];
        if (jsonUser)
            [[PFUser currentUser] setObject:jsonUser forKey:kFrescoUserData];
        
        // save locally
        [[PFUser currentUser] pinWithName:kFrescoUserData];
        
        // save to parse
        NSError *error;
        if ([[PFUser currentUser] save:&error]) {
            _currentUser = frsUser;
            block(YES, nil);
        }
        else {
            // if we're going to codify this it needs to be centralized -- this is arbitrary
            NSError *saveError = [NSError errorWithDomain:@"com.fresconews" code:100 userInfo:@{@"msg" : @"Couldn't save user"}];
            block (NO, saveError);
        }
    }
    else {
        // if we're going to codify this it needs to be centralized -- this is arbitrary
        NSError *saveError = [NSError errorWithDomain:@"com.fresconews" code:100 userInfo:@{@"msg" : @"Not a user"}];
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

- (void)createFrescoUser:(FRSAPIResponseBlock)responseBlock
{
    NSString *email = [PFUser currentUser].email;
    NSDictionary *params = @{@"email" : email ?: [NSNull null]};
    
#warning this shouldn't return success on email exists and/or I should handle null "data" element
    [self POST:@"/user/create" parameters:params constructingBodyWithBlock:nil
       success:^(NSURLSessionDataTask *task, id responseObject) {
           NSDictionary *data = [NSDictionary dictionaryWithDictionary:[responseObject objectForKey:@"data"]];
           FRSUser *user = [MTLJSONAdapter modelOfClass:[FRSUser class] fromJSONDictionary:data error:NULL];
           
           // synchronize the user
           [self synchronizeFRSUser:user withBlock:^(BOOL succeeded, NSError *error) {
               if (responseBlock) responseBlock(user, nil);
           }];
       } failure:^(NSURLSessionDataTask *task, NSError *error) {
           NSLog(@"Error creating new user %@", error);
           if (responseBlock) responseBlock(nil, error);
       }];
}

- (void)updateFrescoUserWithParams:(NSDictionary *)inputParams block:(FRSAPIResponseBlock)responseBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id" : _currentUser.userID}];
    [params addEntriesFromDictionary:inputParams];
    
    [self POST:@"/user/update" parameters:params constructingBodyWithBlock:nil
       success:^(NSURLSessionDataTask *task, id responseObject) {
           NSDictionary *data = [NSDictionary dictionaryWithDictionary:[responseObject objectForKey:@"data"]];
           FRSUser *user = [MTLJSONAdapter modelOfClass:[FRSUser class] fromJSONDictionary:data error:NULL];

           // synchronize the user
           [self synchronizeFRSUser:user withBlock:^(BOOL succeeded, NSError *error) {
               if (responseBlock) responseBlock(user, nil);
           }];
       } failure:^(NSURLSessionDataTask *task, NSError *error) {
           NSLog(@"Error creating new user %@", error);
           if (responseBlock) responseBlock(nil, error);
       }];
}


#pragma mark - Stories

- (void)getStoriesWithResponseBlock:(FRSAPIResponseBlock)responseBlock {
    
    NSString *path = @"/story/recent";
    
    NSDictionary *params = @{@"limit" : @"3", @"notags" : @"true"};

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
    
    [self GET:@"/story/get/" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
       
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
    
    [self GET:[NSString stringWithFormat:@"/user/galleries?id=%@&offset=%@", userId, offset] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
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
    
    [self GET:[NSString stringWithFormat:@"/gallery/get?id=%@", galleryId] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
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
    
    [self GET:@"/gallery/resolve/" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
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
        
        [self getGalleriesAtURLString:[NSString stringWithFormat:@"/gallery/highlights?offset=%@&stories=true", offset] WithResponseBlock:responseBlock];
    }
    else{
        [self getGalleriesAtURLString:@"/gallery/highlights?stories=true" WithResponseBlock:responseBlock];
    }
}

#pragma mark - Assignments

/*
** Get a single assignment with an ID
*/

- (void)getAssignment:(NSString *)assignmentId withResponseBlock:(FRSAPIResponseBlock)responseBlock {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self GET:[NSString stringWithFormat:@"/assignment/get?id=%@", assignmentId] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
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
    
    NSDictionary *params = @{@"lat" :@(coordinate.latitude), @"lon" : @(coordinate.longitude), @"radius" : @(radius)};

    [self GET:@"/assignment/find" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
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
    
    NSDictionary *params = @{@"lat" :@(lat), @"lon" : @(lon), @"radius" : @(radius)};
    
    [self GET:@"/assignment/findclustered" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
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

- (void)getNotificationsForUser:(NSString *)userId responseBlock:(FRSAPIResponseBlock)responseBlock{

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSDictionary *params = @{@"id" : userId};
    
    [self GET:@"/notification/list" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
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
    
    [self POST:@"/notification/see" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
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
    
    [self POST:@"/notifications/delete" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
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
    [self getGalleriesAtURLString:[NSString stringWithFormat:@"/user/galleries?id=%@", [FRSDataManager sharedManager].currentUser.userID] WithResponseBlock:responseBlock];
}
@end

