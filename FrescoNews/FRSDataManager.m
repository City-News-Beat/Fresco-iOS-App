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

static NSString * const kAPIBaseURLString = @"http://fresconews.com/api/";
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
    NSURL *baseURL = [NSURL URLWithString:kAPIBaseURLString];
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

#pragma mark - posts

-(void)getPostsWithId:(NSNumber*)postId responseBlock:(FRSAPIResponseBlock)responseBlock
{
    NSString *path = @"frs-query.php";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setObject:@"getPost" forKey:@"type"];
    [params setObject:postId forKey:@"postId"];
   
    if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.fresconews.Fresco"]){
        [params setObject: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"sourcesFilter"];
    
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        FRSPost *post = [MTLJSONAdapter modelOfClass:[FRSPost class] fromJSONDictionary:responseObject error:NULL];
        
        if (responseBlock) responseBlock(post, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (responseBlock) responseBlock(nil, error);
    }];


}

- (void)getPostsWithTags:(NSArray *)tags limit:(NSNumber *)limit responseBlock:(FRSAPIArrayResponseBlock)responseBlock
{
    NSString *path = @"frs-query.php";
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setObject:limit forKey:@"limit"];
    
    if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.fresconews.Fresco"])
        [params setObject: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"sourcesFilter"];
    
    if ([tags count]) {
        [params setObject:@"getPostsWithTags" forKey:@"type"];
        NSArray *tagNames = [tags map:^NSString *(FRSTag * obj) {
            return [obj identifier];
        }];
        [params setObject:tagNames forKey:@"tags"];
    }
    else {
        [params setObject:@"getPosts" forKey:@"type"];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSArray *posts = [responseObject map:^id(id obj) {
            return [MTLJSONAdapter modelOfClass:[FRSPost class] fromJSONDictionary:obj error:NULL];
        }];
        
        if (responseBlock) responseBlock(posts, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (responseBlock) responseBlock(nil, error);
    }];
}

- (void)getPostsWithTag:(FRSTag *)tag limit:(NSNumber *)limit responseBlock:(FRSAPIArrayResponseBlock)responseBlock
{
    NSArray *tags = tag ? @[tag] : nil;
    [self getPostsWithTags:tags limit:limit responseBlock:responseBlock];
}

- (void)getPostsAfterId:(NSNumber*)lastId responseBlock:(FRSAPIArrayResponseBlock)responseBlock{
    
    NSString *path = @"frs-query.php";
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setObject:@"getPosts" forKey:@"type"];
    [params setObject:lastId forKey:@"lastId"];
    
    if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.fresconews.Fresco"])
        [params setObject: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"sourcesFilter"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
    
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        NSArray *posts = [responseObject map:^id(id obj) {
            return [MTLJSONAdapter modelOfClass:[FRSPost class] fromJSONDictionary:obj error:NULL];
        }];
        
        if (responseBlock) responseBlock(posts, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        if (responseBlock) responseBlock(nil, error);
    }];
}


#pragma mark - get tags
- (void)getTagsWithResponseBlock:(FRSAPIResponseBlock)responseBlock{
    NSString *path = @"frs-query.php";
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"getTagsWithPosts" forKey:@"type"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        NSArray *tags = [responseObject map:^id(id obj) {
            return [MTLJSONAdapter modelOfClass:[FRSTag class] fromJSONDictionary:obj error:NULL];
        }];
        if(responseBlock)
            responseBlock(tags, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

       if(responseBlock)
           responseBlock(nil, error);
    }];
    
}

#pragma mark - tag search

- (void)searchForTags:(NSString *)searchTerm responseBlock:(FRSAPIArrayResponseBlock)responseBlock
{
    [self cancelSearch];
    NSString *path = @"frs-query.php";
    NSDictionary *params = @{@"type": @"getTags", @"query" : (searchTerm ?: @"")};
    NSURLSessionTask *task = [self GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if (responseBlock) responseBlock(responseObject, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (responseBlock) responseBlock(nil, error);
    }];
    [self setSearchTask:task];
}

- (void)cancelSearch
{
    [[self searchTask] cancel];
    [self setSearchTask:nil];
}

#warning for video
#pragma mark - For Video
- (void)getHomeDataWithResponseBlock:(FRSAPIResponseBlock)responseBlock{
    NSString *path = @"http://monorail.theburgg.com/fresco/home_data.json?type=stories";
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSArray *posts = [responseObject map:^id(id obj) {
            return [MTLJSONAdapter modelOfClass:[FRSPost class] fromJSONDictionary:obj error:NULL];
        }];
        if (responseBlock) responseBlock(posts, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (responseBlock) responseBlock(nil, error);
    }];
    
}

#pragma mark - Stories

- (void)getStoriesWithResponseBlock:(FRSAPIResponseBlock)responseBlock {
    NSString *path = @"http://monorail.theburgg.com/fresco/stories.json?type=stories";
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

@end