//
//  FRSDataManager.m
//  Fresco
//
//  Created by Team Fresco on 2/2/14.
//  Copyright (c) 2014 TapMedia LLC. All rights reserved.
//

@import Parse;
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "NSArray+F.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "FRSDataManager.h"
//#import "FRSLocationManager.h"
#import "FRSStory.h"


#define kFrescoUserIdKey @"frescoUserId"
#define kFrescoTokenKey @"frescoAPIToken"

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

- (void)getGalleries:(NSDictionary *)params shouldRefresh:(BOOL)refresh withResponseBlock:(FRSAPIResponseBlock)responseBlock{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if(self.reachabilityManager.reachable && refresh){
        //If we are refreshing, removed the cached response for the request by setting the cache policy
        self.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    }
    
    [[AFHTTPSessionManager manager] GET:@"https://api.fresconews.com/v1/gallery/highlights" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        NSArray *galleries = responseObject[@"data"];
        if(responseBlock) responseBlock(galleries, nil);
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        return;
    }];
    

    //Set the policy back to normal
    self.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    
}

- (void)getStoriesWithOffset:(NSNumber*)offset shouldRefresh:(BOOL)refresh withReponseBlock:(FRSAPIResponseBlock)responseBlock{
    
    NSString *path = @"https://api.fresconews.com/v1/story/recent";
    
    NSDictionary *params = @{
                             @"limit" :@"8",
                             @"notags" : @"true",
                             @"offset" : offset ?: [NSNumber numberWithInteger:0]
                             };
    
    //If we are refreshing, removed the cached response for the request by setting the cache policy
    if(refresh)
        self.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        
        NSArray *stories = [responseObject objectForKey:@"data"];
        
        if(responseBlock) responseBlock(stories, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if(responseBlock) responseBlock(nil, error);
    }];
    
    //Set the policy back to normal
    self.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    
}


@end