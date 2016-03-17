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
    NSLog(@"%@", userInfo);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUserLocation:userInfo completion:^(NSDictionary *response, NSError *error) {
            if (!error) {
                NSLog(@"Sent Location");
            }
            else {
                NSLog(@"Location Error: %@", error);
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

-(void)fetchGalleriesWithLimit:(NSInteger)limit offsetGalleryID:(NSInteger)offset completion:(void(^)(NSArray *galleries, NSError *error))completion {
    
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
        NSMutableArray *smallResponse = [[NSMutableArray alloc] init];
        
        for (NSDictionary *object in responseObject) {
            NSMutableDictionary *smallObject = [NSMutableDictionary dictionaryWithDictionary:object];
            NSArray *thumbnails = [smallObject objectForKey:@"thumbnails"];
            NSMutableArray *newThumbnails = [[NSMutableArray alloc] init];
            
            for (NSMutableDictionary *thumbnail in thumbnails) {
                NSMutableDictionary *meta = [NSMutableDictionary dictionaryWithDictionary:thumbnail];
                NSString *imageURL = [meta objectForKey:@"image"];
                imageURL = [imageURL stringByReplacingOccurrencesOfString:@"images/" withString:@"images/small/"];
                [meta setObject:imageURL forKey:@"image"];
                [newThumbnails addObject:meta];
            }
            
            [smallObject setObject:newThumbnails forKey:@"thumbnails"];
            [smallResponse addObject:smallObject];
        }
        
        completion(smallResponse, error);
    }];
}

-(void)updateUserLocation:(NSDictionary *)inputParams completion:(void(^)(NSDictionary *response, NSError *error))completion
{
    
    [self post:@"user/locate" withParameters:inputParams completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
        
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
