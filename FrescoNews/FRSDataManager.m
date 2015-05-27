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

- (void)currentUserFromParseUser
{
    // user is logged into parse
    if ([PFUser currentUser]) {
        NSString *userId = [[PFUser currentUser] objectForKey:kFrescoUserIdKey];
        
        // make a blank user
        self.currentUser = [[FRSUser alloc] init];
        
        // but user isn't sync'd
        if (!userId || [userId length] == 0) {
            [[PFUser currentUser] fetch];
            userId = [[PFUser currentUser] objectForKey:kFrescoUserIdKey];
            
            // or doesn't exist at all make one asynchronously
            if (!userId || [userId length] == 0) {
                [self createFrescoUser:^(id responseObject, NSError *error) {
                    if (responseObject) {
                        FRSUser *frsUser = responseObject;
                        _currentUser = frsUser;
                        
                        // send data back to Parse
                        [[PFUser currentUser] setObject:_currentUser.userID forKey:kFrescoUserIdKey];
                        [[PFUser currentUser] save];
                    }
                }];
            }
            // this is synchronous
            else
                self.currentUser.userID = userId;
        }
        else
            self.currentUser.userID = userId;
    }
}

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

- (void)logout
{
    self.currentUser = nil;
}

- (FRSUser *)currentUser
{
    // see if we can bootstrap the user from Parse
    if (!_currentUser)
       [self currentUserFromParseUser];

    return _currentUser;
}

- (void)createFrescoUser:(FRSAPIResponseBlock)responseBlock{
 //   NSString *randomEmail = [NSString stringWithFormat:@"jrgresh+fresco%8.f@gmail.com", [NSDate timeIntervalSinceReferenceDate]];
   // NSDictionary *params = @{@"email" : randomEmail, @"password" : @"foobar"};
    
    [self POST:@"/user/create" parameters:nil constructingBodyWithBlock:nil
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

