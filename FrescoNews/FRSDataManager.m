//
//  FRSDataManager.m
//  Fresco
//
//  Created by Team Fresco on 2/2/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

#import "FRSDataManager.h"
#import <ASIHTTPRequest/ASIFormDataRequest.h>
#import "NSFileManager+Additions.h"
#import "ASIFormDataRequest+Array.h"
#import <NSArray+F.h>

static NSString * const kPersistedStoriesFilename = @"stories.frs";
static NSString * const kPersistedUserFilename = @"user.usr";

@interface FRSDataManager () {
    @protected
    FRSUser *_currentUser;
}

@property (nonatomic, strong) NSURLSessionTask *searchTask;

+ (NSURLSessionConfiguration *)frescoSessionConfiguration;
+ (NSString *)userPath;

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


#pragma - login

+ (NSString *)userPath
{
    return [[NSFileManager libraryDirectoryPath] stringByAppendingPathComponent:kPersistedUserFilename];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password responseBlock:(FRSAPIResponseBlock)responseBlock
{
    NSString *path = @"frs-login.php";
    NSDictionary *params = @{@"username": username, @"password" : password};
    [self GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        FRSUser *user = [MTLJSONAdapter modelOfClass:[FRSUser class] fromJSONDictionary:responseObject error:NULL];
        [self setCurrentUser:user];
        if (responseBlock) responseBlock(user, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (responseBlock) responseBlock(nil, error);
    }];
}

- (void)setCurrentUser:(FRSUser *)currentUser
{
    if (_currentUser != currentUser) {
        NSString *userPath = [[self class] userPath];
        if (currentUser) {
            _currentUser = currentUser;
            [NSKeyedArchiver archiveRootObject:_currentUser toFile:userPath];
        }
        else {
            _currentUser = nil;
            [[NSFileManager defaultManager] removeItemAtPath:userPath error:NULL];
        }
    }
}

- (FRSUser *)currentUser
{
    if (!_currentUser) {
        NSString *userPath = [[self class] userPath];
        _currentUser = [NSKeyedUnarchiver unarchiveObjectWithFile:userPath];
    }
    return _currentUser;
}

- (void)logout
{
    [self setCurrentUser:nil];
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


- (void)getGalleriesWithResponseBlock:(FRSAPIResponseBlock)responseBlock {
    [self getGalleriesAtURLString:@"/user/galleries?id=55284ea411fe08b11f004297" WithResponseBlock:responseBlock];
}

#pragma mark - Assignments

/*
** Get a single assignment with an ID
*/

- (void)getAssignment:(NSString *)assignmentId WithResponseBlock:(FRSAPIResponseBlock)responseBlock {
    
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

- (void)getAssignmentsWithinLocation:(float)lat lon:(float)lon radius:(float)radius  WithResponseBlock:(FRSAPIResponseBlock)responseBlock{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSDictionary *params = @{@"lat" :@(lat), @"lon" : @(lon), @"radius" : @(radius)};
    
    [self GET:@"/assignment/find" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(![responseObject[@"data"] isEqual:[NSNull null]]){
        
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


#pragma mark - Notifications

/*
** Get notifications for the user
*/

- (void)getNotificationsForUser:(FRSAPIResponseBlock)responseBlock{

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSDictionary *params = @{@"user_id" : @""};
    
    #warning will not work, endpoint does not exist
    [self GET:@"/notifications/get" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
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
** Delete a specific notification
*/

- (void)deleteNotification:(NSString *)notificationId withResponseBlock:(FRSAPIResponseBlock)responseBlock{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSDictionary *params = @{@"id" : notificationId};
    
    #warning will not work, endpoint does not exist
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






@end
