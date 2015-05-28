//
//  FRSDataManager.m
//  Fresco
//
//  Created by Team Fresco on 2/2/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import <NSArray+F.h>
#import <Parse/Parse.h>
#import "FRSDataManager.h"
#import "NSFileManager+Additions.h"

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

#warning Check for retain cycles
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
                    if (responseObject) {
                        FRSUser *frsUser = [responseObject copy];
                        
                        frsUser.first = @"J.S.";
                        frsUser.last = @"Bach";
                        
                        NSString *jsonUser = [frsUser asJSONString];
                        if (jsonUser)
                            [[PFUser currentUser] setObject:jsonUser forKey:kFrescoUserData];
                        
                        // save locally
                        [[PFUser currentUser] pinWithName:kFrescoUserData];
                        
                        if ([[PFUser currentUser] save]) {
                            _currentUser = frsUser;
                            block(YES, nil);
                        }
                        else {
                            NSError *saveError = [NSError errorWithDomain:@"com.fresconews" code:100 userInfo:@{@"msg" : @"Couldn't save user"}];
                            block (NO, saveError);
                        }
                    }
                }];
            }
        }
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

/*
- (void)setCurrentUser:(FRSUser *)currentUser
{
    if (currentUser)
        _currentUser = currentUser;
    // log out
    else {
        _currentUser = nil;
        [PFUser logOut];
    }
}
*/


/*
- (FRSUser *)currentUser
{
    // see if we can bootstrap the user from Parse
    if (!_currentUser)
       [self currentUserFromParseUser];

    return _currentUser;
}
*/

- (void)createFrescoUser:(FRSAPIResponseBlock)responseBlock
{
    NSString *randomEmail = [NSString stringWithFormat:@"jrgresh+fresco%8.f@gmail.com", [NSDate timeIntervalSinceReferenceDate]];
    NSDictionary *params = @{@"email" : randomEmail, @"password" : @"foobar"};
    
    [self POST:@"/user/create" parameters:params constructingBodyWithBlock:nil
       success:^(NSURLSessionDataTask *task, id responseObject) {
           NSDictionary *data = [NSDictionary dictionaryWithDictionary:[responseObject objectForKey:@"data"]];
           FRSUser *user = [MTLJSONAdapter modelOfClass:[FRSUser class] fromJSONDictionary:data error:NULL];
           if (responseBlock) responseBlock(user, nil);
       } failure:^(NSURLSessionDataTask *task, NSError *error) {
           NSLog(@"Error creating new user %@", error);
           if (responseBlock) responseBlock(nil, error);
       }];
}


#pragma mark - Stories

- (void)getStoriesWithResponseBlock:(FRSAPIResponseBlock)responseBlock {
    
    NSString *path = @"http://monorail.theburgg.com/fresco/stories.php?type=stories";
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSArray *stories = [responseObject map:^id(id obj) {
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

#pragma mark - Galleries

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

- (void)getHomeDataWithResponseBlock:(NSNumber*)offset responseBlock:(FRSAPIResponseBlock)responseBlock{
    
    if (offset != nil) {
        
        [self getGalleriesAtURLString:[NSString stringWithFormat:@"/gallery/highlights?offset=%@", offset] WithResponseBlock:responseBlock];
    }
    else{
        [self getGalleriesAtURLString:@"/gallery/highlights/" WithResponseBlock:responseBlock];
    }
}

#pragma mark - Assignments

- (void)getAssignment:(NSString *)assignmentId withResponseBlock:(FRSAPIResponseBlock)responseBlock
{
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
- (void)getHomeDataWithResponseBlock:(NSNumber*)offset responseBlock:(FRSAPIResponseBlock)responseBlock
{
    if (offset != nil) {
        
        [self getGalleriesAtURLString:[NSString stringWithFormat:@"/gallery/highlights?offset=%@", offset] WithResponseBlock:responseBlock];
    }
    else {
        [self getGalleriesAtURLString:@"/gallery/highlights/" WithResponseBlock:responseBlock];
    }
}
*/

- (void)getGalleriesWithResponseBlock:(FRSAPIResponseBlock)responseBlock {
    [self getGalleriesAtURLString:[NSString stringWithFormat:@"/user/galleries?id=%@", [FRSDataManager sharedManager].currentUser.userID] WithResponseBlock:responseBlock];
}
@end

