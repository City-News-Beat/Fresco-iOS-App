//
//  FRSAPIClient.m
//  Fresco
//
//  Created by Daniel Sun on 1/11/16.
//  Copyright © 2016 Fresco. All rights reserved.
//

#import "FRSAPIClient.h"
#import <AFNetworking/AFNetworking.h>
#import "Fresco.h"

@implementation FRSAPIClient


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
    NSLog(@"LOCATION: %@", userInfo);
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
-(void)post:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion {
    
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
-(void)fetchGalleriesWithLimit:(NSInteger)limit offsetGalleryID:(NSInteger)offset completion:(void(^)(NSArray *galleries, NSError *error))completion{
    
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

-(void)getRecentGalleriesFromLastGalleryID:(NSString *)galleryID completion:(void(^)(NSArray *galleries, NSError *error))completion{
    
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
       /* NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id" : self.currentUser.userID}];
        
        [params addEntriesFromDictionary:inputParams];
        
        [self POST:@"user/locate" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            if(completion) completion(responseObject, nil);
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            if(completion) completion(nil, error);
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            NSLog(@"Error: %@", error);
        }];
        
    }*/
}



-(AFHTTPRequestOperationManager *)managerWithFrescoConfigurations {
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"kFrescoAuthToken"] forHTTPHeaderField:@"authToken"];
    return manager;
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
