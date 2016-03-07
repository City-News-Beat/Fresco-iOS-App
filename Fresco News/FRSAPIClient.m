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

-(void)post:(NSString *)endPoint withParameters:(NSDictionary *)parameters completion:(FRSAPIDefaultCompletionBlock)completion {
    
    AFHTTPRequestOperationManager *manager = [self managerWithFrescoConfigurations];
    
    [manager POST:endPoint parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        completion(responseObject[@"data"], Nil);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        completion(Nil, error);
    }];
}

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

 
///gallery/search?q=test&offset=0&limit=18&verified=true&tags=`
//
//[1:02]
//`/story/search?q=test&offset=0&limit=10`
//
//[1:02]
//`/user/search?q=test&offset=0&limit=10`
//
//
//

#pragma mark - Gallery Fetch

//- (void)getGalleries:(NSDictionary *)params shouldRefresh:(BOOL)refresh withResponseBlock:(FRSAPIResponseBlock)responseBlock{
//    
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//    
//    if(self.reachabilityManager.reachable && refresh){
//        //If we are refreshing, removed the cached response for the request by setting the cache policy
//        self.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringCacheData;
//    }
//    
//    [[AFHTTPSessionManager manager] GET:@"https://api.fresconews.com/v1/gallery/highlights" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
//        
//        NSArray *galleries = responseObject[@"data"];
//        if(responseBlock) responseBlock(galleries, nil);
//        
//        
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        return;
//    }];
//    
//    
//    //Set the policy back to normal
//    self.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
//    
//}




-(void)getGalleriesWithLimit:(NSInteger)limit offsetGalleryID:(NSString *)offsetID completion:(void(^)(NSArray *galleries, NSError *error))completion{
    
    //CHECK FOR RELEASE (FROM DAN)
    NSDictionary *params = @{
                             @"limit" : @(limit),
                             @"last_gallery_id" : offsetID
                             };
    
    [self get:highlightsEndpoint withParameters:params completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

-(void)getRecentGalleriesFromLastGalleryID:(NSString *)galleryID completion:(void(^)(NSArray *galleries, NSError *error))completion{
    
}

#pragma mark - Stories Fetch


-(void)fetchStoriesWithLimit:(NSInteger)limit lastStoryID:(NSString *)offsetID completion:(void(^)(NSArray *stories, NSError *error))completion{
    
    //AFHTTPRequestOperationManager *manager = [self managerWithFrescoConfigurations];
    
    NSDictionary *params = @{
                             @"limit" : @(limit),
                             @"notags" : @"true",
                             @"offset" : (offsetID != Nil) ? offsetID : [NSNumber numberWithInteger:0]
                             };
    
    [self get:storiesEndpoint withParameters:params completion:^(id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

//NSString *path = @"https://api.fresconews.com/v1/story/recent";
//
//NSDictionary *params = @{
//                         @"limit" :@"8",
//                         @"notags" : @"true",
//                         @"offset" : offset ?: [NSNumber numberWithInteger:0]
//                         };
//
////If we are refreshing, removed the cached response for the request by setting the cache policy
//if(refresh)
//self.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
//
//[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//
//[self GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//    
//    
//    NSArray *stories = [responseObject objectForKey:@"data"];
//    
//    if(responseBlock) responseBlock(stories, nil);
//    
//} failure:^(NSURLSessionDataTask *task, NSError *error) {
//    
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//    
//    if(responseBlock) responseBlock(nil, error);
//}];
//
////Set the policy back to normal
//self.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;



-(AFHTTPRequestOperationManager *)managerWithFrescoConfigurations{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_API]];
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"kFrescoAuthToken"] forHTTPHeaderField:@"authToken"];
    return manager;
}

@end
